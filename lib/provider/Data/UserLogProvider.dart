import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaorre/Model/LoginDataModel.dart';
import 'package:gaorre/Model/WaitingDataModel.dart';
import 'package:gaorre/Model/WaitingLogDataModel.dart';
import 'package:gaorre/provider/Data/loginDataProvider.dart';
import 'package:gaorre/provider/Data/waitingDataProvider.dart';
import 'package:gaorre/services/HTTP_service.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

final userLogProvider =
    StateNotifierProvider<UserLogDataListNotifier, UserLogDataList?>((ref) {
  return UserLogDataListNotifier(ref); // 초기 상태를 null로 설정합니다.
});

// StateNotifier를 확장하여 UserLogDataList 객체를 관리하는 클래스를 정의합니다.
class UserLogDataListNotifier extends StateNotifier<UserLogDataList?> {
  UserLogDataListNotifier(this.ref) : super(null) {
    _startHeartbeatCheck();
  }

  StompClient? _client; // StompClient 인스턴스를 저장할 내부 변수 추가
  final Ref ref;
  Timer? _heartbeatTimer; // 하트비트 타이머..
  List<DateTime?> lastHeartbeatReceived = [
    null,
    null,
    null
  ]; // 마지막 heartbeat 시간 기록
  List<dynamic> subscriptionInfo = [null, null, null];
  /* 
    subscriptionInfo[0] : WaitingData 구독정보
    subscriptionInfo[1] : UserLog 구독정보
    subscriptionInfo[2] : NoShow 구독정보
  */

  void _startHeartbeatCheck() async {
    // 1분마다 heartbeat 체크
    _heartbeatTimer = Timer.periodic(Duration(seconds: 10), (_) async {
      print('구독상태 점검... [userLogProvider - heartBeatTimer]');
      for (int i = 0; i < subscriptionInfo.length; i++) {
        if (subscriptionInfo[i] != null &&
            lastHeartbeatReceived[i] != null &&
            DateTime.now().difference(lastHeartbeatReceived[i]!).inSeconds >
                30) {
          // 2분동안 heartbeat을 받지 못했다면 구독 해제 및 재구독
          print(
              'Heartbeat not received for subscription index $i, re-subscribing... [userLogProvider]');
          unSubscribe(i);
          await subscribeToLogData(
              ref.read(loginProvider.notifier).getLoginData()!.storeCode);
          // sendWaitingData(
          //     ref.read(loginProvider.notifier).getLoginData()!.storeCode);
        }
      }
      // print('구독상태 점검 완료... 이상없음 [waitingProvider - heartBeatTimer]');
    });
  }

  // StompClient 인스턴스를 설정하는 메소드
  void setClient(StompClient? client) {
    print("<UserLogProvider> 스텀프 연결 설정");
    _client = client; // 내부 변수에 StompClient 인스턴스 저장
    print('클라이언트 상태 : ${_client.toString()}');
  }

  void updateState(UserLogDataList newState) {
    print('유저로그 상태 업데이트. [userLogProvider - retrieveUserLogData]');
    state = newState;
    updateWaitingTeamwithLog();
  }

  void updateWaitingTeamwithLog(){
    WaitingData? currentWaitingData = ref.read(waitingProvider.notifier).getWaitingData();
    
    if (currentWaitingData != null) {
      for (WaitingTeam waitingTeam in currentWaitingData.teamInfoList) {
        // 대기번호로 로그 리스트에서 해당 대기번호를 가진 로그 찾기
        UserLogData? log = state!.userLogs?.firstWhere(
          (log) => log.waitingNumber == waitingTeam.waitingNumber,
        );
        
        if (log != null && log.status.startsWith('called')) {
          int minutes = int.parse(log.status.split(' : ')[1]);
          DateTime statusChangedTime = DateTime.parse(log.statusChangeTime!);
          DateTime krStatusChangeTime = statusChangedTime.add(const Duration(hours:-9)); // 로그로 받아온 시간은 UTC임.
          DateTime entryTime = krStatusChangeTime.add(Duration(minutes: minutes));

          // WaitingTeam의 entryTime 속성 업데이트
          waitingTeam.entryTime = entryTime;
        }
      }
    }
    
    ref.read(waitingProvider.notifier).updateState(currentWaitingData!);
  }

void updateWaitingTeamwithEachLog(UserLogData receivedLog){
  // 현재 대기 데이터를 가져옴
  WaitingData? currentWaitingData = ref.read(waitingProvider.notifier).getWaitingData();

  // receivedLog의 status가 'called'로 시작하는지 확인
  if (receivedLog.status.startsWith('called')) {
    if (currentWaitingData != null) {
      // 해당 waitingNumber를 가진 WaitingTeam 찾기
      for (WaitingTeam waitingTeam in currentWaitingData.teamInfoList) {
        if (waitingTeam.waitingNumber == receivedLog.waitingNumber) {
          // 로그에서 분 정보 추출 및 entryTime 계산
          int minutes = int.parse(receivedLog.status.split(' : ')[1]);
          DateTime statusChangedTime = DateTime.parse(receivedLog.statusChangeTime!);
          DateTime entryTime = statusChangedTime.add(Duration(minutes: minutes));

          // WaitingTeam의 entryTime 업데이트
          waitingTeam.entryTime = entryTime;

          // 상태 업데이트
          ref.read(waitingProvider.notifier).updateState(currentWaitingData);
          break; // 일치하는 첫 번째 팀을 업데이트 한 후 루프 종료
        }
      }
    }
  } else {
    return; // 'called'로 시작하지 않는 경우 함수 종료
  }
}


  void resetState() {
    print('유저로그 상태 초기화 요청... [userLogProvider - retrieveUserLogData]');
    state = null;
  }

  Future<void> subscribeToLogData(int storeCode) async {
    print('<UserLog> 구독요청 수신.');
    if(_client == null || !_client!.connected) {
      print(
          'STOMP가 연결되어 있지 않습니다. Subscription aborted. [logDataProvider - subscribeToLogData]');
      await Future.delayed(Duration(seconds: 5));
      print(
          'WaitingData 구독을 재시도 합니다... [logDataProvider - subscribeToLogData]');
      subscribeToLogData(storeCode);
      return;
    }
    subscriptionInfo[1] = _client?.subscribe(
      destination: '/topic/admin/log/$storeCode',
      callback: (StompFrame frame) {
        lastHeartbeatReceived[1] =
            DateTime.now(); // 구독에 응답 받을 때마다 마지막 heartbeat 시간 업데이트
        userLogData_CallBack(frame);
      },
    );
    print('LogData Subscription 객체: ${subscriptionInfo[1].toString()}');
  }

  void userLogData_CallBack(StompFrame frame){
    print('<UserLogData> 메세지 수신. 다음은 수신된 메세지입니다.');
    if (frame!.body != null) {
      print(frame.body.toString());
      Map<String, dynamic> responseData = json.decode(frame.body!);
      UserLogData retrievedData = UserLogData.fromJson(responseData);
      // StateNotifier를 통해 상태를 업데이트합니다.
      updateWaitingTeamwithEachLog(retrievedData);
    }
  }

  Future<void> retrieveUserLogData(LoginData loginData) async {
    print('유저 로그 데이터 신청... [userLogProvider - retrieveUserLogData]');
    final jsonBody = json.encode({
      "storeCode": loginData.storeCode,
      "jwtAdmin": loginData.loginToken,
    });
    try {
      final response =
          await HttpsService.postRequest('/StoreAdmin/log', jsonBody);
      if (response.statusCode == 200) {
        final responseBody = json.decode(utf8.decode(response.bodyBytes));
        if (responseBody['status'] == "200") {
          // 정상 수신 완료;
          UserLogDataList retrievedData =
              UserLogDataList.fromJson(responseBody);
          updateState(retrievedData);
        }
      } else {
        throw "HTTP STATUSCODE 오류 : ${response.statusCode}";
      }
    } catch (error) {
      print('HTTP 에러 발생 : $error [userLogProvider - retrieveUsertLogData]');
    }
  }

  void unSubscribe(int index) {
    // index는 어떤것을 구독해제 할 지 결정하기 위한 변수임.
    subscriptionInfo[index](unsubscribeHeaders: null);
    subscriptionInfo[index] = null;
  }

  UserLogDataList? getState() {
    return state;
  }
}
