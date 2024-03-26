// stomp_client_provider.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class StoreInfo {
  final int storeCode;
  final String storeName;
  final String address;
  final double distance;
  final double latitude;
  final double longitude;

  StoreInfo({
    required this.storeCode,
    required this.storeName,
    required this.address,
    required this.distance,
    required this.latitude,
    required this.longitude,
  });

  factory StoreInfo.fromJson(Map<String, dynamic> json) {
    return StoreInfo(
      storeCode: json['storeCode'],
      storeName: json['storeName'],
      address: json['address'],
      distance: json['distance'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}

final stompClientProvider = FutureProvider<StompClient>((ref) async {
  final completer = Completer<StompClient>();
  late StompClient client;

  client = StompClient(
    config: StompConfig(
      url: 'ws://192.168.1.214:8080/ws',
      onConnect: (StompFrame frame) {
        print("connected");
        // 필요한 초기화 수행, 여기서 client는 이미 정의되어 있으므로 사용 가능합니다.
        ref.read(storeInfoListNotifierProvider.notifier).setClient(client);
        completer.complete(client);
      },
      beforeConnect: () async {
        print('Connecting to websocket...');
      },
      onWebSocketError: (dynamic error) {
        print(error.toString());
        completer.completeError(error);
      },
    ),
  );

  client.activate();
  return completer.future; // onConnect에서 complete가 호출될 때까지 대기합니다.
});

final storeInfoListNotifierProvider =
    StateNotifierProvider<StoreInfoListNotifier, List<StoreInfo>>((ref) {
  return StoreInfoListNotifier([]);
});

class StoreInfoListNotifier extends StateNotifier<List<StoreInfo>> {
  StoreInfoListNotifier(List<StoreInfo?> state) : super([]);

  void setClient(StompClient client) {
    client.subscribe(
        destination: '/topic/user/storeList/nearestStores',
        callback: (frame) {
          if (frame.body != null) {
            List<dynamic> result = json.decode(frame.body!);
            List<StoreInfo> newList =
                result.map((item) => StoreInfo.fromJson(item)).toList();
            print(newList);
            state = newList;
          }
        });
    client.send(
      destination: '/app/user/storeList/nearestStores',
      // 추후 위치 정보를 받아와서 사용할 수 있도록 수정
      body: json.encode({
        "latitude": "32.1",
        "longitude": "127",
      }),
    );
  }

  void removeStoreInfo(String storeCode) {
    state = state.where((info) => info.storeCode != storeCode).toList();
  }
}
