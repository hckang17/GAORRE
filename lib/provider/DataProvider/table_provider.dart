import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/Model/guest_data_model.dart';
import 'package:orre_manager/Model/orderList_data.dart';
import 'package:orre_manager/Model/restaurant_table_model.dart';
import 'package:http/http.dart' as http;
import 'package:orre_manager/services/http_service.dart';

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
              guestInfo: currentTableList[existingSeatIndex].guestInfo ?? newSeat.guestInfo,
              orderInfo: currentTableList[existingSeatIndex].orderInfo ?? newSeat.orderInfo,
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
        print("신규테이블 추가");
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

  FutureOr<bool> requestTableOrderList(int storeCode, int tableNumber) async {
    try {
      final jsonBody = json.encode({
        "storeCode": storeCode,
        "tableNumber": tableNumber
      });
      final response = await HttpsService.postRequest('/StoreAdmin/menu/order/check', jsonBody);
      if(response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(utf8.decode(response.bodyBytes));
        print('수신내역 : ${responseBody.toString()}');
        OrderList orderList = OrderList.fromJson(responseBody);
        updateSeatWithOrderList(orderList);
        print('주문정보 업데이트를 진행합니다');
        return true;
      } else {
        print('주문정보 수신 실패');
        return false;
      }
    } catch (error) {
      print('error : $error');
      return false;
    }
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
  }

  void updateSeatWithOrderList(OrderList orderList) {
    // Find the index of the seat with matching tableNumber
    int seatIndex = state?.table.indexWhere((seat) => seat.tableNumber == orderList.tableNumber) ?? -1;
    RestaurantTable? currentTable = state;
    List<Seat> currentSeats = currentTable!.table;
    currentSeats[seatIndex].orderInfo = orderList;
    RestaurantTable target = RestaurantTable(table: currentSeats);
    updateState(target);
  }


//https://orre.store/api/admin/StoreAdmin/available

  Future<void> requestAddNewTable(int storeCode, int tableNumber, int personNumber, String jwtToken) async {
    var existingTableNumberIndex = state!.table.indexWhere((seat) => seat.tableNumber == tableNumber);
    // tableNumber가 existing하면 아무런 일도 일어나지 않음.
    if(existingTableNumberIndex != -1) {
      print('테이블이 이미 존재합니다');
      // 즉시 종료
      return;
    } else {
      print('Adding new table');
      final jsonBody = json.encode({
        'storeCode' : storeCode,
        'storeAddTableNumber' : tableNumber,
        'personNumber': personNumber,
        'jwtAdmin': jwtToken,
      });
      // var headers = { 'Content-Type': 'application/json; charset=UTF-8' };
      // // final response = await http.post(Uri.parse('https://orre.store/api/admin/StoreAdmin/table/add'), 
      // //   headers: headers, body: jsonBody);
      final response = await HttpsService.postRequest('/StoreAdmin/table/add', jsonBody);
      if(response.statusCode == 200) {
        final responseBody = json.decode(utf8.decode(response.bodyBytes));
        bool result = responseBody['success'];
        if(result == true){
          Seat newSeat = Seat(
            tableNumber: tableNumber,
            tableStatus: 0,
            maxPersonPerTable: personNumber
          );
          RestaurantTable? currentState = state;
          currentState!.table.add(newSeat);
          updateState(currentState);
        } else {
          print('테이블 생성에 오류가 발생했습니다');
        }
      } else {
        print('error occured.');
        print('다음은 response body');
        print(response.body);
      }
    }
  }

  Future<void> requestDeleteTable(int storeCode, int tableNumber, String jwtToken) async {
    var existingTableNumberIndex = state!.table.indexWhere((seat) => seat.tableNumber == tableNumber);
    // tableNumber가 existing하면 아무런 일도 일어나지 않음.
    if(existingTableNumberIndex == -1) {
      // 즉시 종료
      print('테이블번호가 존재하지 않습니다');
      return;
    } else {
      print('Delete table');
      final jsonBody = json.encode({
        'storeCode' : storeCode,
        'storeRemoveTableNumber' : tableNumber,
        'jwtAdmin': jwtToken,
      });
      // final response = await http.post()
      final response = await HttpsService.postRequest('/StoreAdmin/table/remove', jsonBody);
      if(response.statusCode == 200) {
        final responseBody = json.decode(utf8.decode(response.bodyBytes));
        bool result = responseBody['success'];
        if(result == true){
          RestaurantTable? currentTable = state;
          currentTable!.table.removeAt(existingTableNumberIndex);
          updateState(currentTable);
        } else {
          print('error occured.');
        }
      } else {
        print('에러발생');
        print(response.body.toString());
        print('HTTP response를 받지 못했습니다.');
      }
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
          print(frame.body.toString());
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