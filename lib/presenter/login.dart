import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import '../store.dart';

class LoginData {
  final String status;
  final String storeCode;
  final String loginToken;

  LoginData({
    required this.status,
    required this.storeCode,
    required this.loginToken,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      status: json['status'],
      storeCode: json['storeCode'],
      loginToken: json['token'],
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _idController = TextEditingController();
  TextEditingController _pwController = TextEditingController();
  late StompClient stompClient;

  @override
  void initState() {
    super.initState();
    stompClient = StompClient(
      config: StompConfig(
        url: 'ws://172.30.1.85:8080/ws',
        onConnect: (StompFrame frame) {
          print("connected");
        },
        beforeConnect: () async {
          print('waiting to connect...');
          await Future.delayed(const Duration(milliseconds: 200));
          print('connecting...');
        },
        onWebSocketError: (dynamic error) => print(error.toString()),
      ),
    );
    stompClient.activate();
  }

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    stompClient.deactivate();
    super.dispose();
  }

  void _login(BuildContext context) {
    String pw = _pwController.text;
    String adminPhoneNumber = _idController.text;

    if (adminPhoneNumber.isNotEmpty && pw.isNotEmpty) {
      Map<String, dynamic> loginData = {
        "adminPhoneNumber": adminPhoneNumber,
        "password": pw,
      };

      String jsonEncoded = json.encode(loginData);
      print(jsonEncoded);

          
      stompClient.subscribe(
        destination: '/topic/admin/StoreAdmin/login/$adminPhoneNumber',
        callback: (StompFrame frame) {
          print('subscribe, success!!');
          print(frame.body.toString());

          Map<String, dynamic> responseData = json.decode(frame.body ?? '');
          LoginData loginResponse = LoginData.fromJson(responseData);

          if (loginResponse.status == 'success') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => StorePage(storeCode: loginResponse.storeCode),
              ),
            );

            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Login Succeeded'),
                  content: Text('Welcome!'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );
          } else {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Login Failed'),
                  content: Text('Invalid ID or Password.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        },
      );

      stompClient.send(
        destination: '/admin/StoreAdmin/login/$adminPhoneNumber',
        body: jsonEncoded,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ORRE(Manager) Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _idController,
              decoration: InputDecoration(labelText: 'Admin PhoneNumber'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _pwController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _login(context),
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
