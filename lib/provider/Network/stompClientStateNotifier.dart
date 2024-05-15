import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/presenter/Widget/alertDialog.dart';
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
  DONE,
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
    print("클라이언트 configure [StompClientStateNotifier]");
    final streamController = StreamController<StompStatus>.broadcast();

    if (state != null) {
      print('이미 ConfigureClient가 실행되었기 때문에 아무것도 실행하지 않습니다.. [StompClientStateNotifier]');
      // 이미 configureClient가 실행되었을 경우 재설정 하지 않음
      return streamController.stream;
    } else {
      print('웹소켓 연결 요청 url -> ${WebSocketService.url} [StompClientStateNotifier]');
      client = StompClient(
        config: StompConfig(
          url: WebSocketService.url,
          onConnect: (StompFrame frame) {
            onConnectCallback(frame);
            ref.read(stompState.notifier).state = StompStatus.CONNECTED;
            streamController.add(StompStatus.CONNECTED);
          },
          onWebSocketError: (dynamic error) {
            print("웹소켓 에러: $error [StompClientStateNotifier]");
            // 연결 실패 시 0.5초 후 재시도
            ref.read(stompState.notifier).state = StompStatus.ERROR;
            streamController.add(StompStatus.ERROR);
            Future.delayed(Duration(milliseconds: 1000), () {
              client.activate();
            });
          },
          onDisconnect: (_) {
            print('웹소켓 연결 끊어짐(onDisconnect) [StompClientStateNotifier]');
            // 연결 끊김 시 재시도 로직
            ref.read(stompState.notifier).state = StompStatus.DISCONNECTED;
            streamController.add(StompStatus.DISCONNECTED);
            Future.delayed(Duration(milliseconds: 1000), () {
              client.activate();
            });
          },
          onStompError: (p0) {
            print("스텀프 에러(onStompError): $p0 [StompClientStateNotifier]");
            if (p0.body!.contains("Connection timed out")){
              print('서버가 바쁜것 같습니다.. [StompClientStateNotifier]');
            }
            ref.read(stompState.notifier).state = StompStatus.ERROR;
            streamController.add(StompStatus.ERROR);
            // 연결 실패 시 재시도 로직
            Future.delayed(Duration(milliseconds: 1000), () {
              client.activate();
            });
          },
          onDebugMessage: (p0) {
            print("디버그 메세지: $p0");
          },
          onWebSocketDone: () {
            ref.read(stompState.notifier).state = StompStatus.DISCONNECTED;
            // streamController.close();
            print("웹소켓 끊김 onWebSocketDone [StompClientStateNotifier]");
            // 연결 끊김 시 재시도 로직
            state = null;
            streamController.close();
            print('웹소켓 꺼짐... [StompClientStateNotifier]');
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
    print("스텀프 STOMP connected [StompClientStateNotifier]");
    ref.read(waitingProvider.notifier).setClient(client);
    print('웨이팅데이터 스텀프 : ${client.toString()} [StompClientStateNotifier]');
    ref.read(tableProvider.notifier).setClient(client);
    print('테이블데이터 스텀프 : ${client.toString()} [StompClientStateNotifier]');
    // 필요한 초기화 수행
    // 예를 들어, 여기서 다시 구독 로직을 실행
  }

  void reconnect() {
    print("reconnect [StompClientStateNotifier]");
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



// class StompClientStateNotifier extends StateNotifier<StompClient?> {
//   final Ref ref;
//   late StompClient client;
//   Timer? retryTimer;
//   int retryAttempts = 0;
//   final int maxRetryAttempts = 5;
//   final StreamController<StompStatus> streamController = StreamController<StompStatus>.broadcast();

//   StompClientStateNotifier(this.ref) : super(null) {
//     configureClient();
//   }

//     void reconnect() {
//     print("[StompClientStateNotifier] trying reconnect");
//     // 재시도 시, 구독 로직을 다시 실행
//     if (ref
//         .read(errorStateNotifierProvider.notifier)
//         .state
//         .contains(Error.network)) {
//       return;
//     }
//     state?.activate();
//     // ~.reconnet
//     ref.read(stompState.notifier).state = StompStatus.CONNECTED;
//   }

//   Stream<StompStatus> configureClient() {
//     print("클라이언트 configure");
//     if (state != null) {
//       return streamController.stream;
//     } else {
//       print('웹소켓 연결 요청 url -> ${WebSocketService.url}');
//       client = StompClient(
//         config: StompConfig(
//           url: WebSocketService.url,
//           onConnect: (StompFrame frame) {
//             onConnectCallback(frame);
//             ref.read(stompState.notifier).state = StompStatus.CONNECTED;
//             streamController.add(StompStatus.CONNECTED);
//             retryAttempts = 0;
//           },
//           onWebSocketError: handleConnectionError,
//           onDisconnect: handleConnectionError,
//           onStompError: handleConnectionError,
//           onDebugMessage: (p0) {
//             print("디버그 메세지: $p0");
//           },
//           onWebSocketDone: () {
//             print("웹소켓 연결 끊어짐.");
//             ref.read(stompState.notifier).state = StompStatus.DISCONNECTED;
//             streamController.add(StompStatus.DISCONNECTED);
//             disconnect();  // 연결이 끊어졌으므로 정리 작업을 수행
//           },
//         ),
//       );

//       Future.delayed(Duration(milliseconds: 100), () {
//         client.activate();
//         state = client;
//       });
//     }
//     return streamController.stream;
//   }

//   void handleConnectionError(dynamic error) {
//     print("웹소켓 에러 또는 연결 끊김: $error");
//     ref.read(stompState.notifier).state = StompStatus.ERROR;
//     streamController.add(StompStatus.ERROR);

//     if (retryAttempts < maxRetryAttempts) {
//       if (retryTimer != null && retryTimer!.isActive) {
//         retryTimer!.cancel();
//       }
//       retryTimer = Timer(Duration(seconds: 1), () {
//         client.activate();
//       });
//       retryAttempts++;
//     } else {
//       print("최대 연결 재시도 횟수 초과");
//       streamController.add(StompStatus.ERROR);
//       streamController.close(); // 최대 재시도 횟수 초과 시 스트림 종료
//     }
//   }

//   void onConnectCallback(StompFrame connectFrame) {
//     print("STOMP connected");
//     ref.read(waitingProvider.notifier).setClient(client);
//     ref.read(tableProvider.notifier).setClient(client);
//   }

//   Future<void> disconnect() async {
//     client.deactivate();
//     retryTimer?.cancel();
//     streamController.close();
//   }

//   @override
//   void dispose() {
//     disconnect();
//     super.dispose();
//   }
// }