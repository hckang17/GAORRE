

class UserLogDataList {
  List<UserLogData>? userLogs;

  UserLogDataList({
    this.userLogs
  });

  factory UserLogDataList.fromJson(Map<String, dynamic> json){
    var userLogDataList = json['userLogs'] as List;
    List<UserLogData> logList = userLogDataList.map((userLogJson) => UserLogData.fromJson(userLogJson)).toList();
    return UserLogDataList(userLogs: logList);
  }
}

class UserLogData {
  final String userPhoneNumber;   // 고객 연락처 
  final String status;            // 고객 상태
  final String makeWaitingTime;   // 최초로 웨이팅 등록을 한 시간
  String? statusChangeTime;
  final int waitingNumber;
  final int personNumber;

  UserLogData({
    required this.userPhoneNumber,
    required this.status,
    required this.makeWaitingTime,
    required this.waitingNumber,
    required this.personNumber,
    this.statusChangeTime,
  });

  factory UserLogData.fromJson(Map<String, dynamic> json) {
    return UserLogData(
      userPhoneNumber: json['userPhoneNumber'],
      status: json['status'],
      makeWaitingTime: json['makeWaitingTime'],
      statusChangeTime: json['statusChangeTime'],
      waitingNumber: json['waiting'],
      personNumber: json['personNumber'],
    );
  }
}


// {
//     "userLogs": [
//         {
//             "userPhoneNumber": "01056630635",
//             "historyNum": 1,
//             "status": "waiting",
//             "makeWaitingTime": "2024-05-14T04:08:34.000+00:00",
//             "storeCode": 1,
//             "statusChangeTime": null,
//             "paidMoney": 0,
//             "orderedMenu": ""
//             "waiting",
//             "personNumber", 
//         }
//     ],
//     "status": "200"
// }