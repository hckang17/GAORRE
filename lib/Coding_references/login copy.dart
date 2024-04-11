// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter/material.dart';
// import 'package:stomp_dart_client/stomp.dart';
// import 'package:stomp_dart_client/stomp_config.dart';
// import 'package:stomp_dart_client/stomp_frame.dart';
// import '../presenter/store_screen.dart';
// // import 'stomp_websocket.dart'; // Uncomment this line to import StompService

// class LoginData {
//   final String status;  
//   final int storeCode;  
//   final String loginToken;

//   LoginData({
//     required this.status,
//     required this.storeCode,
//     required this.loginToken,
//   });

//   factory LoginData.fromJson(Map<String, dynamic> json) {
//     return LoginData(
//       status: json['status'],
//       storeCode: json['storeCode'],
//       loginToken: json['token'],
//     );
//   }
// }

// final stompClientProvider = FutureProvider<StompClient>((ref) async {
//   final completer = Completer<StompClient>();

//   StompClient client = StompClient(
//     config: StompConfig(
//       url: 'ws://172.30.1.29:8080/ws',
//       onConnect: (StompFrame frame) {
//         print("connected");
//         completer.complete(frame as FutureOr<StompClient>?);
//       },
//       beforeConnect: () async {
//         print('Connecting to websocket...');
//       },
//       onWebSocketError: (dynamic error) {
//         print(error.toString());
//         completer.completeError(error);
//       },
//     ),
//   );

//   client.activate();
//   return completer.future;
// });

// class LoginPage extends StatelessWidget {
//   TextEditingController _idController = TextEditingController();
//   TextEditingController _pwController = TextEditingController();

//   void _login(BuildContext context, StompClient stompClient) {
//     String pw = _pwController.text;
//     String adminPhoneNumber = _idController.text; // Fill in with admin phone number

//     if (adminPhoneNumber.isNotEmpty && pw.isNotEmpty) {
//       Map<String, dynamic> loginData = {
//         "adminPhoneNumber": adminPhoneNumber,
//         "password": pw,
//       };

//       String jsonEncoded = json.encode(loginData);

//       stompClient.subscribe(
//         destination: '/admin/StoreAdmin/login/$adminPhoneNumber',
//         callback: (StompFrame frame) {
//           // Handle response from server
//           Map<String, dynamic> responseData = json.decode(frame.body ?? '');
//           LoginData loginResponse = LoginData.fromJson(responseData);

//           if (loginResponse.status == 'success') {
//             // Login successful
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => StorePage(storeCode: loginResponse.storeCode),
//               ),
//             );

//             showDialog(
//               context: context,
//               builder: (context) {
//                 return AlertDialog(
//                   title: Text('Login Succeeded'),
//                   content: Text('Welcome!'),
//                   actions: <Widget>[
//                     TextButton(
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                       child: Text('OK'),
//                     ),
//                   ],
//                 );
//               },
//             );
//           } else {
//             // Login failed
//             showDialog(
//               context: context,
//               builder: (context) {
//                 return AlertDialog(
//                   title: Text('Login Failed'),
//                   content: Text('Invalid ID or Password.'),
//                   actions: <Widget>[
//                     TextButton(
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                       child: Text('OK'),
//                     ),
//                   ],
//                 );
//               },
//             );
//           }
//         }, 
//       );
//       // Send login data to server
//       stompClient.send(
//         destination: '/admin/StoreAdmin/login/$adminPhoneNumber',
//         body: jsonEncoded,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('ORRE(Manager) Login'),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(20.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextField(
//               controller: _idController,
//               decoration: InputDecoration(labelText: 'Admin PhoneNumber'),
//             ),
//             SizedBox(height: 20),
//             TextField(
//               controller: _pwController,
//               decoration: InputDecoration(labelText: 'Password'),
//               obscureText: true,
//             ),
//             SizedBox(height: 20),
//             Consumer(
//               builder: (context, watch, child) {
//                 final stompClientFuture = watch;

//                 return ElevatedButton(
//                   onPressed: () async {
//                     final stompClient = await stompClientFuture;
//                     _login(context, stompClient as StompClient);
//                   },
//                   child: Text('Login'),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
