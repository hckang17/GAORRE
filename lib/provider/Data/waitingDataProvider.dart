import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/Model/LoginDataModel.dart';
import 'package:orre_manager/Model/WaitingDataModel.dart';
import 'package:orre_manager/presenter/Widget/AlertDialog.dart';
import 'package:orre_manager/provider/Data/loginDataProvider.dart';
import 'package:orre_manager/provider/Data/storeDataProvider.dart';
import 'package:orre_manager/services/HIVE_service.dart';
import 'package:orre_manager/services/HTTP_service.dart';
import 'package:orre_manager/services/SMS_service.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

// WaitingInfo 객체를 관리하는 프로바이더를 정의합니다.
final waitingProvider =
    StateNotifierProvider<WaitingDataNotifier, WaitingData?>((ref) {
  return WaitingDataNotifier(ref); // 초기 상태를 null로 설정합니다.
});

// StateNotifier를 확장하여 WaitingInfo 객체를 관리하는 클래스를 정의합니다.
class WaitingDataNotifier extends StateNotifier<WaitingData?> {
  StompClient? _client; // StompClient 인스턴스를 저장할 내부 변수 추가
  Timer? _heartbeatTimer;  // 하트비트 타이머..
  WaitingDataNotifier(this.ref) : super(null) {
    _startHeartbeatCheck();
  }
  final Ref ref;
  
  List<DateTime?> lastHeartbeatReceived = [null, null, null]; // 마지막 heartbeat 시간 기록
  List<dynamic> subscriptionInfo = [null, null, null];
  /* 
    subscriptionInfo[0] : WaitingData 구독정보
    subscriptionInfo[1] : CallGuest 구독정보
    subscriptionInfo[2] : NoShow 구독정보
  */

  void _startHeartbeatCheck() async {
    // 1분마다 heartbeat 체크
    _heartbeatTimer = Timer.periodic(Duration(seconds: 10), (_) async {
      print('구독상태 점검... [waitingProvider - heartBeatTimer]');
      for (int i = 0; i < subscriptionInfo.length; i++) {
        if (subscriptionInfo[i] != null && lastHeartbeatReceived[i] != null &&
            DateTime.now().difference(lastHeartbeatReceived[i]!).inSeconds > 30) {
          // 2분동안 heartbeat을 받지 못했다면 구독 해제 및 재구독
          print('Heartbeat not received for subscription index $i, re-subscribing...');
          unSubscribe(i);
          await subscribeToWaitingData(ref.read(loginProvider.notifier).getLoginData()!.storeCode);
          sendWaitingData(ref.read(loginProvider.notifier).getLoginData()!.storeCode);
        }
      }
      // print('구독상태 점검 완료... 이상없음 [waitingProvider - heartBeatTimer]');
    });
  }


  // StompClient 인스턴스를 설정하는 메소드
  void setClient(StompClient? client) {
    print("<WaitingProvider> 스텀프 연결 설정");
    _client = client; // 내부 변수에 StompClient 인스턴스 저장
    print('클라이언트 상태 : ${_client.toString()}');
  }

  void saveWaitingData() async {
    try {
      await HiveService.saveData('waitingData', state!.toJson());
      print('[saveWaitingData] 성공! ');
    } catch (error) {
      print('웨이팅데이터 저장 실패... 에러 : $error [saveWaitingData]');
    }
  }

  void loadWaitingData() async {
    print('[WatingData] 데이터 로딩');
    String? waitingDataRaw = await HiveService.retrieveData('waitingData');
    if(waitingDataRaw == null){
      state = null;
    } else {
      Map<String, dynamic> waitingDataJson = jsonDecode(waitingDataRaw);
      WaitingData newWaitingData = WaitingData.fromJson(waitingDataJson);
      updateState(newWaitingData);
    }
  }

  WaitingData? getWaitingData() {
    return state;
  }

  void updateState(WaitingData newState) {
    //디버그용 콘솔//
    print('WaitingData 업데이트 실행');

    if (state == null) {
      // 기존 state가 null이면 newState를 그대로 적용
      print('WaitingData가 null 이므로, 그대로 newState를 적용.');
      state = newState;
      return;
    } else {
      // 기존 state의 복사본을 만듭니다.
      WaitingData? currentState = state;
      List<WaitingTeam> currentTeamInfoList = List.from(currentState!.teamInfoList);
      if(currentState.teamInfoList.length == newState.teamInfoList.length) {
        // 기존정보 갱신인 경우
        print('WaitingTeam 객체 하나하나 변경..');

        for (var newTeam in newState.teamInfoList) {
          // 동일한 waitingNumber를 가진 WaitingTeam을 찾습니다.
          var existingTeamIndex = currentTeamInfoList.indexWhere((team) => team.waitingNumber == newTeam.waitingNumber);
          if (existingTeamIndex != -1) {
            // 이미 기존 대기Team목록에 존재하는 경우 해당 항목을 새로운 값으로 업데이트합니다.
            currentTeamInfoList[existingTeamIndex] = WaitingTeam(
              waitingNumber: newTeam.waitingNumber,
              status: newTeam.status,
              phoneNumber: newTeam.phoneNumber,
              personNumber: newTeam.personNumber,
              entryTime: currentTeamInfoList[existingTeamIndex].entryTime ?? newTeam.entryTime, // entryTime입력이 없을 경우에만 새 entryTime을 적용합니다.
            );
          } else {
            // 기존 대기 Team목록에 없는 경우 새로운 항목으로 추가합니다.
            currentTeamInfoList.add(newTeam);
          }
        }
      } else if(currentState.teamInfoList.length > newState.teamInfoList.length) {
        // 삭제, 착석 등으로 웨이팅 정보가 사라졌을 때.
        print('WaitingTeam 객체 삭제..');

        List<int> deletedTeamIndexes = [];

        for (int i = 0; i < currentTeamInfoList.length; i++) {
          var existingTeamIndex = newState.teamInfoList.indexWhere((team) => team.waitingNumber == currentTeamInfoList[i].waitingNumber);
          if (existingTeamIndex == -1) {
            // 삭제된 항목의 index를 기록합니다.
            deletedTeamIndexes.add(i);
          }
        }

        // 삭제된 항목을 업데이트된 List에서 제거합니다.
        for (int i = deletedTeamIndexes.length - 1; i >= 0; i--) {
          currentTeamInfoList.removeAt(deletedTeamIndexes[i]);
        }
      } else if(currentState.teamInfoList.length < newState.teamInfoList.length) {
        print("신규 WaitingTeam 추가됨");
        for(int i=0; i < newState.teamInfoList.length; i++){
          var existingTeamIndex = currentTeamInfoList.indexWhere((team) => team.waitingNumber == newState.teamInfoList[i].waitingNumber);
          if(existingTeamIndex == -1){
            currentTeamInfoList.add(newState.teamInfoList[i]);
          }
        }
      }

      WaitingData updatedState = WaitingData(
        storeCode: newState.storeCode,
        estimatedWaitingTimePerTeam: newState.estimatedWaitingTimePerTeam,
        teamInfoList: currentTeamInfoList,
      );

      // 새로운 상태로 업데이트합니다.
      state = updatedState;
    }
  }

  Future<bool> requestUserCall(WidgetRef ref, String phoneNumber, int waitingNumber, int storeCode, int minutesToAdd) async {
    print('고객 호출 - waitingNumber $waitingNumber');
    String storeName = ref.read(storeDataProvider.notifier).getStoreData()!.storeName;
    print('우리점포 이름 : $storeName');
    final jsonBody = json.encode({
        "storeCode": storeCode,
        "waitingTeam": waitingNumber,
        "minutesToAdd": minutesToAdd,
    });
    final response = await HttpsService.postRequest('/StoreAdmin/userCall', jsonBody);
    if(response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(utf8.decode(response.bodyBytes));
      try {
        CallWaitingTeam callGuestResponse = CallWaitingTeam.fromJson(responseBody);
        if(callGuestResponse.storeCode == storeCode) //고객호출 성공시! 이때, storeCode가 같은지로 확인함.
        {
          String formattedTime = extractEntryTime(callGuestResponse.entryTime);
          WaitingData? currentState = state;
          // WaitingTeam의 entryTime을 업데이트
          currentState!.teamInfoList.forEach((waitingTeam) {
            if (waitingTeam.waitingNumber == callGuestResponse.waitingTeam) {
              waitingTeam.entryTime = DateTime.parse(callGuestResponse.entryTime);
            }
          });
          updateState(currentState);
          showAlertDialog(ref.context, '$waitingNumber번 고객 호출', '입장 마감 시간 : $formattedTime', null);
          
          String SMScontent = SMScontentString(waitingNumber, storeName, extractEntryTimeInMinutes(callGuestResponse.entryTime));
          print(SMScontent);
          bool result = await SendSMSService.requestSendSMS(ref.context ,phoneNumber, "[웨이팅 호출]", SMScontent);
          if(result) await showAlertDialog(ref.context, "웨이팅 호출 SMS 전송", "성공!", null);
          return true;
        } else {
          // 고객호출 실패
          print('고객호출 실패');
          await showAlertDialog(ref.context, '$waitingNumber번 고객 호출', '고객호출 실패', null);
          return false;
        }
      }catch(error){
        print('고객 호출 실패. 에러 : $error');
        await showAlertDialog(ref.context, '$waitingNumber번 고객 호출', '고객호출 실패', null);
        return false;
      }
    } else {
      print('HTTP 에러. 에러코드 : ${response.statusCode}');
      await showAlertDialog(ref.context, '$waitingNumber번 고객 호출', '고객호출 실패\n잠시후 재시도 해주세요', null);
      return false;
    }
  }

  Future<void> requestUserDelete(BuildContext context, int storeCode, int noShowWaitingNumber) async {
    print('웨이팅유저 삭제 요청');
    final jsonBody = json.encode({
      "storeCode": storeCode,
      "noShowUserCode": noShowWaitingNumber,
    });
    try {
      final response = await HttpsService.postRequest('/StoreAdmin/noShow', jsonBody);
      if (response.statusCode == 200) {
        final responseBody = json.decode(utf8.decode(response.bodyBytes));
        if (responseBody['success'] == true) {
          print('성공적으로 $noShowWaitingNumber번 손님을 웨이팅취소했습니다.');
          showAlertDialog(context, '웨이팅 취소', '$noShowWaitingNumber번 손님 웨이팅해제 완료', null);
          print('...웨이팅 리스트 정보를 새로 요청합니다.');
          sendWaitingData(storeCode);
        } else {
          print('$noShowWaitingNumber번 손님 웨이팅취소를 실패했습니다.');
          showAlertDialog(context, '웨이팅 취소', '$noShowWaitingNumber번 손님 웨이팅해제 실패', null);
        }
      } else {
        throw Exception('Server responded with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('오류 발생, 재시도합니다: $e');
      // await Future.delayed(Duration(seconds: 3)); // 잠시 대기 후 재시도
      // await requestUserDelete(context, storeCode, noShowWaitingNumber); // 재귀적으로 함수 호출
    }
  }

  Future<bool> addWaitingTeam (BuildContext context, LoginData loginData, String phoneNumber, int personCount) async {
    print('수동 웨이팅 팀 추가 요청 발생 [waitingProvider - addWaitingTeam]');
    //자 여기에 기존 state에 동일한 phoneNumber의 웨이팅 유저가 있는지?
    int existingTeamIndex = state!.teamInfoList.indexWhere((team) => team.phoneNumber == phoneNumber);
    if(existingTeamIndex != -1){
      print('이미 동일한 휴대폰 번호의 대기 고객이 존재합니다. [waitingProvider - addWaitingTeam]');
      // showAlertDialog(context, "수동 웨이팅 추가", "이미 동일한 연락처의 대기 고객이 존재합니다!", null);
      return false;
    }
    final jsonBody = json.encode({
      "storeCode" : loginData.storeCode,
      "userPhoneNumber" : phoneNumber,
      "personNumber" : personCount,
    });
    try {
      _client?.send(
        destination: '/app/admin/waiting/make/${loginData.storeCode}/$phoneNumber',
        body: jsonBody
      );
      print('수동 웨이팅 요청을 보냈습니다. [waitingProvider - addWaitingTeam]');
      return true;
    } catch (error) {
      print('에러발생 : $error [waitingProvider - addWaitingTeam]');
      return false;
    } 
  }

  void waitingData_CallBack(StompFrame? frame) {
    print('<WaitingData> 메세지 수신. 다음은 수신된 메세지입니다.');
    if (frame!.body != null) {
      print(frame.body.toString());
      Map<String, dynamic> responseData = json.decode(frame.body!);
      WaitingData waitingResponse = WaitingData.fromJson(responseData);
      // StateNotifier를 통해 상태를 업데이트합니다.
      updateState(waitingResponse);
    }
  }

  Future<void> subscribeToWaitingData(int storeCode) async {
    print('<WaitingData> 구독요청 수신.');
    if (_client == null || !_client!.connected) {
        print('STOMP가 연결되어 있지 않습니다. Subscription aborted. [waitingProvider - subscribeToWaitingData]');
        await Future.delayed(Duration(seconds: 5));
        print('WaitingData 구독을 재시도 합니다... [waitingProvider - subscribeToWaitingData]');
        subscribeToWaitingData(storeCode);
        return;
    }
    if (subscriptionInfo[0] != null) {
        print('이미 <WaitingData>를 구독중입니다.');
        return;
    }
    subscriptionInfo[0] = _client?.subscribe(
      destination: '/topic/admin/dynamicStoreWaitingInfo/$storeCode',
      callback: (StompFrame frame) {
        lastHeartbeatReceived[0] = DateTime.now();  // 구독에 응답 받을 때마다 마지막 heartbeat 시간 업데이트
        waitingData_CallBack(frame);
      },
    );
    print('Subscription 객체: ${subscriptionInfo[0].toString()}');
  }

  void reconnect(int storeCode) {
    print('[waitingData] 스텀프 재연결시도...');
    _client?.activate();
    loadWaitingData();
    subscribeToWaitingData(storeCode);
    sendWaitingData(storeCode);
  }

  void sendWaitingData(int storeCode) {
    print('<WaitingData> 정보 요청');
    _client?.send(
      destination: '/app/admin/dynamicStoreWaitingInfo/$storeCode',
      body: json.encode({
        "storeCode": storeCode,
      }),
    );
  }

  void unSubscribe(int index) { 
    // index는 어떤것을 구독해제 할 지 결정하기 위한 변수임.
    // print("<callGuest> is now unsubscribed");
    subscriptionInfo[index](unsubscribeHeaders: null);
    subscriptionInfo[index] = null;
  }

  Future<bool> confirmEnterance(BuildContext context, LoginData loginData, int waitingNumber) async {
    print('고객 입장 확정 여부 전송... [waitingProvider - confirmEnterance]');
    final jsonBody = json.encode({
      "storeCode" : loginData.storeCode,
      "waitingNumber" : waitingNumber,
      "jwtAdmin" : loginData.loginToken,
    });
    try {
      final response = await HttpsService.postRequest('/StoreAdmin/entering', jsonBody);
      if (response.statusCode == 200) {
        final responseBody = json.decode(utf8.decode(response.bodyBytes));
        if (responseBody['status'] == "200") {
          print('성공적으로 $waitingNumber번 손님을 입장시켰습니다.. [waitingProvider - confirmEnterance]');
          showAlertDialog(context, '입장 확인', '$waitingNumber번 손님 입장처리 완료', null);
          print('...웨이팅 리스트 정보를 새로 요청합니다. [waitingProvider - confirmEnterance]');
          sendWaitingData(loginData.storeCode);
          return true;
        } else {
          print('$waitingNumber번 손님 입장처리를 실패했습니다. [waitingProvider - confirmEnterance]');
          showAlertDialog(context, '입장 확인', '$waitingNumber번 손님 입장처리 실패', null);
          return false;
        }
      } else {
        throw Exception('Server responded with status code: ${response.statusCode} [waitingProvider - confirmEnterance]');
      }
    } catch (e) {
      print('오류 발생, 재시도합니다: $e [waitingProvider - confirmEnterance]');
      return false;
      // await Future.delayed(Duration(seconds: 3)); // 잠시 대기 후 재시도
      // await requestUserDelete(context, storeCode, noShowWaitingNumber); // 재귀적으로 함수 호출
    }

  }



  @override
  void dispose() {
    for(int i=0; i<subscriptionInfo.length; i++){
      if(subscriptionInfo[i] != null){
        unSubscribe(i);
        subscriptionInfo[i] = null;
      }
    }
    _client?.deactivate();
    super.dispose();
  }
}

// extractTime method
String extractEntryTime(String message) {
  DateTime parsedTime = DateTime.parse(message);
  // HH:MM:SS 형식으로 변환
  String formattedTime =
      '${parsedTime.hour.toString().padLeft(2, '0')}:${parsedTime.minute.toString().padLeft(2, '0')}:${parsedTime.second.toString().padLeft(2, '0')}';
  return formattedTime;
}

String extractEntryTimeInMinutes(String message) {
  DateTime parsedTime = DateTime.parse(message);
  String formattedTime = '${parsedTime.hour.toString().padLeft(2, '0')}시${parsedTime.minute.toString().padLeft(2, '0')}분';
  return formattedTime;
}

String SMScontentString(int waitingNumber, String storeName, String deadlineTime){
  String result = "안녕하세요~! $waitingNumber번 고객님! $storeName에 입장하실 시간이에요! $deadlineTime까지 내점해주세요~!";
  return result;
}


class WaitingProviderLegacy {
    // void subscribeToCallGuest(BuildContext context, int storeCode) {
  //   print('<subscribeToCallGuest> 구독 요청 수신');
  //   if (subscriptionInfo[1] != null) {
  //     // unSubscribeToCallGuest();
  //     // 중복구독을 막기위한 장치임.
  //     print('이미 <CallGuest>를 구독중입니다.');
  //   } else {
  //     print('<subscribeToCallGuest>의 구독을 시작했습니다.');
  //     subscriptionInfo[1] = _client?.subscribe(
  //         destination: '/topic/admin/StoreAdmin/userCall/$storeCode',
  //         callback: (StompFrame frame) {
  //           callGuestCallBack(frame, context);
  //         });
  //   }
  // }

  // void callGuestCallBack(StompFrame frame, BuildContext context) {
  //   print('<CallGuest> 데이터 수신');
  //   print(frame.body.toString());
  //   Map<String, dynamic> responseData = json.decode(frame.body!);
  //   CallWaitingTeam callGuestResponse = CallWaitingTeam.fromJson(responseData);
  //   // {"storeCode":1,"waitingTeam":1,"entryTime":"2024-03-28T23:04:18.3394633"}
  //   String formattedTime = extractEntryTime(callGuestResponse.entryTime);

  //   WaitingData? newState = state;

  //   // WaitingTeam의 entryTime을 업데이트
  //   newState!.teamInfoList.forEach((waitingTeam) {
  //     if (waitingTeam.waitingNumber == callGuestResponse.waitingTeam) {
  //       waitingTeam.entryTime = DateTime.parse(callGuestResponse.entryTime);
  //     }
  //   });

  //   updateState(newState);

  //   showDialog(
  //       context: context,
  //       builder: (context) {
  //         return AlertDialog(
  //             title: Text('손님 호출'),
  //             content: (Text(
  //                 '호출한 손님번호 : ${callGuestResponse.waitingTeam}\n입장마감시간 : $formattedTime')),
  //             actions: <Widget>[
  //               TextButton(
  //                 onPressed: () {
  //                   Navigator.of(context).pop();
  //                 },
  //                 child: Text('OK'),
  //               ),
  //             ]);
  //       });
  // }

  // void sendCallRequest(BuildContext context, int waitingNumber, int storeCode,
  //     int minutesToAdd) {
  //   print("<CallGuest> 손님 호출 - WaitingNumber $waitingNumber");
  //   _client?.send(
  //       destination: '/app/admin/StoreAdmin/userCall/$storeCode',
  //       body: json.encode({
  //         "storeCode": storeCode,
  //         "waitingTeam": waitingNumber,
  //         "minutesToAdd": minutesToAdd,
  //       }));
  // }

  // void subscribeToNoshowData(BuildContext context, int storeCode) {
  //   print('<NoShow> 구독요청 수신.');
  //   if (subscriptionInfo[0] != null) {
  //     // Do nothing
  //     print('이미 <NoShow>를 구독중입니다.');
  //   } else {
  //     subscriptionInfo[2] = _client?.subscribe(
  //         destination: '/topic/admin/StoreAdmin/noShow/$storeCode',
  //         callback: (StompFrame frame) {
  //           print('<NoShow> 메세지 수신. 다음은 수신된 메세지입니다.');
  //           print(frame.body!.toString());
  //           Map<bool, dynamic> responseData = json.decode(frame.body!);
  //           bool status = responseData['success'];
  //           showDialog(
  //             context: context,
  //             builder: (context) {
  //               return AlertDialog(
  //                 title: Text('손님 호출'),
  //                 content: Text(
  //                   status ? '성공적으로 노쇼처리하였습니다.' : '오류가 발생하였습니다.',
  //                 ),
  //                 actions: <Widget>[
  //                   TextButton(
  //                     onPressed: () {
  //                       Navigator.of(context).pop();
  //                     },
  //                     child: Text('확인'),
  //                   ),
  //                 ],
  //               );
  //             },
  //           );
  //         });
  //   }
  // }

  // void sendNoShowMessage(int storeCode, int noShowUserWaitingNumber) {
  //   print('노쇼유저 정보 송신 : $noShowUserWaitingNumber');
  //   _client?.send(
  //       destination: '/app/admin/StoreAdmin/noShow/$storeCode',
  //       body: json.encode({
  //         "storeCode": storeCode,
  //         "noShowUserCode": noShowUserWaitingNumber,
  //       }));
  // }

}