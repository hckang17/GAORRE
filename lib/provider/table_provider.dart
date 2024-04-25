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
    print('update Table State 실행');
    if(state == null) {
      print('TableData가 null이므로, 그대로 newState적용');
      state = newState;
    } else {
      RestaurantTable currentState = state!;
      List<Seat> currentTableList = currentState.table;
      if(currentTableList.length == newState.table.length){
        print('Seat객체 하나하나 변경..');
        for (var newSeat in newState.table) {
          var existingSeatIndex = currentTableList.indexWhere((seat) => seat.tableNumber == newSeat.tableNumber);
          if(existingSeatIndex != -1) {
            currentTableList[existingSeatIndex] = Seat(
              tableNumber: newSeat.tableNumber,
              maxPersonPerTable: newSeat.maxPersonPerTable,
              tableStatus: newSeat.tableStatus,
              guestInfo: currentTableList[existingSeatIndex].guestInfo ?? newSeat.guestInfo
            );
          } else {
            currentTableList.add(newSeat);
          }
        }
      } else if(currentTableList.length > newState.table.length) {
        print('Seat객체 삭제..');
        List<int> deletedSeatIndexes = [];
        for(int i=0; i < currentTableList.length; i++) {
          var existingSeatIndex = newState.table.indexWhere((seat) => seat.tableNumber == currentTableList[i].tableNumber);
          if(existingSeatIndex == -1){
            deletedSeatIndexes.add(i);
          }
        }
        //삭제할 항목을 List에서 제거~
        for(int i = deletedSeatIndexes.length-1; i>=0; i--){
          currentTableList.removeAt(deletedSeatIndexes[i]);
        }
      } else {
        //테이블이 추가되었을 때
        for(int i=0; i < newState.table.length; i++) {
          var existingSeatIndex = currentTableList.indexWhere((seat) => seat.tableNumber == newState.table[i].tableNumber);
          if(existingSeatIndex == -1){
            currentTableList.add(newState.table[i]);
          }
        }
      }
      state = RestaurantTable(table:currentTableList);
    }

    // state = newState;
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
    RestaurantTable? currentTable = state;
    List<Seat> currentSeats = currentTable!.table;
    currentSeats[seatIndex].guestInfo = guest;
    currentSeats[seatIndex].tableStatus = 1;
    RestaurantTable target = RestaurantTable(table: currentSeats);
    updateState(target);

    // if (seatIndex != -1) {
    //   // Create a copy of the seat at the found index
    //   Seat updatedSeat = state!.table[seatIndex];
    //   // Update guestInfo
    //   updatedSeat.guestInfo = guest;
    //   // Replace the original seat with the updated seat
    //   state!.table[seatIndex] = updatedSeat;
    //   // Notify listeners about the state change
    //   updateState(RestaurantTable(table: state!.table));
    // } else {
    //   print('Seat with table number ${guest.tableNumber} not found.');
    // }

    
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
            print('테이블의 손님정보를 업데이트합니다.');
            // Update the guestInfo of the corresponding seat
            RestaurantTable? currentState = state;
            List<Seat> currentSeats = currentState!.table;
            int targetSeat = currentSeats.indexWhere((seat) => tableNumber == seat.tableNumber);
            if(targetSeat != -1){
              currentSeats[targetSeat].guestInfo = null;
              currentSeats[targetSeat].tableStatus = 0;
            }
            updateState(
              RestaurantTable(table: currentSeats)
            );
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