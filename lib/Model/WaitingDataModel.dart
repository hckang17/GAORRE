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
    List<WaitingTeam> teams =
        teamInfoList.map((teamJson) => WaitingTeam.fromJson(teamJson)).toList();

    return WaitingData(
      storeCode: json['storeCode'],
      teamInfoList: teams,
      estimatedWaitingTimePerTeam: json['estimatedWaitingTimePerTeam'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storeCode': storeCode,
      'teamInfoList': teamInfoList.map((team) => team.toJson()).toList(),
      'estimatedWaitingTimePerTeam': estimatedWaitingTimePerTeam,
    };
  }
}

class WaitingTeam {
  final int waitingNumber; // 대기번호
  final int status; // 대기상태
  final String phoneNumber;
  final int personNumber;
  DateTime? entryTime; // nullable

  WaitingTeam({
    required this.waitingNumber, //
    required this.status,
    required this.phoneNumber,
    required this.personNumber,
    this.entryTime,
  });

  factory WaitingTeam.fromJson(Map<String, dynamic> json) {
    return WaitingTeam(
      waitingNumber: json['waitingTeam'],
      status: json['status'],
      phoneNumber: json['phoneNumber'],
      personNumber: json['personNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'waitingNumber': waitingNumber,
      'status': status,
      'phoneNumber': phoneNumber,
      'personNumber': personNumber,
      'entryTime': entryTime?.toIso8601String(),
    };
  }
}

class CallWaitingTeam {
  //	{"storeCode":1,"waitingTeam":1,"entryTime":"2024-03-28T23:04:18.3394633"}
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
