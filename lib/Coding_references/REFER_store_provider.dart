import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import '../Model/waiting_data_model.dart';

// WaitingInfo 객체를 관리하는 프로바이더를 정의합니다.
final waitingProvider =
    StateNotifierProvider<WaitingDataNotifier, WaitingData?>((ref) {
  return WaitingDataNotifier(); // 초기 상태를 null로 설정합니다.
});

// StateNotifier를 확장하여 WaitingInfo 객체를 관리하는 클래스를 정의합니다.
class WaitingDataNotifier extends StateNotifier<WaitingData?> {
  StompClient? _client; // StompClient 인스턴스를 저장할 내부 변수 추가
  WaitingDataNotifier() : super(null);
  // dynamic nowSubscribeToCallGuest;
  List<dynamic> subscriptionInfo = [null, null, null];
  /* 
    subscriptionInfo[0] : WaitingData 구독정보
    subscriptionInfo[1] : CallGuest 구독정보
    subscriptionInfo[2] : NoShow 구독정보
  */

  // StompClient 인스턴스를 설정하는 메소드
  void setClient(StompClient client) {
    print("<WaitingProvider> 스텀프 연결 설정");
    _client = client; // 내부 변수에 StompClient 인스턴스 저장
  }

  void updateState(WaitingData newState){
    state = newState;
  }

  void subscribeToWaitingData(int storeCode) {
    print('<WaitingData> 구독요청 수신.');
    if(subscriptionInfo[0] != null){
      // Do nothing
      print('이미 <WaitingData>를 구독중입니다.');
    } else {
      subscriptionInfo[0] = _client?.subscribe(
        destination: '/topic/admin/dynamicStoreWaitingInfo/$storeCode',
        callback: (StompFrame frame) {
          print('<WaitingData> 메세지 수신. 다음은 수신된 메세지입니다.');
          if (frame.body != null) {
            print(frame.body.toString());
            Map<String, dynamic> responseData = json.decode(frame.body!);
            WaitingData waitingResponse = WaitingData.fromJson(responseData);
            // StateNotifier를 통해 상태를 업데이트합니다.
            updateState(waitingResponse);
          }
        },
      );
    }
  }

  void subscribeToNoshowData(BuildContext context, int storeCode){
    print('<NoShow> 구독요청 수신.');
    if(subscriptionInfo[0] != null){
      // Do nothing
      print('이미 <NoShow>를 구독중입니다.');
    } else {
      subscriptionInfo[2] = _client?.subscribe(
        destination: '/topic/admin/StoreAdmin/noShow/$storeCode',
        callback: (StompFrame frame) {
          print('<NoShow> 메세지 수신. 다음은 수신된 메세지입니다.');
          Map<bool, dynamic> responseData = json.decode(frame.body!);
          bool status = responseData['success'];
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('손님 호출'),
                content: Text(
                  status ? '성공적으로 노쇼처리하였습니다.' : '오류가 발생하였습니다.',
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('확인'),
                  ),
                ],
              );
            },
          );
        }
      );
    }
  }

  void sendNoShowMessage(int storeCode, int noShowUserWaitingNumber) {
    print('노쇼유저 정보 송신 : $noShowUserWaitingNumber');
    _client?.send(
      destination: '/app/admin/StoreAdmin/noShow/$storeCode',
      body: json.encode({
        "storeCode" : storeCode,
        "noShowUserCode" : noShowUserWaitingNumber,
      })
    );
  }

  // {"storeCode":"1","noShowUserCode":"2"}

  void sendWaitingData(int storeCode){
    print('<WaitingData> 정보 요청');
    _client?.send(
      destination: '/app/admin/dynamicStoreWaitingInfo/$storeCode',
      body: json.encode({
        "storeCode": storeCode,
      }),
    );
  }

  void subscribeToCallGuest(BuildContext context, int storeCode){
    print('<CallGuest> 구독 요청 수신');
    if(subscriptionInfo[1] != null){
      // unSubscribeToCallGuest();
      // 중복구독을 막기위한 장치임.
      print('이미 <CallGuest>를 구독중입니다.');
    } else {
      print('<subscribeToCallGuest>의 구독을 시작했습니다.');
      subscriptionInfo[1] = _client?.subscribe(
        destination: '/topic/admin/StoreAdmin/userCall/$storeCode',
        callback: (StompFrame frame){
          print('something read from server');
          print(frame.body.toString());
          Map<String, dynamic> responseData = json.decode(frame.body!);
          CallWaitingTeam callGuestResponse = CallWaitingTeam.fromJson(responseData);
          // {"storeCode":1,"waitingTeam":1,"entryTime":"2024-03-28T23:04:18.3394633"}
          String formattedTime = extractEntryTime(callGuestResponse.entryTime);
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('손님 호출'),
                content: (
                  Text('호출한 손님번호 : ${callGuestResponse.waitingTeam}\n입장마감시간 : $formattedTime')
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ]
              );
            }
          );
        }
      );
    }
  }

  int testFunction(int storeCode){
    return 777;
  }

  void sendCallRequest(
      BuildContext context,
      int waitingNumber,
      int storeCode,
      int minutesToAdd
      ) {
    print("<CallGuest> 손님 호출 - WaitingNumber $waitingNumber");
    _client?.send(
      destination: '/app/admin/StoreAdmin/userCall/$storeCode',
      body: json.encode({
        "storeCode": storeCode,
        "waitingTeam": waitingNumber,
        "minutesToAdd" : minutesToAdd, 
      })
    );
  }

  void unSubscribe(int index){
    // index는 어떤것을 구독해제 할 지 결정하기 위한 변수임.
    // print("<callGuest> is now unsubscribed");
    subscriptionInfo[index](unsubscribeHeaders: null);
  }

  @override
  void dispose() {
    _client?.deactivate();
    super.dispose();
  }
}


// extractTime method
String extractEntryTime(String message) {
  DateTime parsedTime = DateTime.parse(message);
  // HH:MM:SS 형식으로 변환
  String formattedTime = '${parsedTime.hour.toString().padLeft(2, '0')}:${parsedTime.minute.toString().padLeft(2, '0')}:${parsedTime.second.toString().padLeft(2, '0')}';
  return formattedTime;
}