// import 'package:flutter/material.dart';

// class Table {
//   final int maximumPeople;
//   int tableStatus;
//   String? userCode;
//   List<Menu> orderList;

//   Table({
//     required this.maximumPeople,
//     required this.tableStatus,
//     this.userCode,
//     this.orderList = const [],
//   });
// }

// class Menu {
//   final String name;
//   final double price;

//   Menu({required this.name, required this.price});
// }

// // RestaurantTable 위젯 정의
// class RestaurantTable extends StatelessWidget {
//   const RestaurantTable({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // 레스토랑 테이블 위젯에서는 여러 개의 테이블을 배치할 것이므로 ListView.builder 사용
//     return ListView.builder(
//       itemCount: 8, // 8개의 테이블을 배치
//       itemBuilder: (BuildContext context, int index) {
//         // 테이블 위젯 반환
//         return TableWidget(
//           table: Table(
//             maximumPeople: 4, // 테이블에 대한 정보 설정
//             tableStatus: 0,
//             orderList: [
//               Menu(name: 'Menu 1', price: 10.0),
//               Menu(name: 'Menu 2', price: 15.0),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   static RestaurantTable fromJson(List responseData) {}
// }

// // Table 위젯 정의
// class TableWidget extends StatelessWidget {
//   final Table table;

//   TableWidget({required this.table});

//   @override
//   Widget build(BuildContext context) {
//     // 테이블 정보를 기반으로 위젯을 구성
//     return Container(
//       margin: EdgeInsets.all(10),
//       padding: EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         border: Border.all(),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('Maximum People: ${table.maximumPeople}'),
//           Text('Table Status: ${table.tableStatus}'),
//           Text('User Code: ${table.userCode ?? 'No user'}'),
//           Text('Order List:'),
//           // 주문 목록을 표시
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: table.orderList
//                 .map((menu) => Text('${menu.name} - \$${menu.price}'))
//                 .toList(),
//           ),
//         ],
//       ),
//     );
//   }
// }