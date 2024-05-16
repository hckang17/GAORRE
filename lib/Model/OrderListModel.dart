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

  Map<String, dynamic> toJson() {
    return {
      'storeCode': storeCode,
      'tableNumber': tableNumber,
      'totalPrice': totalPrice,
      'orderedItemList': orderedItemList?.map((item) => item.toJson()).toList(),
    };
  }

  @override
  String toString() {
    String returnValue = '주문내역 : ';

    if (orderedItemList != null) {
      for (var item in orderedItemList!) {
        returnValue += '품목 : ${item.menuName} 의 수량 : ${item.amount}, ';
      }
    }

    // 마지막 쉼표와 공백 제거
    if (returnValue.endsWith(', ')) {
      returnValue = returnValue.substring(0, returnValue.length - 2);
    }

    return returnValue;
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

  Map<String, dynamic> toJson() {
    return {
      'menuName': menuName,
      'price': price,
      'amount': amount,
    };
  }
}