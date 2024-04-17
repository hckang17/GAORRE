import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/Model/guest_data_model.dart';
import 'package:orre_manager/Model/restaurant_table_model.dart';

import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

final tableProvider = StateNotifierProvider<RestaurantTableNotifier, RestaurantTable?>((ref) {
  return RestaurantTableNotifier(); // 초기상태 null.
});

class RestaurantTableNotifier extends StateNotifier<RestaurantTable?> {
  StompClient? _client; // StompClient 인스턴스 저장할 내부 변수
  RestaurantTableNotifier() : super(null);
  List<dynamic> subscriptionInfo = [null, null, null];
  /*
    subscriptionInfo[0] : 테이블 상태 구독 정보
    subscriptionInfo[1] : 테이블 언락 구독 정보
    subscriptionInfo[2] : 테이블 락 구독 정보
  */

  void setClient(StompClient client) {
    print("<TableProvider> 스텀프 연결 설정");
    _client = client; // 내부변수에 stompClient추가.
  }

  void updateState(RestaurantTable newState) {
    state = newState;
  }

  /* subscribe 관련 코드 */
  void subscribeToTableData(int storeCode) {
    print('<TableData> 구독 요청 수신.');
    if(subscriptionInfo[0] != null){
      // Do Nothing
      print('이미 <TableData>를 구독중입니다.');
    } else {
      subscriptionInfo[0] = _client?.subscribe(
        destination: '/topic/admin/StoreAdmin/available/$storeCode',
        callback: (StompFrame frame) {
          print('<TableStatus> 상태 갱신.');
          print(frame.body);
          List<dynamic> responseData = json.decode(frame.body!);
          RestaurantTable tableStatus = RestaurantTable.fromJson(responseData as List);
          updateState(tableStatus);
        }
      );
    }
  }

  void subscribeToUnlockTableData(int storeCode) {
    print('<UnlockTableData> 구독 요청 수신.');
    if(subscriptionInfo[1] != null){
      // Do Nothing
      print('이미 <UnlockTableData>를 구독중입니다.');
    } else {
      subscriptionInfo[1] = _client?.subscribe(
        destination: '/topic/admin/table/unlock/$storeCode',
        callback: (StompFrame frame) {
          print('<UnlockTableData> 메세지 수신.');
          print(frame!.body.toString());
          Map<String, dynamic> responseData = json.decode(frame.body!);

          // Check if 'waitingNumber' exists in the response data
          if (responseData['success'] == true) {
            Guest seatedGuest = Guest(
              waitingNumber: responseData['waitingNumber'],
              userToken: responseData['jwtUser'],
              tableNumber: responseData['tableNumber'],
              storeCode: responseData['storeCode'],
            );
            print('테이블의 손님정보를 업데이트합니다.');
            // Update the guestInfo of the corresponding seat
            updateSeatWithGuest(seatedGuest);
          } else {
            print('Waiting number not found in response data.');
          }
        }
      );
    }
  }

  // Update guestInfo of the corresponding seat
  void updateSeatWithGuest(Guest guest) {
    // Find the index of the seat with matching tableNumber
    int seatIndex = state?.table.indexWhere((seat) => seat.tableNumber == guest.tableNumber) ?? -1;
    
    if (seatIndex != -1) {
      // Create a copy of the seat at the found index
      Seat updatedSeat = state!.table[seatIndex];
      // Update guestInfo
      updatedSeat.guestInfo = guest;
      // Replace the original seat with the updated seat
      state!.table[seatIndex] = updatedSeat;
      // Notify listeners about the state change
      updateState(RestaurantTable(table: state!.table));
    } else {
      print('Seat with table number ${guest.tableNumber} not found.');
    }
  }




  void subscribeToLockTableData(int storeCode) {
    print('<LockTableData> 구독 요청 수신.');
    if(subscriptionInfo[2] != null){
      // Do Nothing
      print('이미 <LockTableData>를 구독중입니다.');
    } else {
      subscriptionInfo[2] = _client?.subscribe(
        destination: '/topic/admin/table/lock/$storeCode',
        callback: (StompFrame frame) {
          print('<LockTableData> 메세지 수신.');
          print(frame!.body.toString());
          Map<String, dynamic> responseData = json.decode(frame.body!);
          if(responseData['success'] == true){
            int tableNumber = responseData['tableNumber'];
            print('$tableNumber번 테이블을 잠금처리하였습니다.');
            state!.table[tableNumber].guestInfo = null;
          }
        }
      );
    }
  }

  /*
  {
  "success": true,
  "jwtUser": "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIwMTA4NjAyMjM0MSIsInJvbGUiOiJ1c2VyIiwiaWF0IjoxNzEyNDE2MzY4LCJleHAiOjE3MTI1MDI3Njh9.c9xCpO-2nXA1n4BIDy1yx-C0FjmWGhdtTlGhtMEhlckkYMDU1yrG6ZIUBCxBALl9zStLHV7VymrKHjXhBYqYPw",
  "storeCode": 1,
  "tableNumber": 1,
  "waitingNumber": 3
  } 

  {
  "success": true,
  "storeCode": 1,
  "tableNumber": 1
  } 
  */
  void sendUnlockRequest(int storeCode, int tableNumber, int waitingNumber, String jwtAdmin) {
    print('<Unlock Request> 송신 ');
    _client?.send(
      destination: '/app/admin/table/unlock/$storeCode',
      body: json.encode({
        "jwtAdmin" : jwtAdmin,
        "storeCode" : storeCode,
        "tableNumber" : tableNumber,
        "waitingNumber" : waitingNumber
      })
    );
  }

  void sendLockRequest(int storeCode, int tableNumber, String jwtAdmin) {
    print('<Lock Request> 송신');
    _client?.send(
      destination: '/app/admin/table/lock/$storeCode',
      body: json.encode({
        "jwtAdmin": jwtAdmin,
        "storeCode": storeCode,
        "tableNumber": tableNumber
      })
    );
  }


  /* send 관련 코드 */
  void sendStoreCode(int storeCode){
    print('<TableData> 데이터 송신.');
    _client?.send(
      destination: '/app/admin/StoreAdmin/available/$storeCode',
      body: json.encode({
        "storeCode" : storeCode
      })
    );
  }

}