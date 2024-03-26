class LoginData {
  final String status;
  final int storeCode;
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