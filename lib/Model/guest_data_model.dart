import 'dart:core';

class Guest {
  final int waitingNumber;
  String? contact;
  String? userName;
  final String userToken;
  int tableNumber;
  final int storeCode;

  Guest({
    required this.waitingNumber,
    required this.userToken,
    required this.tableNumber,
    required this.storeCode,
  });

  String getUserToken() {
    return userToken;
  }

  void setUserName(String userName) {
    this.userName = userName;
  }

  @override
  String toString(){
    return userToken;
  }

  Map<String, dynamic> toJson() {
    return {
      'waitingNumber': waitingNumber,
      'contact': contact,
      'userName': userName,
      'userToken': userToken,
      'tableNumber': tableNumber,
      'storeCode': storeCode,
    };
  }
}