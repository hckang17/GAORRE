import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/Model/login_data_model.dart';
import 'package:orre_manager/Model/restaurant_table_model.dart';
import 'package:orre_manager/provider/DataProvider/table_provider.dart';


void showTableInfoPopup(WidgetRef ref, BuildContext context, Seat table, LoginData loginData) {
  TextEditingController _temp_waitingNumber = TextEditingController();

  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return ListView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16),
            children: [
              Text('테이블 정보', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text('테이블 번호: ${table.tableNumber}'),
              Text('테이블 최대 착석 인원: ${table.maxPersonPerTable}'),
              Text('테이블 상태: ${table.tableStatus == 0 ? '미사용중' : '사용중'}'),
              if (table.guestInfo != null)
                Text('손님 정보(디버깅용): ${table.guestInfo.toString()}'),
              SizedBox(height: 10),
              if (table.orderInfo != null && table.tableStatus == 1) ...[
                Text('주문 내역', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('총 주문 금액: ${table.orderInfo!.totalPrice}원'),
                SizedBox(height: 10),
                Container(
                  height: 200, // 예시로 높이를 제한했습니다.
                  child: ListView.builder(
                    itemCount: table.orderInfo!.orderedItemList?.length,
                    itemBuilder: (context, index) {
                      var item = table.orderInfo!.orderedItemList?[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('상품명: ${item!.menuName}'),
                          Text('수량: ${item.amount}'),
                          Text('가격: ${item.price}원'),
                          Divider(),
                        ],
                      );
                    },
                  ),
                ),
              ],
              if (table.tableStatus == 0) 
                TextField(
                  controller: _temp_waitingNumber,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '대기번호 입력',
                  ),
                ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (table.tableStatus == 0) {
                        int waitingNumber =
                            int.tryParse(_temp_waitingNumber.text) ?? 0;
                        ref.read(tableProvider.notifier).sendUnlockRequest(
                            loginData.storeCode, table.tableNumber, waitingNumber, loginData.loginToken!);
                      } else {
                        ref.read(tableProvider.notifier).sendLockRequest(
                            loginData.storeCode, table.tableNumber, loginData.loginToken!);
                      }
                    },
                    child: Text(table.tableStatus == 0 ? '테이블 잠금 해제' : '테이블 잠금'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('닫기'),
                  ),
                ],
              ),
            ],
          );
        },
      );
    },
  );
}
