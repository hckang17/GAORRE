import 'dart:convert';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // 플랫폼 확인용

class HiveService {
  static const String _boxName = "Gaorre";

  // Hive 초기화 및 기본 박스 열기
  static Future<bool> initHive() async {
    if (kIsWeb) {
      await Hive.initFlutter(); // 웹에서는 이 방식을 사용
    } else {
      try {
        final appDocumentDir = await getApplicationDocumentsDirectory();
        Hive.init(appDocumentDir.path); // 모바일에서는 path_provider 사용
      } catch (error) {
        print('하이브 저장소 초기화 실패. 에러코드 : $error');
        return false;
      }
    }
    await Hive.openBox(_boxName); // 모든 플랫폼에서 박스 열기
    print('HIVE저장소 초기화 성공... [HiveService]');
    return true;
  }

  static Future<bool> saveIntData(String key, int value) async {
    var box = Hive.box(_boxName);
    try {
      String intString = value.toString();
      await box.put(key, intString);
      print('[하이브 데이터 저장]\nKey : $key, Value : $value');
      return true;
    } catch(error) {
      print('[하이브 데이터 저장] 실패... 에러코드 : $error');
      return false;
    }
  }

  static Future<bool> saveStringData(String key, String value) async {
    var box = Hive.box(_boxName);
    try {
      String intString = value;
      await box.put(key, intString);
      print('[하이브 데이터 저장]\nKey : $key, Value : $value');
      return true;
    } catch(error) {
      print('[하이브 데이터 저장] 실패... 에러코드 : $error');
      return false;
    }
  }

  // 데이터 저장 (JSON 형식)
  static Future<bool> saveData(String key, Map<String, dynamic> value) async {
    var box = Hive.box(_boxName);
    try {
      String jsonString = jsonEncode(value);
      await box.put(key, jsonString);
      print('[하이브 데이터 저장]\nKey : $key\nValue : $value');
      return true;
    } catch (error) {
      print('[하이브 데이터 저장] 실패... 에러코드 : $error');
      return false;
    }
  }

  // 데이터 불러오기 (JSON 형식)
  static Future<String?> retrieveData(String key) async {
    var box = Hive.box(_boxName);
    var jsonString = box.get(key);
    if (jsonString != null) {
      // JSON 문자열을 객체로 변환하거나 그대로 반환할 수 있습니다.
      return jsonString;
    }
    return null; // 키에 해당하는 데이터가 없을 경우 null 반환
  }

  static Future<bool> clearAllData() async {
    var box = Hive.box(_boxName);
    try {
      await box.clear();  // 박스 내 모든 키-값 쌍 삭제
      return true;
    } catch (error) {
      print('[하이브 데이터 클리어] 클리어 실패... 에러코드 : $error');
      return false;
    }
  }

  // Hive 종료
  static void closeHive() {
    Hive.close();
  }
}
