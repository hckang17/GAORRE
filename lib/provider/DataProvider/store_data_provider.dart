import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/Model/login_data_model.dart';
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

  Future<void> addMenu(BuildContext context, Uint8List imageBytes, String menuCode, String name, String categoryKey, String description, int price, LoginData? loginData) async {
    // 이미지 파일 이름 설정
    String imageName = '$menuCode.jpg';

    // JSON 데이터 생성
    final jsonBody = utf8.encode(json.encode({
      "storeCode" : loginData!.storeCode,
      "menuCode": menuCode,
      "menu": name,
      "price": price,
      "singleMenuCode": categoryKey,
      "introduce": description,
      "jwtAdmin": loginData!.loginToken,
    }));
    print(jsonBody.toString());
    // HTTP 요청 생성
    var request = http.MultipartRequest('POST', Uri.parse('https://orre.store/api/admin/StoreAdmin/menu/s3/upload'));

    // 이미지 파일 추가
    request.files.add(
      http.MultipartFile(
        'file',
        http.ByteStream.fromBytes(imageBytes),
        imageBytes.length,
        filename: imageName,
        // contentType: MediaType('image', 'jpeg'),
      ),
    );

    request.files.add(
      http.MultipartFile.fromBytes(
        'request', 
        jsonBody,
        contentType: MediaType('application', 'json') // JSON 데이터의 컨텐트 타입을 application/json으로 명시
      )
    );
    // JSON 데이터 추가
    // request.fields['request'] = jsonBody;

    // HTTP 요청 보내기
    try {
      var response = await request.send();
      
      if (response.statusCode == 200) {
        // 요청이 성공하면 처리
        print('메뉴 추가 요청이 성공하였습니다.');
        showAlertDialog(context, "메뉴 추가", "메뉴추가 성공!", null);
        requestStoreData(loginData!.storeCode);
      } else {
        // 요청이 실패하면 처리
        showAlertDialog(context, "메뉴 추가", "메뉴추가 실패..", null);
        print('메뉴 추가 요청이 실패하였습니다. 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      // 요청에 실패한 경우 예외 처리
      print('메뉴 추가 요청 중 오류가 발생하였습니다: $e');
    }
  }

  
}