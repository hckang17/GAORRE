class RestaurantTable {
  final List<Table> table;

  RestaurantTable({
    required this.table,
  });

  factory RestaurantTable.fromJson(List<dynamic> json) {
    var tables = json.map((tableJson) => Table.fromJson(tableJson)).toList();

    return RestaurantTable(
      table: tables,
    );
  }


  @override
  String toString(){
    return '${table[0].tableNumber}, ${table[0].maxPersonPerTable}, ${table[0].tableStatus}';
  }
}

class Table {
  final int tableNumber;
  final int maxPersonPerTable;
  int tableStatus = 0;

  Table({
    required this.tableNumber,
    required this.maxPersonPerTable,
    required this.tableStatus,
  });

  factory Table.fromJson(Map<String, dynamic> json) {
    return Table(
      tableNumber: json['tableNumber'],
      maxPersonPerTable: json['tablePersonNumber'], // JSON 데이터에 있는 'tablePersonNumber' 값을 'maxPersonPerTable'에 할당
      tableStatus: json['tableAvailable'],
    );
  }
}
