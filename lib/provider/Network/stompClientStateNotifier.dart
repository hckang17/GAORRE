import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/provider/Data/tableDataProvider.dart';
import 'package:orre_manager/provider/Data/waitingDataProvider.dart';
import 'package:orre_manager/provider/errorStateNotifier.dart';
import 'package:orre_manager/services/websocket_services.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

enum StompStatus {
  CONNECTED,
  DISCONNECTED,
  ERROR,
}

final stompState = StateProvider<StompStatus>((ref) {
  return StompStatus.DISCONNECTED;
});

final stompClientStateNotifierProvider =
    StateNotifierProvider<StompClientStateNotifier, StompClient?>((ref) {
  return StompClientStateNotifier(ref);
});

class StompClientStateNotifier extends StateNotifier<StompClient?> {
  final Ref ref;
  late StompClient client;
  StompClientStateNotifier(this.ref) : super(null) {}

  Stream<StompStatus> configureClient() {
    print("클라이언트 configure ");
    final streamController = StreamController<StompStatus>.broadcast();

    if (state != null) {
      // 이미 configureClient가 실행되었을 경우 재설정 하지 않음
      return streamController.stream;
    } else {
      print('웹소켓 연결 요청 url -> ${WebSocketService.url}');
      client = StompClient(
        config: StompConfig(
          url: WebSocketService.url,
          onConnect: (StompFrame frame) {
            onConnectCallback(frame);
            ref.read(stompState.notifier).state = StompStatus.CONNECTED;
            streamController.add(StompStatus.CONNECTED);
          },
          onWebSocketError: (dynamic error) {
            print("websocket error: $error");
            // 연결 실패 시 0.5초 후 재시도
            ref.read(stompState.notifier).state = StompStatus.ERROR;
            streamController.add(StompStatus.ERROR);
            Future.delayed(Duration(milliseconds: 500), () {
              client.activate();
            });
          },
          onDisconnect: (_) {
            print('disconnected');
            // 연결 끊김 시 재시도 로직

            ref.read(stompState.notifier).state = StompStatus.DISCONNECTED;
            streamController.add(StompStatus.DISCONNECTED);
            Future.delayed(Duration(milliseconds: 500), () {
              client.activate();
            });
          },
          onStompError: (p0) {
            print("stomp error: $p0");
            ref.read(stompState.notifier).state = StompStatus.ERROR;
            streamController.add(StompStatus.ERROR);
            // 연결 실패 시 재시도 로직
            Future.delayed(Duration(milliseconds: 500), () {
              client.activate();
            });
          },
          onDebugMessage: (p0) {
            print("debug message: $p0");
          },
          onWebSocketDone: () {
            ref.read(stompState.notifier).state = StompStatus.DISCONNECTED;
            streamController.close();
            print("websocket done");
            // 연결 끊김 시 재시도 로직
          },
        ),
      );

      Future.delayed(Duration(milliseconds: 100), () {
        client.activate();
        state = client;
      });
    }
    return streamController.stream;
  }

  void onConnectCallback(StompFrame connectFrame) {
    print("스텀프 STOMP connected");
    ref.read(waitingProvider.notifier).setClient(client);
    print('웨이팅데이터 스텀프 : ${client.toString()}');
    ref.read(tableProvider.notifier).setClient(client);
    // 필요한 초기화 수행
    // 예를 들어, 여기서 다시 구독 로직을 실행
  }

  void reconnect() {
    print("reconnected");
    // 재시도 시, 구독 로직을 다시 실행
    if (ref
        .read(errorStateNotifierProvider.notifier)
        .state
        .contains(Error.network)) {
      return;
    }
    state?.activate();
    // ~.reconnet
    ref.read(stompState.notifier).state = StompStatus.CONNECTED;
  }

  // Example method to disconnect from the STOMP server
  Future<void> disconnect() async {
    // Implement your disconnection logic here
    client.deactivate();
  }
}
