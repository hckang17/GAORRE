import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaorre/Model/LoginDataModel.dart';
import 'package:gaorre/Model/MenuDataModel.dart';
import 'package:gaorre/Model/RestaurantTableModel.dart';
import 'package:gaorre/Model/StoreDataModel.dart';
import 'package:gaorre/presenter/Widget/AlertDialog.dart';
import 'package:gaorre/provider/Data/loginDataProvider.dart';
import 'package:gaorre/services/HIVE_service.dart';
import 'package:gaorre/services/HTTP_service.dart';
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:http_parser/http_parser.dart';

enum WaitingAvailableState {
  POSSIBLE, // 0
  IMPOSSIBLE, // 1
}

final storeDataProvider =
    StateNotifierProvider<StoreDataNotifier, StoreData?>((ref) {
  return StoreDataNotifier(); // 초기상태 null.
});

class StoreDataNotifier extends StateNotifier<StoreData?> {
  StoreDataNotifier() : super(null);

  // 점포정보 반환
  StoreData? getStoreData() {
    return state;
  }

  // 웨이팅가능여부 정보 반환. 1 -> 웨이팅접수불가 / 0 -> 웨이팅접수가능
  int getWaitingAvailable() {
    return state!.waitingAvailable;
  }

  // 메뉴코드 찾는 메서드
  String getMenuCode(String menuName) {
    try {
      // state 또는 state의 menuInfo가 null일 경우 예외를 발생시킵니다.
      if (state == null || state!.menuInfo == null) {
        throw Exception(
            '가게 데이터가 없거나 메뉴 정보가 없습니다. [storeDataProvider - getMenuCode]');
      }
      // 메뉴 리스트를 순회하며 메뉴 이름과 일치하는 메뉴 코드를 찾습니다.
      for (Menu menu in state!.menuInfo!) {
        if (menu.menuName == menuName) {
          return menu.menuCode;
        }
      }

      // 일치하는 메뉴가 없을 경우 예외를 발생시킵니다.
      throw Exception(
          '해당 이름의 메뉴를 찾을 수 없습니다: $menuName [storeDataProvider - getMenuCode]');
    } catch (e) {
      // 예외 발생 시 예외 메시지를 출력하고 빈 문자열을 반환합니다.
      print('오류 발생: $e');
      throw Exception(
          '해당 이름의 메뉴를 찾을 수 없습니다: $menuName [storeDataProvider - getMenuCode]');
    }
  }

  // 점포정보 갱신
  void updateState(StoreData? newState) {
    print('가게정보를 업데이트합니다. [storeDataProvider - updateState]');
    state = newState;
  }

  // 메뉴카테고리 반환 메서드
  Map<String, String?> getMenuCategory() {
    return state!.menuCategories;
  }

  // 메뉴리스트 반환 메서드
  List<Menu>? getMenuList() {
    return state!.menuInfo;
  }

  // 웨이팅가능여부 변경 메서드
  Future<bool> changeAvailableStatus(LoginData loginData) async {
    late int payload;
    if (state!.waitingAvailable == WaitingAvailableState.POSSIBLE.index) {
      payload = WaitingAvailableState.IMPOSSIBLE.index;
    } else {
      payload = WaitingAvailableState.POSSIBLE.index;
    }

    final jsonBody = json.encode({
      "storeCode": loginData.storeCode,
      "jwtAdmin": loginData.loginToken,
      "storeWaitingAvailable": payload,
    });
    try {
      final response = await HttpsService.postRequest(
          '/StoreAdmin/available/waiting', jsonBody);
      if (response.statusCode == 200) {
        final responseBody = json.decode(utf8.decode(response.bodyBytes));
        if (responseBody['status'] == "200") {
          print('가게 웨이팅 가능 여부 변경 성공!~ [waitingAvailableStatusProvider]');
          state!.waitingAvailable = payload;
          return true;
        } else {
          print('가게 웨이팅 가능 여부 변경 실패.. [waitingAvailableStatusProvider]');
          return false;
        }
      } else {
        print('HTTP 수신에 문제가 발생한것같습니다. [waitingAvailableStatusProvider]');
        return false;
      }
    } catch (error) {
      print(
          '웨이팅 가능 여부 변경에 오류가 있습니다.. 에러 : $error [waitingAvailableStatusProvider]');
      return false;
    }
  }

  // ★매우 중요★ 가게 정보를 일괄 요청하는 메서드
  Future<bool> requestStoreData(int storeCode) async {
    int tableNumber = 1; // 딱히 중요하지 않은 변수라 일단 1 처리.
    final jsonBody = json.encode({
      "storeCode": storeCode,
      "tableNumber": tableNumber,
    });
    print('가게 정보를 요청합니다. [storeDataProvider - requestStoreData]');
    try {
      final response =
          await HttpsService.postRequest('/StoreAdmin/storeInfo', jsonBody);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody =
            json.decode(utf8.decode(response.bodyBytes));
        print('수신내역 : ${responseBody.toString()}');
        StoreData storeData = StoreData.fromJson(responseBody);
        updateState(storeData);
        return true;
      } else {
        return false;
      }
    } catch (error) {
      print('에러 발생 : $error [storeDataProvider - requestStoreData]');
      throw Exception('가게정보 요청 실패 [storeDataProvider - requestStoreData]');
    }
  }

  // 메뉴 추가 메서드
  FutureOr<bool> addMenu(
      BuildContext context,
      Uint8List imageBytes,
      String menuCode,
      String name,
      String categoryKey,
      String description,
      int price,
      LoginData? loginData) async {
    // 이미지 파일 이름 설정
    String imageName = '$menuCode.jpg';

    // JSON 데이터 생성
    final jsonBody = utf8.encode(json.encode({
      "storeCode": loginData!.storeCode,
      "menuCode": menuCode,
      "menu": name,
      "price": price,
      "singleMenuCode": categoryKey.toUpperCase(),
      "introduce": description,
      "jwtAdmin": loginData!.loginToken,
    }));
    // print(jsonBody.toString());
    // HTTP 요청 생성
    var request = http.MultipartRequest('POST',
        Uri.parse('https://orre.store/api/admin/StoreAdmin/menu/s3/upload'));

    // 이미지 파일 추가
    request.files.add(
      http.MultipartFile(
        'file',
        http.ByteStream.fromBytes(imageBytes),
        imageBytes.length,
        filename: imageName,
      ),
    );

    request.files.add(http.MultipartFile.fromBytes('request', jsonBody,
        contentType: MediaType(
            'application', 'json') // JSON 데이터의 컨텐트 타입을 application/json으로 명시
        ));

    // HTTP 요청 보내기
    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        // HTTP가 정상적으로 요청되었을 때
        print('메뉴 추가 요청이 성공하였습니다.');
        await showAlertDialog(context, "메뉴 추가", "메뉴추가 성공!", null);
        requestStoreData(loginData!.storeCode);
        return true;
      } else {
        // 요청이 실패하면 처리
        await showAlertDialog(
            context, "메뉴 추가", "메뉴추가 실패.. 에러코드:[${response.statusCode}]", null);
        print(
            '메뉴 추가 요청이 실패하였습니다. 상태 코드: ${response.statusCode} [storeDataProvider - addMenu]');
        return false;
      }
    } catch (e) {
      // 요청에 실패한 경우 예외 처리
      print('메뉴 추가 요청 중 오류가 발생하였습니다: $e');
      return false;
    }
  }

  // 메뉴 수정 메서드
  FutureOr<bool> modifyMenu(
      BuildContext context,
      LoginData loginData,
      String originMenu,
      String menuName,
      String menuCode,
      int price,
      String introduce,
      int recommend) async {
    print('메뉴 변경 신청... [storeDataProvider - modifyMenu]');
    final jsonBody = json.encode({
      'storeCode': loginData.storeCode,
      'menuCode': menuCode,
      'menu': originMenu,
      'newMenu': menuName,
      'jwtAdmin': loginData.loginToken,
      'price': price,
      'introduce': introduce,
      'recommend': recommend,
    });
    try {
      final response = await HttpsService.postRequest(
          '/StoreAdmin/menu/s3/modify', jsonBody);
      if (response.statusCode == 200) {
        //HTTP는 정상수신되었을 때
        final responseBody = json.decode(utf8.decode(response.bodyBytes));
        if (responseBody['status'] == "200") {
          // 메뉴 수정 완료
          print('메뉴 수정 완료!');
          await showAlertDialog(
              context, "메뉴 변경", "메뉴명 : $menuName 변경 성공!", null);
          await requestStoreData(loginData.storeCode);
          return true;
        } else {
          // 메뉴 수정 실패
          print('메뉴 수정 실패. status = ${responseBody['status']}');
          await showAlertDialog(
              context,
              "메뉴 변경",
              "메뉴명 : $menuName 변경 실패...\n에러코드:[${responseBody['status']}]",
              null);
          await requestStoreData(loginData.storeCode);
          return false;
        }
      } else {
        //HTTP부터 정상수신 되지 않았을 때
        print('HTTP 에러 : status code <${response.statusCode}>');
        await showAlertDialog(context, "메뉴 변경",
            "메뉴명 : $menuName 변경 실패... \n에러코드:HTTP${response.statusCode}", null);
        return false;
      }
    } catch (error) {
      print('에러발생 : $error');
      return false;
    }
  }

  // 메뉴 삭제 메서드
  FutureOr<bool> removeMenu(BuildContext context, String menuCode, String name,
      LoginData? loginData) async {
    print('메뉴삭제 신청...');
    final jsonBody = json.encode({
      "storeCode": loginData!.storeCode,
      "menu": name,
      "menuCode": menuCode,
      "jwtAdmin": loginData.loginToken,
    });
    try {
      final response = await HttpsService.postRequest(
          '/StoreAdmin/menu/s3/remove', jsonBody);
      if (response.statusCode == 200) {
        final responseBody = json.decode(utf8.decode(response.bodyBytes));
        if (responseBody['status'] == "200") {
          // 메뉴 삭제 성공
          print('메뉴명 : $name 메뉴삭제 성공!');
          requestStoreData(loginData.storeCode);
          await showAlertDialog(context, "메뉴 삭제", "메뉴명 : $name 삭제 성공!", null);
          return true;
        } else {
          // 메뉴 삭제 실패
          await showAlertDialog(context, "메뉴 삭제",
              "메뉴명 : $name 삭제 실패... 에러코드:[${responseBody['status']}]", null);
          print('삭제 실패. StatusCode : ${response.statusCode}');
          return false;
        }
      } else {
        // HTTP 수신 에러
        print('HTTP 관련 에러로 생각됨');
        return false;
      }
    } catch (e) {
      print('에러발생 에러코드 : $e');
      return false;
    }
  }

  // 카테고리 추가/수정/삭제 메서드.   카테고리명이 비어있으면 삭제요청임.
  FutureOr<bool> editCategory(
      BuildContext context,
      LoginData? loginData,
      List<Menu>? menuInCategory,
      String singleMenuCode,
      String? categoryName) async {
    print('카테고리 수정 요청 수신');
    // if(menuInCategory!.isNotEmpty){
    //   await showAlertDialog(context, "카테고리 삭제", "카테고리의 메뉴를 모두 삭제한 후 다시 시도해 주세요", null);
    //   return false;
    // }
    final String finalSingleMenuCode = singleMenuCode.toUpperCase();
    final jsonBody = json.encode({
      "storeCode": loginData!.storeCode,
      "jwtAdmin": loginData.loginToken,
      "singleMenuCode": finalSingleMenuCode,
      "menuCategory": categoryName,
    });
    try {
      final response = await HttpsService.postRequest(
          '/StoreAdmin/menu/category/modify', jsonBody);
      if (response.statusCode == 200) {
        final responseBody = json.decode(utf8.decode(response.bodyBytes));
        if (responseBody['status'] == "200") {
          print('카테고리 등록/수정 성공!');
          requestStoreData(loginData.storeCode!);
          await showAlertDialog(context, "카테고리 등록/수정", "성공!", null);
          return true;
        } else {
          // 다른 문제 발생
          print('카테고리 등록/성공 실패');
          await showAlertDialog(context, "카테고리 등록/수정",
              "실패.\n에러코드:[${responseBody['status']}]", null);
          return false;
        }
      } else {
        // HTTP수신은 됐으나 다른 문제발생
        print('HTTP수신은 완료. 다른 문제임 StatusCOde : ${response.statusCode}');
        return false;
      }
    } catch (error) {
      print('HTTP 수신 장애 발생');
      return false;
    }
  }

  // 오늘 영업 종료! 모든 웨이팅을 해제합니다.
  Future<bool> requestCloseStore(WidgetRef ref) async {
    ///StoreAdmin/closing - jwtAdmin, storeCode
    print('영업종료 요청... [storeDataProvider - closeStore]');
    final LoginData loginData =
        ref.read(loginProvider.notifier).getLoginData()!;
    final jsonBody = json.encode({
      "jwtAdmin": loginData.loginToken,
      "storeCode": loginData.storeCode,
    });
    try {
      final response =
          await HttpsService.postRequest('/StoreAdmin/closing', jsonBody);
      if (response.statusCode == 200) {
        final responseBody = json.decode(utf8.decode(response.bodyBytes));
        if (responseBody['status'] == "200" ||
            responseBody['status'] == "6402") {
          // 폐점성공
          print('영업종료처리 성공 [storeDataProvider - closeStore]');
          await showAlertDialog(ref.context, "영업종료", "성공", null);
          await HiveService.clearAllData();
          return true;
        } else {
          print('영업종료처리 실패 [storeDataProvider - closeStore]');
          await showAlertDialog(ref.context, "영업종료",
              "실패\n에러코드:[${responseBody['status']}]", null);
          return false;
        }
      } else {
        print('HTTP statusCode not 200 [storeDataProvider - closeStore]');
        await showAlertDialog(
            ref.context, "영업종료", "실패\n에러코드:[${response.statusCode}]", null);
        return false;
      }
    } catch (error) {
      print("HTTP 에러발생. 에러 : $error [storeDataProvider - closeStore]");
      await showAlertDialog(ref.context, "영업종료", "실패\n에러코드:HTTP", null);
      return false;
    }
  }
}
