import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/Model/LoginDataModel.dart';
import 'package:orre_manager/Model/WaitingLogDataModel.dart';
import 'package:orre_manager/services/HTTP_service.dart';

final userLogProvider =
    StateNotifierProvider<UserLogDataListNotifier, UserLogDataList?>((ref) {
  return UserLogDataListNotifier(); // 초기 상태를 null로 설정합니다.
});

// StateNotifier를 확장하여 UserLogDataList 객체를 관리하는 클래스를 정의합니다.
class UserLogDataListNotifier extends StateNotifier<UserLogDataList?> {
  UserLogDataListNotifier() : super(null);

  void updateState(newState){
    print('유저로그 상태 업데이트. [userLogProvider - retrieveUserLogData]');
    state = newState;
  }

  void resetState(newState){
    print('유저로그 상태 초기화 요청... [userLogProvider - retrieveUserLogData]');
    state = null;
  }

  Future<void> retrieveUserLogData(LoginData loginData) async {
    print('유저 로그 데이터 신청... [userLogProvider - retrieveUserLogData]');
    final jsonBody = json.encode({
      "storeCode" : loginData.storeCode,
      "jwtAdmin" : loginData.loginToken,
    });
    try{
      final response = await HttpsService.postRequest('/StoreAdmin/log', jsonBody);
      if(response.statusCode == 200){
        final responseBody = json.decode(utf8.decode(response.bodyBytes));
        if(responseBody['status'] == "200"){
          // 정상 수신 완료;
          UserLogDataList retrievedData = UserLogDataList.fromJson(responseBody);
          updateState(retrievedData);
        }
      }else{
        throw "HTTP STATUSCODE 오류 : ${response.statusCode}";
      }
    }catch(error){
      print('HTTP 에러 발생 : $error [userLogProvider - retrieveUsertLogData]');
    }
  }

  UserLogDataList? getState() {
    return state;
  }

}