import 'dart:async';
import 'dart:convert';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class StompService {
  final Function(StompFrame) onConnectCallback;

  StompService({
    this.onConnectCallback = _defaultOnConnectCallback,
  }) {
    _initializeStompClient();
  }

  void _initializeStompClient() {
    final stompClient = StompClient(
      config: StompConfig(
        url: 'ws://192.168.0.13:8080/ws',
        onConnect: (frame) => onConnect(frame),
        beforeConnect: () async {
          print('waiting to connect...');
          await Future.delayed(const Duration(milliseconds: 200));
          print('connecting...');
        },
        onWebSocketError: (dynamic error) => print(error.toString()),
        // stompConnectHeaders: {'Authorization': 'Bearer yourToken'},
        // webSocketConnectHeaders: {'Authorization': 'Bearer yourToken'},
      ),
    );
  }

  void onConnect(StompFrame frame) {
    print('connected! message came from (stomp_websocket.dart)');
    onConnectCallback(frame); // Call the provided callback
  }

  static void _defaultOnConnectCallback(StompFrame frame) {
    // Default implementation of onConnectCallback
    print('Default onConnectCallback executed');
  }
}




// Future<void> sendLoginInfo(String phoneNumber, String password) async {
//   final stompClient = StompService.stompClient;

//   final loginInfo = {'adminPhoneNumber': phoneNumber, 'password': password};
//   final jsonLoginInfo = json.encode(loginInfo);

//   final stompFrame = await stompClient.send(
//     destination: '/app/admin/StoreAdmin/login/$phoneNumber', // 엔드포인트 설정
//     body: jsonLoginInfo,
//     headers: {'content-type': 'application/json'}, // JSON 형식으로 전송
//   );

//   final response = json.decode(stompFrame.body);

//   if (response['status'] == 'success') {
//     final String token = response['token'];
//     final int storeCode = response['storeCode'];

//     // 로그인 성공 처리
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Login Succeed'),
//           content: Text('Welcome!'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
    
//     // 성공한 경우 토큰 및 storeCode를 얻을 수 있으므로 적절한 작업을 수행합니다.
//     // 예: 토큰 및 storeCode를 전역 변수에 저장하거나 필요한 곳에 전달합니다.
//   } else {
//     // 로그인 실패 처리
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Login Failed'),
//           content: Text('Invalid ID or Password.'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }



// void onConnect(StompFrame frame) {
//   print('connected!');
//   // stompClient.subscribe(
//   //   destination: '/topic/test/subscription',
//   //   callback: (frame) {
//   //     List<dynamic>? result = json.decode(frame.body!);
//   //     print(result);
//   //   },
//   // );

//   // Timer.periodic(const Duration(seconds: 10), (_) {
//   //   stompClient.send(
//   //     destination: '/app/test/endpoints',
//   //     body: json.encode({'a': 123}),
//   //   );
//   // });
// }