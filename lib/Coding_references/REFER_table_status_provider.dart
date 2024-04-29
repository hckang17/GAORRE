import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import '../Model/restaurant_table_model.dart';

final storeTableProvider =
    StateNotifierProvider<RestaurantTableNotifier, RestaurantTable?>((ref) {
  return RestaurantTableNotifier(); // 초기 상태를 null로 설정합니다.
});

class RestaurantTableNotifier extends StateNotifier<RestaurantTable> {
  RestaurantTableNotifier() : super(RestaurantTable(table: [])); // 초기 상태를 빈 테이블 목록으로 설정합니다.

  StompClient? _client; // StompClient 인스턴스를 저장할 내부 변수 추가
  List<dynamic> subscriptionInfo = [null];
  
  void setClient(StompClient client) {
    print("<storeTableProvider> 스텀프 연결 설정");
    _client = client; // 내부 변수에 StompClient 인스턴스 저장
  }

  void updateTableStatus(RestaurantTable newTableStatus) {
    state = newTableStatus;
  } // state를 변경하기 위한 메서드

  void subscribeToTable(int storeCode){
    print('<TableStatus> 정보 구독 요청 수신');
    if(subscriptionInfo[0] == null){
      print('<TableStatus> 구독 성공');
      subscriptionInfo[0] = _client?.subscribe(
        destination: '/topic/admin/StoreAdmin/available/$storeCode',
        callback: (StompFrame frame) {
          print('<TableStatus> 상태 갱신.');
          print(frame.body);
          Map<String, dynamic> responseData = json.decode(frame.body!);
          RestaurantTable tableStatus = RestaurantTable.fromJson(responseData as List);
          updateTableStatus(tableStatus);
        },
      );
    }
  }

  String getTableStatusInformation() {
    return state.toString();
  }

  void sendStoreCode(int storeCode){
    print('<TableStatus> 데이터 송신.');
    _client?.send(
      destination: '/app/admin/StoreAdmin/available/$storeCode',
      body: json.encode({
        "storeCode" : storeCode
      })
    );
  }

}


