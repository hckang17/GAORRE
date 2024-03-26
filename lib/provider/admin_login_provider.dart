import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/presenter/login.dart';
import 'package:orre_manager/store.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import '../Model/login_data_model.dart';

// LoginInfo 객체를 관리하는 프로바이더를 정의합니다.
final loginProvider =
    StateNotifierProvider<LoginDataNotifier, LoginData?>((ref) {
  return LoginDataNotifier(null); // 초기 상태를 null로 설정합니다.
});

// StateNotifier를 확장하여 LoginInfo 객체를 관리하는 클래스를 정의합니다.
class LoginDataNotifier extends StateNotifier<LoginData?> {
  StompClient? _client; // StompClient 인스턴스를 저장할 내부 변수 추가

  LoginDataNotifier(LoginData? initialState) : super(initialState);

  // StompClient 인스턴스를 설정하는 메소드
  void setClient(StompClient client) {
    print("LoginData : setClient");
    _client = client; // 내부 변수에 StompClient 인스턴스 저장
  }

  void subscribeToLoginData(BuildContext context, String adminPhoneNumber) {
    _client?.subscribe(
      destination: '/topic/admin/StoreAdmin/login/$adminPhoneNumber',
      callback: (StompFrame frame) {
        print('something read from server.');
        print(frame.body);
        print(frame.body.toString());
        if (frame.body != null) {
          print(frame.body.toString());
        }//디버그용 확인!
        
        Map<String, dynamic> responseData = json.decode(frame.body ?? '');
        LoginData loginResponse = LoginData.fromJson(responseData);

        if (loginResponse.status == 'success') {
          print('login successed');
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
                ]
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
    print("LoginData : subscribe!");
  }

  // Logindata를 보내는 메서드
  void sendLoginData(BuildContext context, String adminPhoneNumber, String pw) {
    print("sendLoginData : $adminPhoneNumber");
    _client?.send(
        destination: '/app/admin/StoreAdmin/login/$adminPhoneNumber',
      body: json.encode({
        "adminPhoneNumber": adminPhoneNumber,
        "adminPassword": pw,
      }),
    );
  }

  @override
  void dispose() {
    _client?.deactivate();
    super.dispose();
  }
}
