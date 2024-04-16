import 'dart:convert';

class WaitingData {
  final int storeCode;
  final List<WaitingTeam> teamInfoList;
  final int estimatedWaitingTimePerTeam;

  WaitingData({
    required this.storeCode,
    required this.teamInfoList,
    required this.estimatedWaitingTimePerTeam,
  });

  factory WaitingData.fromJson(Map<String, dynamic> json) {
    var teamInfoList = json['teamInfoList'] as List;
    List<WaitingTeam> teams = teamInfoList.map((teamJson) => WaitingTeam.fromJson(teamJson)).toList();

    return WaitingData(
      storeCode: json['storeCode'],
      teamInfoList: teams,
      estimatedWaitingTimePerTeam: json['estimatedWaitingTimePerTeam'],
    );
  }
}

class WaitingTeam {
  final int waitingTeam;  // 대기번호
  final int enteringTeam; 
  final String phoneNumber;
  final int personNumber;

  WaitingTeam({
    required this.waitingTeam,
    required this.enteringTeam,
    required this.phoneNumber,
    required this.personNumber,
  });

  factory WaitingTeam.fromJson(Map<String, dynamic> json) {
    return WaitingTeam(
      waitingTeam: json['waitingTeam'],
      enteringTeam: json['enteringTeam'],
      phoneNumber: json['phoneNumber'],
      personNumber: json['personNumber'],
    );
  }
}

class CallWaitingTeam {
  //	{"storeCode":1,"waitingTeam":1,"entryTime":"2024-03-28T23:04:18.3394633"
  final int storeCode;
  final int waitingTeam;
  final String entryTime;

  CallWaitingTeam({
    required this.storeCode,
    required this.waitingTeam,
    required this.entryTime,
  });

  factory CallWaitingTeam.fromJson(Map<String, dynamic> json) {
    return CallWaitingTeam(
      storeCode: json['storeCode'],
      waitingTeam: json['waitingTeam'],
      entryTime: json['entryTime'],
    );
  }
}