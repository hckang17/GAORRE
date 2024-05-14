import 'dart:convert';

class LoginData {
  String? status;
  final int storeCode;
  final String? loginToken;

  LoginData({this.status, required this.storeCode, required this.loginToken});

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      status: json['status'],
      storeCode: json['storeCode'],
      loginToken: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'storeCode': storeCode,
      'token': loginToken,
    };
  }
}
