class OrderList {
  final int tableNumber;
  final int storeCode;
  final int totalPrice;
  final List<OrderedMenu>? orderedItemList;

  OrderList({
    required this.tableNumber,
    required this.storeCode,
    required this.totalPrice,
    required this.orderedItemList,
  });

  factory OrderList.fromJson(Map<String, dynamic> json) {
    var orderedItemList = json['orderItems'] as List;
    List<OrderedMenu> itemList = orderedItemList.map((itemJson) => OrderedMenu.fromJson(itemJson)).toList();
    return OrderList(
      storeCode: json['storeCode'],
      tableNumber: json['tableNumber'],
      totalPrice: json['totalPrice'],
      orderedItemList : itemList,
    );
  }
}

class OrderedMenu {
  final String menuName;
  final int price;
  final int amount;

  OrderedMenu({
    required this.menuName,
    required this.price,
    required this.amount,
  });

  factory OrderedMenu.fromJson(Map<String, dynamic> json){
    return OrderedMenu(
      menuName: json['menuName'],
      price: json['price'],
      amount: json['amount'],
    );
  }
}
// {
//     "status": "200",
//     "storeCode": 1,
//     "tableNumber": 1,
//     "totalPrice": 134800,
//     "orderItems": [
//         {
//             "menuName": "김초밥(후토마끼)",
//             "price": 18000,
//             "amount": 5
//         },
//         {
//             "menuName": "명란크림파스타",
//             "price": 9900,
//             "amount": 2
//         },
//         {
//             "menuName": "스키야키",
//             "price": 20000,
//             "amount": 1
//         },
//         {
//             "menuName": "참이슬",
//             "price": 5000,
//             "amount": 1
//         }
//     ]
// }