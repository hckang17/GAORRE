// // stomp_client_provider.dart
// import 'dart:async';

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:orre_manager/provider/Data/loginDataProvider.dart';
// import 'package:orre_manager/provider/Data/tableDataProvider.dart';
// import 'package:orre_manager/provider/Data/waitingDataProvider.dart';
// import 'package:orre_manager/services/websocket_services.dart';
// import 'package:stomp_dart_client/stomp.dart';
// import 'package:stomp_dart_client/stomp_config.dart';
// import 'package:stomp_dart_client/stomp_frame.dart';


// enum StompStatus {
//   CONNECTED,
//   DISCONNECTED,
//   ERROR,
//   DONE
// }

// final stompState = StateProvider<StompStatus>((ref) {
//   return StompStatus.DISCONNECTED;
// });

// final stompClientStreamProvider = StreamProvider<StompClient>((ref) {
//   final streamController = StreamController<StompClient>.broadcast();
//   late StompClient client;
//   Timer? reconnectTimer;

//   void reconnect() {
//     if (reconnectTimer != null && reconnectTimer!.isActive) {
//       reconnectTimer!.cancel();
//     }
//     reconnectTimer = Timer(Duration(seconds: 1), client.activate);
//   }

//   void connect() {
//     client = StompClient(
//       config: StompConfig(
//         url: WebSocketService.url,
//         onConnect: (StompFrame frame) {
//           print("스텀프 connected [StompClientStreamProvider]");
//           streamController.add(client);
//           ref.read(waitingProvider.notifier).setClient(client);
//           ref.read(tableProvider.notifier).setClient(client);
//           ref.read(stompState.notifier).state = StompStatus.CONNECTED;
//         },
//         onWebSocketError: (error) {
//           print("websocket error: $error [StompClientStreamProvider]");
//           ref.read(stompState.notifier).state = StompStatus.ERROR;
//           reconnect();
//         },
//         onDisconnect: (_) {
//           print('스텀프 disconnected [StompClientStreamProvider]');
//           ref.read(stompState.notifier).state = StompStatus.DISCONNECTED;
//           reconnect();
//         },
//         onStompError: (p0) {
//           print("스텀프 stomp error: $p0 [StompClientStreamProvider]");
//           ref.read(stompState.notifier).state = StompStatus.ERROR;
//           reconnect();
//         },
//         onWebSocketDone: () {
//           print("웹소켓 연결 끊어짐. [StompClientStreamProvider]");
//           ref.read(stompState.notifier).state = StompStatus.DONE;
//           reconnect();
//         },
//       ),
//     );

//     client.activate();
//   }

//   connect();

//   ref.onDispose(() {
//     streamController.close();
//     reconnectTimer?.cancel();
//   });

//   return streamController.stream;
// });
// // final stompClientStreamProvider = StreamProvider<StompClient>((ref) {
// //   // StreamController를 생성합니다. broadcast를 사용하여 여러 리스너에서 구독 가능하도록 합니다.
// //   final streamController = StreamController<StompClient>.broadcast();
// //   late StompClient client;
// //   bool reconnect = false;

// //   void connect() {
// //     // StompClient 구성
// //     client = StompClient(
// //       config: StompConfig(
// //         url: WebSocketService.url,
// //         onConnect: (StompFrame frame) {
// //           print("connected");

// //           // 필요한 초기화 수행
// //           // 예를 들어, 여기서 다시 구독 로직을 실행
// //           ref.read(waitingProvider.notifier).setClient(client);
// //           ref.read(tableProvider.notifier).setClient(client);
// //           ref.read(stompState.notifier).state = 'connected';

// //           // 재시도 시, 구독 로직을 다시 실행
// //           if (reconnect) {
// //             ref.read(waitingProvider.notifier).reconnect(ref.read(loginProvider.notifier).getLoginData().storeCode);
// //             ref.read(tableProvider.notifier).reconnect(ref.read(loginProvider.notifier).getLoginData().storeCode);
// //             reconnect = false;
// //             ref.read(stompState.notifier).state = 'reconnected';
// //           }

// //           // 스트림에 StompClient를 추가합니다.
// //           streamController.add(client);
// //         },
// //         onWebSocketError: (dynamic error) {
// //           print("websocket error: $error");
// //           // 연결 실패 시 재시도 로직
// //           reconnect = true;
// //           ref.read(stompState.notifier).state = 'error';
// //           Future.delayed(Duration(seconds: 1), client.activate); // 1초 후 재시도
// //         },
// //         onDisconnect: (_) {
// //           print('disconnected');
// //           // 연결 끊김 시 재시도 로직
// //           reconnect = true;
// //           ref.read(stompState.notifier).state = 'disconnected';
// //           Future.delayed(Duration(seconds: 1), client.activate); // 1초 후 재시도
// //         },
// //         onStompError: (p0) {
// //           print("stomp error: $p0");
// //           // 연결 실패 시 재시도 로직
// //           reconnect = true;
// //           ref.read(stompState.notifier).state = 'error';
// //           Future.delayed(Duration(seconds: 1), client.activate); // 1초 후 재시도
// //         },
// //         onDebugMessage: (p0) {
// //           print("debug message: $p0");
// //         },
// //         onWebSocketDone: () {
// //           print("웹소켓 연결 끊어짐.");
// //           // 연결 끊김 시 재시도 로직
// //           reconnect = true;
// //           ref.read(stompState.notifier).state = 'done';
// //         },
// //       ),
// //     );

// //     client.activate();
// //   }

// //   // 최초 연결 시도
// //   connect();

// //   return streamController.stream;
// // });
