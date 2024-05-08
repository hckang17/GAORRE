class Menu {
  final String menuName;
  final String menuCode;
  final int price;
  final String menuInfo;
  String menuImageURL;
  int recommend;  // 0 : 추천안함, 1 : 추천함
  int isAvailable;  // 0 : 주문불가, 1 : 주문가능

  Menu({
    required this.menuName,
    required this.menuCode,
    required this.price,
    required this.menuInfo,
    this.menuImageURL = "",
    this.recommend = 0,
    this.isAvailable = 1,
  });
}