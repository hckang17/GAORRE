import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    subscriptionInfo[0] : ~구독 정보
  */

  void setClient(StompClient client) {
    print("<TableProvider> 스텀프 연결 설정");
    _client = client; // 내부변수에 stompClient추가.
  }

  void updateState(RestaurantTable newState) {
    state = newState;
  }

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