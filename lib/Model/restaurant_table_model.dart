import 'package:orre_manager/Model/guest_data_model.dart';

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

}

class Seat {
  final int tableNumber;
  final int maxPersonPerTable;
  int tableStatus;
  // 0 = 사용불가능 , 1 = 사용(착석)가능
  Guest? guestInfo;
  // 메뉴도 여기다가 추가해야지..


  Seat({
    required this.tableNumber,
    required this.maxPersonPerTable,
    required this.tableStatus,
  });

  factory Seat.fromJson(Map<String, dynamic> json) {
    return Seat(
      tableNumber: json['tableNumber'],
      maxPersonPerTable: json['tablePersonNumber'], // JSON 데이터에 있는 'tablePersonNumber' 값을 'maxPersonPerTable'에 할당
      tableStatus: json['tableAvailable'],
    );
  }

}
