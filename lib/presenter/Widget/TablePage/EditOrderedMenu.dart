import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaorre/provider/Data/loginDataProvider.dart';
import 'package:gaorre/provider/Data/storeDataProvider.dart';
import 'package:gaorre/provider/Data/tableDataProvider.dart';

void showEditOrderedMenu(
    BuildContext context, String menuName, int amount, int tableNumber) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: EditOrderedMenuForm(
            menuName: menuName,
            initialAmount: amount,
            tableNumber: tableNumber),
      );
    },
  );
}

class EditOrderedMenuForm extends ConsumerWidget {
  final String menuName;
  final int initialAmount;
  final int tableNumber;

  EditOrderedMenuForm(
      {Key? key,
      required this.menuName,
      required this.initialAmount,
      required this.tableNumber})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final amountProvider = StateProvider<int>((ref) => initialAmount);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(menuName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Amount:', style: TextStyle(fontSize: 18)),
              Consumer(
                builder: (context, ref, child) {
                  final amount = ref.watch(amountProvider);
                  return Text('$amount', style: TextStyle(fontSize: 18));
                },
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => ref
                    .read(amountProvider.notifier)
                    .update((state) => state + 1),
              ),
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () => ref
                    .read(amountProvider.notifier)
                    .update((state) => state != 0 ? state - 1 : 0),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () async {
                // 이 부분에 '반영하기' 버튼의 로직을 구현합니다.
                // 예를 들어, 변경된 amount를 서버에 저장하는 코드 등을 포함할 수 있습니다.
                final int payload =
                    ref.read(amountProvider.notifier).state - initialAmount;
                final String menuCode =
                    ref.read(storeDataProvider.notifier).getMenuCode(menuName);
                if (true ==
                    await ref.read(tableProvider.notifier).editOrderedList(
                        ref.context,
                        ref.read(loginProvider.notifier).getLoginData()!,
                        menuCode,
                        payload,
                        tableNumber)) {
                  await ref.read(tableProvider.notifier).requestTableOrderList(
                      ref
                          .read(loginProvider.notifier)
                          .getLoginData()!
                          .storeCode,
                      tableNumber);

                  Navigator.of(context).pop(); // 다이얼로그를 닫습니다.
                }
              },
              child: Text('반영하기'),
            ),
            TextButton(
              onPressed: () {
                // '취소하기' 버튼은 다이얼로그를 닫습니다.
                Navigator.of(context).pop();
              },
              child: Text('취소하기'),
            ),
          ],
        )
      ],
    );
  }
}
