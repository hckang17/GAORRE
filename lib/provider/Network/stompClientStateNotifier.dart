import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/presenter/Widget/AlertDialog.dart';
import 'package:orre_manager/provider/Data/tableDataProvider.dart';
import 'package:orre_manager/provider/Data/waitingDataProvider.dart';
import 'package:orre_manager/provider/errorStateNotifier.dart';
import 'package:orre_manager/services/websocket_services.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';


final stompErrorStack = StateProvider<int>((ref) => 0);

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
  late StompClient? client;
  StompClientStateNotifier(this.ref) : super(null) {}

  Stream<StompStatus> configureClient() {
    print("configureClient [stompClientStateNotifier - ConfigureClient]");
    final streamController = StreamController<StompStatus>.broadcast();

    if (state != null) {
      // 이미 configureClient가 실행되었을 경우 재설정 하지 않음
      print('이미 ConfigureClient가 실행되어 있습니다! [ConfigureClient]');
      return streamController.stream;
    } else {
      print('Configuration을 진행합니다... [main.dart]');
      client = StompClient(
        config: StompConfig(
          url: WebSocketService.url,
          onConnect: (StompFrame frame) {
            print('스텀프 OnConnect 콜백 호출! [main.dart]');
            // final firstBoot = ref.read(firstStompSetup.notifier).state;
            ref.read(stompState.notifier).state = StompStatus.CONNECTED;
            streamController.add(StompStatus.CONNECTED);
            onConnectCallback(frame);
          },
          onWebSocketError: (dynamic error) {
            print("websocket error: $error [StompClientStateNotifier]");
            ref.read(waitingProvider.notifier).setClient(null);
            state = null;
            streamController.add(reconnectionCallback(StompStatus.ERROR));
          },
          onDisconnect: (_) {
            print('disconnected [StompClientStateNotifier]');
            ref.read(waitingProvider.notifier).setClient(null);
            state = null;
            streamController.add(reconnectionCallback(StompStatus.ERROR));
          },
          onStompError: (p0) {
            print("stomp error: $p0 [StompClientStateNotifier]");
            state = null;
            streamController.add(reconnectionCallback(StompStatus.ERROR));
          },
          onWebSocketDone: () {
            ref.read(stompState.notifier).state = StompStatus.DISCONNECTED;
            print("websocket done [StompClientStateNotifier]");
            ref.read(waitingProvider.notifier).setClient(null);
            // ref.read(tableProvider.notifier).setClient(null); 아직은 안해도 됨.
            // 연결 끊김 시 재시도 로직
            // 여기에 만약 network off 로 인한 웹소켓끊어짐이라면? 대응해야할거같은데.
            streamController.add(reconnectionCallback(StompStatus.ERROR));
          },
          // heartbeatOutgoing: const Duration(seconds: 10), // 클라이언트에서 서버로 20초마다 heartbeat 보냄
          heartbeatIncoming: const Duration(seconds: 10), // 서버에서 클라이언트로 20초마다 heartbeat 수신 기대
        ),
      );

      Future.delayed(Duration(milliseconds: 500), () {
        state = client;
        client!.activate();
      });
    }
    return streamController.stream;
  }

  void onConnectCallback(StompFrame connectFrame) {
    print("웹소켓 연결 성공 [StompClientStateNotifier]");
    ref.read(stompErrorStack.notifier).state = 0;
    // 필요한 초기화 수행
    // 예를 들어, 여기서 다시 구독 로직을 실행
    ref.read(waitingProvider.notifier).setClient(client);
    // ref.read(tableProvider.notifier).setClient(client);

  }

  reconnectionCallback(StompStatus status) async {
    print("재연결 Callback [StompClientStateNotifier]");
    // 연결 상태 확인: 이미 연결된 상태면 재연결 로직 중단
    if (ref.read(stompState) == StompStatus.CONNECTED) {
      print("이미 연결된 상태입니다. 재연결 시도를 중단합니다.");
      return;
    }

    if (ref.read(errorStateNotifierProvider.notifier).state.contains(Error.network)) {
      return;
    }

    ref.read(stompState.notifier).state = status;
    await Future.delayed(Duration(milliseconds: 1000), () {
      print("웹소켓 재시도 [StompClientStateNotifier]");
      state = null;
      configureClient();
      // state?.activate();
      // ref.read(stompErrorStack.notifier).state++;
    });
  }

  Future<void> disconnect() async {
    client!.deactivate();
  }
}


class StompLegacy {
// enum StompStatus {
//   CONNECTED,
//   DISCONNECTED,
//   ERROR,
//   DONE,
// }

// final stompState = StateProvider<StompStatus>((ref) {
//   return StompStatus.DISCONNECTED;
// });

// final stompClientStateNotifierProvider =
//     StateNotifierProvider<StompClientStateNotifier, StompClient?>((ref) {
//   return StompClientStateNotifier(ref);
// });

// class StompClientStateNotifier extends StateNotifier<StompClient?> {
//   final Ref ref;
//   late StompClient client;
//   StompClientStateNotifier(this.ref) : super(null) {}

//   Stream<StompStatus> configureClient() {
//     print("클라이언트 configure [StompClientStateNotifier]");
//     final streamController = StreamController<StompStatus>.broadcast();

//     if (state != null) {
//       print('이미 ConfigureClient가 실행되었기 때문에 아무것도 실행하지 않습니다.. [StompClientStateNotifier]');
//       // 이미 configureClient가 실행되었을 경우 재설정 하지 않음
//       return streamController.stream;
//     } else {
//       print('웹소켓 연결 요청 url -> ${WebSocketService.url} [StompClientStateNotifier]');
//       client = StompClient(
//         config: StompConfig(
//           url: WebSocketService.url,
//           onConnect: (StompFrame frame) {
//             onConnectCallback(frame);
//             ref.read(stompState.notifier).state = StompStatus.CONNECTED;
//             streamController.add(StompStatus.CONNECTED);
//           },
//           onWebSocketError: (dynamic error) {
//             print("웹소켓 에러: $error [StompClientStateNotifier]");
//             // 연결 실패 시 0.5초 후 재시도
//             ref.read(stompState.notifier).state = StompStatus.ERROR;
//             streamController.add(StompStatus.ERROR);
//             Future.delayed(Duration(milliseconds: 1000), () {
//               client.activate();
//             });
//           },
//           onDisconnect: (_) {
//             print('웹소켓 연결 끊어짐(onDisconnect) [StompClientStateNotifier]');
//             // 연결 끊김 시 재시도 로직
//             ref.read(stompState.notifier).state = StompStatus.DISCONNECTED;
//             streamController.add(StompStatus.DISCONNECTED);
//             Future.delayed(Duration(milliseconds: 1000), () {
//               client.activate();
//             });
//           },
//           onStompError: (p0) {
//             print("스텀프 에러(onStompError): $p0 [StompClientStateNotifier]");
//             if (p0.body!.contains("Connection timed out")){
//               print('서버가 바쁜것 같습니다.. [StompClientStateNotifier]');
//             }
//             ref.read(stompState.notifier).state = StompStatus.ERROR;
//             streamController.add(StompStatus.ERROR);
//             // 연결 실패 시 재시도 로직
//             Future.delayed(Duration(milliseconds: 1000), () {
//               client.activate();
//             });
//           },
//           onDebugMessage: (p0) {
//             print("디버그 메세지: $p0");
//           },
//           onWebSocketDone: () {
//             ref.read(stompState.notifier).state = StompStatus.DISCONNECTED;
//             // streamController.close();
//             print("웹소켓 끊김 onWebSocketDone [StompClientStateNotifier]");
//             // 연결 끊김 시 재시도 로직
//             state = null;
//             streamController.close();
//             print('웹소켓 꺼짐... [StompClientStateNotifier]');
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

//   void onConnectCallback(StompFrame connectFrame) {
//     print("스텀프 STOMP connected [StompClientStateNotifier]");
//     ref.read(waitingProvider.notifier).setClient(client);
//     print('웨이팅데이터 스텀프 : ${client.toString()} [StompClientStateNotifier]');
//     ref.read(tableProvider.notifier).setClient(client);
//     print('테이블데이터 스텀프 : ${client.toString()} [StompClientStateNotifier]');
//     // 필요한 초기화 수행
//     // 예를 들어, 여기서 다시 구독 로직을 실행
//   }

//   void reconnect() {
//     print("reconnect [StompClientStateNotifier]");
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

//   // Example method to disconnect from the STOMP server
//   Future<void> disconnect() async {
//     // Implement your disconnection logic here
//     client.deactivate();
//   }
// }



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
}

