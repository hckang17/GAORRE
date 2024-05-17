import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/provider/Network/connectivityStateNotifier.dart';
import 'package:orre_manager/provider/Network/stompClientStateNotifier.dart';
import 'package:orre_manager/provider/errorStateNotifier.dart';

// final websocketRefreshServiceProvider = Provider<WebsocketRefreshService>((ref) {
//   return WebsocketRefreshService(ref);
// });

// class WebsocketRefreshService {
//   final Ref ref;
//   // bool lastNetworkState = false;

//   WebsocketRefreshService(this.ref) {
//     ref.listen<bool>(networkStateNotifier, (prevState, newState) {
//       if (newState) { // newState가 true일때
//         if(ref.read(stompClientStateNotifierProvider) != null){
//         print('이미 STOMP Configure이 진행되어있습니다. [WebsocketRefreshService]');
//         }else{
//           print("네트워크 연결 감지됨. 웹소켓 재설정 시작... [WebsocketRefreshService]");
//           ref.read(stompClientStateNotifierProvider.notifier).configureClient().listen((event) {
//             print("Configure Client 발생 이벤트 : $event [WebsocketRefreshService]");
//             if (event == StompStatus.CONNECTED) {
//               print("웹소켓 연결됨..... [WebsocketRefreshService]");
//               ref.read(errorStateNotifierProvider.notifier).deleteError(Error.websocket);
//             } else {
//               print("웹소켓 연결되지 않음... [WebsocketRefreshService]");
//               ref.read(errorStateNotifierProvider.notifier).addError(Error.websocket);
//             }
//             // print("웹소켓  문제없음 [WebsocketRefreshService]");
//           });
//         }
//       } else if(newState) {
//         // 뭐가 들어가야할까..
//       }
//     });
//   }
// }