import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/Model/login_data_model.dart';
import 'package:orre_manager/Model/menu_data_model.dart';
import 'package:orre_manager/Model/restaurant_table_model.dart';
import 'package:orre_manager/Model/store_data_model.dart';
import 'package:orre_manager/presenter/Widget/alertDialog.dart';
import 'package:orre_manager/services/http_service.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

final storeDataProvider = StateNotifierProvider<StoreDataNotifier, StoreData?>((ref) {
  return StoreDataNotifier(); // 초기상태 null.
});

class StoreDataNotifier extends StateNotifier<StoreData?> {
  StoreDataNotifier() : super(null);
  
  StoreData? getStoreData() {
    return state;
  }

  void updateState(StoreData? newState){
    print('가게정보를 업데이트합니다.');
    state = newState;
  }

  Map<String, String?> getMenuCategory(){
    return state!.menuCategories;
  }

  List<Menu>? getMenuList() {
    return state!.menuInfo;
  }

  Future<void> requestStoreData(int storeCode) async {
    int tableNumber = 1;  // 딱히 중요하지 않은 변수라 일단 1 처리.
    final jsonBody = json.encode({
      "storeCode" : storeCode,
      "tableNumber" : tableNumber,
    });
      print('가게 정보를 요청합니다.');
    try {
      final response = await HttpsService.postRequest('/StoreAdmin/storeInfo', jsonBody);
      if(response.statusCode == 200){
        final Map<String, dynamic> responseBody = json.decode(utf8.decode(response.bodyBytes));
        print('수신내역 : ${responseBody.toString()}');
        StoreData storeData = StoreData.fromJson(responseBody);
        updateState(storeData);
      }
    } catch (error) {
      print('에러 발생 : $error');
    }
  }

  FutureOr<bool> addMenu(BuildContext context, Uint8List imageBytes, String menuCode, String name, String categoryKey, String description, int price, LoginData? loginData) async {
    // 이미지 파일 이름 설정
    String imageName = '$menuCode.jpg';

    // JSON 데이터 생성
    final jsonBody = utf8.encode(json.encode({
      "storeCode" : loginData!.storeCode,
      "menuCode": menuCode,
      "menu": name,
      "price": price,
      "singleMenuCode": categoryKey.toUpperCase(),
      "introduce": description,
      "jwtAdmin": loginData!.loginToken,
    }));
    // print(jsonBody.toString());
    // HTTP 요청 생성
    var request = http.MultipartRequest('POST', Uri.parse('https://orre.store/api/admin/StoreAdmin/menu/s3/upload'));

    // 이미지 파일 추가
    request.files.add(
      http.MultipartFile(
        'file',
        http.ByteStream.fromBytes(imageBytes),
        imageBytes.length,
        filename: imageName,
      ),
    );

    request.files.add(
      http.MultipartFile.fromBytes(
        'request', 
        jsonBody,
        contentType: MediaType('application', 'json') // JSON 데이터의 컨텐트 타입을 application/json으로 명시
      )
    );

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
        await showAlertDialog(context, "메뉴 추가", "메뉴추가 실패..", null);
        print('메뉴 추가 요청이 실패하였습니다. 상태 코드: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      // 요청에 실패한 경우 예외 처리
      print('메뉴 추가 요청 중 오류가 발생하였습니다: $e');
      return false;
    }
  }

  FutureOr<bool> modifyMenu(BuildContext context, LoginData loginData, String menuName, String menuCode, int price, String introduce) async {
    print('메뉴 변경 신청...');
    final jsonBody = json.encode({
      'storeCode' : loginData.storeCode,
      'menuCode' : menuCode,
      'menu' : menuName,
      'jwtAdmin' : loginData.loginToken,
      'price' : price,
      'introduce' : introduce,
    });
    try {
      final response = await HttpsService.postRequest('/StoreAdmin/menu/s3/modify', jsonBody);
      if(response.statusCode == 200){
        //HTTP는 정상수신되었을 때
        final responseBody = json.decode(utf8.decode(response.bodyBytes));
        if(responseBody['status'] == "200"){
          // 메뉴 수정 완료
          print('메뉴 수정 완료!');
          await showAlertDialog(context, "메뉴 변경", "메뉴명 : $menuName 변경 성공!", null);
          requestStoreData(loginData.storeCode);
          return true;
        } else {
          // 메뉴 수정 실패
          print('메뉴 수정 실패. status = ${responseBody['status']}');
          await showAlertDialog(context, "메뉴 변경", "메뉴명 : $menuName 변경 실패...", null);
          requestStoreData(loginData.storeCode);
          return false;
        }
      } else {
        //HTTP부터 정상수신 되지 않았을 때
        print('HTTP 에러 : status code <${response.statusCode}>');
        return false;
      }
    } catch (error) {
      print('에러발생 : $error');
      return false;
    }
  }

  FutureOr<bool> removeMenu(BuildContext context, String menuCode, String name, LoginData? loginData) async {
    print('메뉴삭제 신청...');
    final jsonBody = json.encode({
      "storeCode" : loginData!.storeCode,
      "menu" : name,
      "menuCode" : menuCode,
      "jwtAdmin" : loginData.loginToken,
    });
    try {
      final response = await HttpsService.postRequest('/StoreAdmin/menu/s3/remove', jsonBody);
      if(response.statusCode == 200){
        final responseBody = json.decode(utf8.decode(response.bodyBytes));
        if(responseBody['status'] == "200"){
          // 메뉴 삭제 성공
          print('메뉴명 : $name 메뉴삭제 성공!');
          requestStoreData(loginData.storeCode);
          await showAlertDialog(context, "메뉴 삭제", "메뉴명 : $name 삭제 성공!", null);
          return true;
        } else {
          // 메뉴 삭제 실패
          await showAlertDialog(context, "메뉴 삭제", "메뉴명 : $name 삭제 실패...", null);
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

  FutureOr<bool> editCategory(BuildContext context, LoginData? loginData, String singleMenuCode, String? categoryName) async {
    print('카테고리 수정 요청 수신');
    final String finalSingleMenuCode = singleMenuCode.toUpperCase();
    final jsonBody = json.encode({
      "storeCode" : loginData!.storeCode,
      "jwtAdmin" : loginData.loginToken,
      "singleMenuCode" : finalSingleMenuCode,
      "menuCategory" : categoryName,
    });
    try { 
      final response = await HttpsService.postRequest('/StoreAdmin/menu/category/modify', jsonBody);
      if(response.statusCode == 200){
        final responseBody = json.decode(utf8.decode(response.bodyBytes));
        if(responseBody['status'] == "200"){
          print('카테고리 등록/수정 성공!');
          requestStoreData(loginData.storeCode);
          await showAlertDialog(context, "카테고리 등록/수정", "성공!", null);
          return true;
        }else{
          // 다른 문제 발생
          print('카테고리 등록/성공 실패');
          await showAlertDialog(context, "카테고리 등록/수정", "실패", null);
          return false;
        }
      }else{
        // HTTP수신은 됐으나 다른 문제발생
        print('HTTP수신은 완료. 다른 문제임 StatusCOde : ${response.statusCode}');
        return false;
      }
    } catch (error) {
      print('HTTP 수신 장애 발생');
      return false;
    }
  }
}