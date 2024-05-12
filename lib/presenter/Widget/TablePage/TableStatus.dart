import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/Model/login_data_model.dart';
import 'package:orre_manager/Model/restaurant_table_model.dart';
import 'package:orre_manager/provider/DataProvider/table_provider.dart';

class TableInfoWidget extends ConsumerStatefulWidget {
  final LoginData loginData;
  final Seat table;

  const TableInfoWidget({
    Key? key,
    required this.loginData,
    required this.table,
  }) : super(key: key);

  @override
  _TableInfoWidgetState createState() => _TableInfoWidgetState();
}

class _TableInfoWidgetState extends ConsumerState<TableInfoWidget> {
  final TextEditingController _tempWaitingNumber = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ref.watch(tableProvider);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('테이블 정보', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('테이블 번호: ${widget.table.tableNumber}'),
            Text('테이블 최대 착석 인원: ${widget.table.maxPersonPerTable}'),
            Text('테이블 상태: ${widget.table.tableStatus == 0 ? '미사용중' : '사용중'}'),
            if (widget.table.guestInfo != null)
              Text('손님 정보(디버깅용): ${widget.table.guestInfo.toString()}'),
            SizedBox(height: 10),
            if (widget.table.tableStatus == 0) 
              TextField(
                controller: _tempWaitingNumber,
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
                    if (widget.table.tableStatus == 0) {
                      int waitingNumber = int.tryParse(_tempWaitingNumber.text) ?? 0;
                      ref.read(tableProvider.notifier).sendUnlockRequest(
                          widget.loginData.storeCode, widget.table.tableNumber, waitingNumber, widget.loginData.loginToken!);
                    } else {
                      ref.read(tableProvider.notifier).sendLockRequest(
                          widget.loginData.storeCode, widget.table.tableNumber, widget.loginData.loginToken!);
                    }
                  },
                  child: Text(widget.table.tableStatus == 0 ? '테이블 잠금 해제' : '테이블 잠금'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('닫기'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
