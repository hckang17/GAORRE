import 'dart:collection';
import 'dart:convert';
import 'package:orre_manager/Model/menu_data_model.dart'; // 이 경로는 실제 프로젝트의 구조에 따라 조정하세요.

class StoreData {
  final int storeCode;
  final String storeName;
  final int storeInfoVersion;
  final String storeIntroduce;
  final String storeCategory;
  final String storeImageMain;
  final String openingTime;
  final String closingTime;
  final String lastOrderTime;
  final String startBreakTime;
  final String endBreakTime;
  final Map<String, String?> menuCategories;  // String 대신 String? 사용
  List<Menu>? menuInfo;

  StoreData({
    required this.storeCode,
    required this.storeName,
    this.storeInfoVersion = 0,
    this.storeIntroduce = "우리 가게",
    required this.storeCategory,
    this.storeImageMain = "",
    this.openingTime = "09:00:00",
    this.closingTime = "23:00:00",
    this.lastOrderTime = "21:00:00",
    this.startBreakTime = "15:00:00",
    this.endBreakTime = "16:00:00",
    required this.menuCategories,
    this.menuInfo,
  });

  factory StoreData.fromJson(Map<String, dynamic> json) {
    List<Menu> menuList = (json['menuInfo'] as List)
      .map((menuJson) => Menu.fromJson(menuJson))
      .toList();
    Map<String, String?> categoriesMap = LinkedHashMap(); // LinkedHashMap으로 선언합니다.
    List<String> keys = json['menuCategories'].keys.toList()..sort(); // 키를 정렬합니다.

    for (var key in keys) {
      var value = json['menuCategories'][key];
      if (value is! int) {
        categoriesMap[key] = value; 
      }
    }

    return StoreData(
      storeCode: json['storeCode'],
      storeName: json['storeName'],
      storeInfoVersion: json['storeInfoVersion'],
      storeIntroduce: json['storeIntroduce'],
      storeCategory: json['storeCategory'],
      storeImageMain: json['storeImageMain'],
      openingTime: json['openingTime'],
      closingTime: json['closingTime'],
      lastOrderTime: json['lastOrderTime'],
      startBreakTime: json['startBreakTime'],
      endBreakTime: json['endBreakTime'],
      menuCategories: categoriesMap,
      menuInfo: menuList,
    );
  }
}
