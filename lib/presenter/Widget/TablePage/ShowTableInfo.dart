import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaorre/Model/LoginDataModel.dart';
import 'package:gaorre/Model/RestaurantTableModel.dart';
import 'package:gaorre/presenter/Widget/TablePage/TableOrderList.dart';
import 'package:gaorre/presenter/Widget/TablePage/TableStatus.dart';

void showTableInfoPopup(
    WidgetRef ref, BuildContext context, Seat table, LoginData loginData) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // 스크롤 조절이 가능하도록 설정
    builder: (BuildContext context) {
      return Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Wrap(
          children: [
            TableInfoWidget(loginData: loginData, table: table),
            if (table.orderInfo != null && table.tableStatus == 1)
              OrderInfoWidget(table: table),
          ],
        ),
      );
    },
  );
}
