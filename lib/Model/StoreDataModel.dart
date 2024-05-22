import 'dart:collection';
import 'dart:convert';
import 'package:orre_manager/Model/MenuDataModel.dart'; // 이 경로는 실제 프로젝트의 구조에 따라 조정하세요.

class StoreData {
  final int storeCode;
  final String storeName;
  int waitingAvailable;
  final int storeInfoVersion;
  final String storeIntroduce;
  final String storeCategory;
  final String storeImageMain;
  final String openingTime;
  final String closingTime;
  final String lastOrderTime;
  String? startBreakTime;
  String? endBreakTime;
  final Map<String, String?> menuCategories;  // String 대신 String? 사용
  List<Menu>? menuInfo;

  StoreData({
    required this.storeCode,
    required this.storeName,
    required this.waitingAvailable,
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
      waitingAvailable: json['waitingAvailable'],
      storeInfoVersion: json['storeInfoVersion'],
      storeIntroduce: json['storeIntroduce'],
      storeCategory: json['storeCategory'],
      storeImageMain: json['storeImageMain'],
      openingTime: json['openingTime'] ?? '18:00:00',
      closingTime: json['closingTime'] ?? '24:00:00',
      lastOrderTime: json['lastOrderTime'] ?? '22:30:00',
      startBreakTime: json['startBreakTime'] ?? '21:00:00',
      endBreakTime: json['endBreakTime'] ?? '21:10:00',
      menuCategories: categoriesMap, 
      menuInfo: menuList,
    );
  }
}

// {
//     "storeCode": 1,
//     "storeName": "낭만단대",
//     "storePhoneNumber": "03100000000",
//     "storeInfoVersion": 0,
//     "waitingAvailable": 1,
//     "numberOfTeamsWaiting": 25,
//     "estimatedWaitingTime": 125,
//     "storeImageMain": "https://cdn.imweb.me/thumbnail/20230713/2b7c2700fded1.jpg",
//     "storeIntroduce": "단국대 앞 분위기 최고 맛집",
//     "storeCategory": "일식",
//     "openingTime": "11:00:00",
//     "closingTime": "02:00:00",
//     "lastOrderTime": "01:00:00",
//     "startBreakTime": "15:00:00",
//     "endBreakTime": "16:00:00",
//     "menuInfo": [
//         {
//             "menu": "김초밥(후토마끼)",
//             "price": 18000,
//             "menuCode": "A001",
//             "available": 0,
//             "recommend": 0,
//             "img": "https://ak-d.tripcdn.com/images/1i6502215c53edan545B8.jpg?proc=source/trip",
//             "introduce": "한입에 먹으면 복이 와르르!"
//         },
//         {
//             "menu": "김초밥(후토마끼) 반줄",
//             "price": 9000,
//             "menuCode": "A002",
//             "available": 1,
//             "recommend": 0,
//             "img": "https://orre.s3.ap-northeast-2.amazonaws.com/storeCode/1/A/A002.jpg",
//             "introduce": "소식좌들을 위한 후토마끼"
//         },
//         {
//             "menu": "명란크림파스타",
//             "price": 9900,
//             "menuCode": "A006",
//             "available": 0,
//             "recommend": 1,
//             "img": "https://mblogthumb-phinf.pstatic.net/MjAyMDA0MDZfNzkg/MDAxNTg2MTM5MzY0Njk2.4iWb2tiEEaZ25G54uBh9Wcr9ZkDhx2y44_au6rxLHHkg.Xptz_iTi9q0FK9v4zmX98-y_5_RLhpJwyOCA34v_3C8g.JPEG.ghdtkaehddl/%EB%AA%85%EB%9E%80%ED%81%AC%EB%A6%BC%ED%8C%8C%EC%8A%A4%ED%83%80_(23).JPG?type=w800",
//             "introduce": "명란이 통째로 들어간 명란크림파스타"
//         },
//         {
//             "menu": "복분자",
//             "price": 5500,
//             "menuCode": "X009",
//             "available": 1,
//             "recommend": 1,
//             "img": "https://i.namu.wiki/i/AmujFJklrLw3fD_5uvbf9cOI3QN_0VqJNGu3BNjuikJtXZSe-4HmhWbovGIpmti1BHpMnvd49-Cgi__FXDjewg.webp",
//             "introduce": "남자에게 좋은 복분자"
//         },
//         {
//             "menu": "스키야키",
//             "price": 20000,
//             "menuCode": "C007",
//             "available": 1,
//             "recommend": 1,
//             "img": "https://i.namu.wiki/i/EB-nlQ89EJMbDkEBLsQHXm1KilS6Z6W6aNLXkurk4SYa9PqBaJ9ArP5w6LaQgH3sfkp1Du_6Ge4ncTxMcLWBGg.webp",
//             "introduce": "스키야키 스키?"
//         },
//         {
//             "menu": "참이슬",
//             "price": 5000,
//             "menuCode": "X001",
//             "available": 1,
//             "recommend": 0,
//             "img": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRTq6vCZdWIEj0iCUAN_sfQA_Kcz7i2eQomjmgHxrxRQ0zIl-qYVGTayDPXObxFZF_0PXo&usqp=CAU",
//             "introduce": "소주 먹다보면 너네집 주소"
//         }
//     ],
//     "locationInfo": [
//         {
//             "storeName": "낭만단대",
//             "latitude": 37.324729,
//             "longitude": 127.125603,
//             "address": "경기도 용인시 수지구 죽전로 163"
//         }
//     ],
//     "menuCategories": {
//         "storeCode": 1,
//         "h": null,
//         "b": "작은접시",
//         "a": "큰접시",
//         "c": "국물요리",
//         "e": null,
//         "f": null,
//         "d": null,
//         "g": null,
//         "q": null,
//         "j": null,
//         "x": "주류",
//         "w": null,
//         "t": null,
//         "v": null,
//         "s": "서비스",
//         "n": null,
//         "m": null,
//         "k": null,
//         "p": null,
//         "l": null,
//         "o": null,
//         "r": null,
//         "u": null,
//         "i": null,
//         "y": null,
//         "z": null
//     }
// }
