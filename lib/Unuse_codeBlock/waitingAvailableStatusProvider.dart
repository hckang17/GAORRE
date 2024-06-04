
// import 'dart:convert';

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gaorre/Model/LoginDataModel.dart';
// import 'package:gaorre/services/HIVE_service.dart';
// import 'package:gaorre/services/HTTP_service.dart';

// enum WaitingAvailableState {
//   POSSIBLE, // 0
//   IMPOSSIBLE, // 1
// }

// final waitingAvailableStatusStateProvider = StateNotifierProvider<WaitingAvailableStatusNotifier, int>((ref) {
//   return WaitingAvailableStatusNotifier(0); // 초기상태 0. -> POSSIBLE
// });

// class WaitingAvailableStatusNotifier extends StateNotifier<int> {
//   WaitingAvailableStatusNotifier(int initialState) : super(initialState) {
//     _initialize();
//   }

//   int getState(){
//     return state;
//   }

//   void updateState(int newState){
//     newState == 0 ? print('현재 : 웨이팅 접수 받는중') : print('현재 : 웨이팅 접수 안받는중');
//     state = newState;
//     saveWaitingAvailableStatus();
//   }

//   Future<void> _initialize() async {
    
//     String? rawData = await HiveService.retrieveData('waitingAvailableStatus');
//     if (rawData == null) {
//       print('기존 데이터가 존재하지 않음으로.. 웨이팅 가능하도록 설정합니다. [waitingAvailableStatus]');
//       state = 0;
//     } else {
//       print('기존 데이터가 존재합니다! [waitingAvailableStatus]');
//       int loadedState = int.parse(rawData);
//       state = loadedState;
//     }
//   }

  // Future<bool> loadWaitingAvailableStatus() async {
  //   String? rawData = await HiveService.retrieveData('waitingAvailableStatus');
  //   if(rawData == null){
  //     updateState(0);
  //     print('기존 데이터가 존재하지 않음으로.. 웨이팅 가능하도록 설정합니다. [waitingAvailableStatus]');
  //     return false;
  //   } else {
  //     print('기존 데이터가 존재합니다! [waitingAvailableStatus]');
  //     int IntData = int.parse(rawData);
  //     state = IntData;
  //     return true;
  //   }
  // }

//   Future<bool> saveWaitingAvailableStatus() async {
//     try {
//       int currentState = state;
//       await HiveService.saveIntData('waitingAvailableStatus', currentState);
//       print('[saveLoginData] 성공! [loginProvider]');
//       return true;
//       } catch (error) {
//       print('[saveLoginData] 실패. 에러 : $error [loginProvider]');
//       return false;
//     }
//   }

//   Future<bool> changeAvailableStatus(LoginData loginData) async {
//     late int payload;
//     if(state == WaitingAvailableState.POSSIBLE.index){
//       payload = WaitingAvailableState.IMPOSSIBLE.index;
//     }else{
//       payload = WaitingAvailableState.POSSIBLE.index;
//     }

//     final jsonBody = json.encode({
//       "storeCode" : loginData.storeCode,
//       "jwtAdmin" : loginData.loginToken,
//       "storeWaitingAvailable" : payload,
//     });
//     try {
//       final response = await HttpsService.postRequest('/StoreAdmin/available/waiting', jsonBody);
//       if(response.statusCode == 200){
//         final responseBody = json.decode(utf8.decode(response.bodyBytes));
//         if(responseBody['status'] == "200"){
//           print('가게 웨이팅 가능 여부 변경 성공!~ [waitingAvailableStatusProvider]');
//           updateState(payload);
//           return true;
//         }else{
//           print('가게 웨이팅 가능 여부 변경 실패.. [waitingAvailableStatusProvider]');
//           return false;
//         }
//       }else{
//         print('HTTP 수신에 문제가 발생한것같습니다. [waitingAvailableStatusProvider]');
//         return false;
//       }
//     } catch(error) {
//       print('웨이팅 가능 여부 변경에 오류가 있습니다.. 에러 : $error [waitingAvailableStatusProvider]');
//       return false;
//     } 
//   }
// }
