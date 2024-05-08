import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/Model/waiting_data_model.dart';
import 'package:orre_manager/presenter/alertDialog.dart';
import 'package:orre_manager/services/http_service.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

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

  Future<void> requestUserCall(BuildContext context, int waitingNumber, int storeCode, int minutesToAdd) async {
    print('고객 호출 - waitingNumber $waitingNumber');
    final jsonBody = json.encode({
        "storeCode": storeCode,
        "waitingTeam": waitingNumber,
        "minutesToAdd": minutesToAdd,
    });
    final response = await HttpsService.postRequest('/userCall', jsonBody);
    if(response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(utf8.decode(response.bodyBytes));
      CallWaitingTeam callGuestResponse = CallWaitingTeam.fromJson(responseBody);
      if(callGuestResponse.storeCode == storeCode){
        //고객호출 성공
        String formattedTime = extractEntryTime(callGuestResponse.entryTime);
        WaitingData? currentState = state;
        // WaitingTeam의 entryTime을 업데이트
        currentState!.teamInfoList.forEach((waitingTeam) {
          if (waitingTeam.waitingNumber == callGuestResponse.waitingTeam) {
            waitingTeam.entryTime = DateTime.parse(callGuestResponse.entryTime);
          }
        });
        updateState(currentState);
        showAlertDialog(context, '$waitingNumber번 고객 호출', '입장 마감 시간 : $formattedTime', null);
      } else {
        // 고객호출 실패
        print('고객호출 실패');
        showAlertDialog(context, '$waitingNumber번 고객 호출', '고객호출 실패', null);
      }
    } else {
      // 에러발생.

    }
  }

  Future<void> requestUserDelete(BuildContext context, int storeCode, int noShowWaitingNumber) async {
    print('웨이팅유저 삭제 요청');
    final jsonBody = json.encode({
      "storeCode": storeCode,
      "noShowUserCode": noShowWaitingNumber,      
    });
    final response = await HttpsService.postRequest('/noShow', jsonBody);
    if(response.statusCode == 200){
      final responseBody = json.decode(utf8.decode(response.bodyBytes));
      if(responseBody['success'] == true){
        print('성공적으로 $noShowWaitingNumber번 손님을 웨이팅취소했습니다');
        showAlertDialog(context, '웨이팅 취소', '$noShowWaitingNumber번 손님 웨이팅해제 완료', null);
      } else {
        print('$noShowWaitingNumber번 손님 웨이팅취소를 실패했습니다.');
        showAlertDialog(context, '웨이팅 취소', '$noShowWaitingNumber번 손님 웨이팅해제 실패', null);
      }
    } else {
      //에러발생
      print('에러발생');
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

  void subscribeToWaitingData(int storeCode) {
    print('<WaitingData> 구독요청 수신.');
    if (subscriptionInfo[0] != null) {
      // Do nothing
      print('이미 <WaitingData>를 구독중입니다.');
    } else {
      subscriptionInfo[0] = _client?.subscribe(
        destination: '/topic/admin/dynamicStoreWaitingInfo/$storeCode',
        callback: (StompFrame frame) {
          waitingData_CallBack(frame);
        },
      );
    }
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
  String formattedTime =
      '${parsedTime.hour.toString().padLeft(2, '0')}:${parsedTime.minute.toString().padLeft(2, '0')}:${parsedTime.second.toString().padLeft(2, '0')}';
  return formattedTime;
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