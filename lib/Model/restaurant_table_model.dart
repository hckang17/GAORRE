import 'package:orre_manager/Model/guest_data_model.dart';
import 'package:orre_manager/Model/orderList_data.dart';

class RestaurantTable {
  final List<Seat> table;

  RestaurantTable({
    required this.table,
  });

  factory RestaurantTable.fromJson(List<dynamic> json) {
    var tables = json.map((tableJson) => Seat.fromJson(tableJson)).toList();

    return RestaurantTable(
      table: tables,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'table': table.map((seat) => seat.toJson()).toList(),
    };
  }
}

class Seat {
  final int tableNumber;
  final int maxPersonPerTable;
  int tableStatus; /** tableStatus = 0 : 1 / now lock : now unlock */
  // 0 = 락 , 1 = 착석중
  Guest? guestInfo;
  OrderList? orderInfo;
  // 메뉴도 여기다가 추가해야지..
  
  Seat({
    required this.tableNumber,
    required this.maxPersonPerTable,
    required this.tableStatus,
    this.guestInfo,
    this.orderInfo,
  });

  void setSeatsGuest(Guest guestInfo){
    this.guestInfo = guestInfo;
  }

  void setOrderInfo(OrderList orderInfo){
    this.orderInfo = orderInfo;
  }

  factory Seat.fromJson(Map<String, dynamic> json) {
    if(json['tableAvailable'] == 1){
      return Seat(
        tableNumber: json['tableNumber'],
        maxPersonPerTable: json['tablePersonNumber'], // JSON 데이터에 있는 'tablePersonNumber' 값을 'maxPersonPerTable'에 할당
        tableStatus: json['tableAvailable'],
      );
    } else {
      return Seat(
        tableNumber: json['tableNumber'],
        maxPersonPerTable: json['tablePersonNumber'], // JSON 데이터에 있는 'tablePersonNumber' 값을 'maxPersonPerTable'에 할당
        tableStatus: json['tableAvailable'],
    );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'tableNumber': tableNumber,
      'maxPersonPerTable': maxPersonPerTable,
      'tableStatus': tableStatus,
      'guestInfo': guestInfo?.toJson(), // Assuming Guest class has a toJson method
      'orderInfo': orderInfo?.toJson(), // Assuming OrderList class has a toJson method
    };
  }
}
