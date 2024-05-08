import 'dart:convert';
import 'package:orre_manager/Model/menu_data_model.dart';

class StoreData {
  final int storeCode;
  final String storeName;
  int storeInfoVersion; // 얜 뭐임?
  String storeIntroduce;
  final String storeCategory;
  String storeImageMain;
  String openingTime = "11:00:00";
  String closingTime = "24:00:00";
  String lastOrderTime = "23:00:00";
  List<Menu>? menuInfo;

  StoreData({
    required this.storeCode,
    required this.storeName,
    required this.storeInfoVersion,
    required this.storeIntroduce,
    required this.storeCategory,
    required this.storeImageMain,
    required this.openingTime,
    required this.closingTime,
    required this.lastOrderTime,
    this.menuInfo,
  });
}

