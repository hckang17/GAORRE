import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/Model/restaurant_table_model.dart';
import 'package:orre_manager/presenter/Widget/TablePage/EditOrderedMenu.dart';
import 'package:orre_manager/provider/DataProvider/table_provider.dart';

class OrderInfoWidget extends ConsumerStatefulWidget {
  final Seat table;

  const OrderInfoWidget({
    Key? key,
    required this.table,
  }) : super(key: key);

  @override
  _OrderInfoWidgetState createState() => _OrderInfoWidgetState();
}

class _OrderInfoWidgetState extends ConsumerState<OrderInfoWidget> {
  late Seat currentSeat;

  @override
  void initState() {
    super.initState();
    currentSeat = widget.table;
  }

  void updateSeatInfo() {
    final Seat updatedSeat = ref.read(tableProvider.notifier).getSeatByNumberSeat(widget.table.tableNumber);
    if (updatedSeat != null && updatedSeat != currentSeat) {
      print('current싯 갱신할거야!');
      print('갱신할 시트 정보..... 제발 되라 ${updatedSeat.orderInfo.toString()}');
      setState(() {
        currentSeat = updatedSeat;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(tableProvider);
    updateSeatInfo(); // Update seat information based on the current table number

    print('다시든 처음이든 빌드 됐음 ㅇㅇ');

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('주문 내역', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('총 주문 금액: ${currentSeat.orderInfo!.totalPrice}원'),
          SizedBox(height: 10),
          ElevatedButton(
            child: Text('테스트'), 
            onPressed: () {
              print('주문내역 표시...\n${currentSeat.orderInfo.toString()}');
            }
          ),
          SizedBox(height: 10),
          Container(
            height: 200, // Limit the height of the order item list
            child: ListView.builder(
              itemCount: currentSeat.orderInfo!.orderedItemList?.length ?? 0,
              itemBuilder: (context, index) {
                var item = currentSeat.orderInfo!.orderedItemList![index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text('상품명: ${item.menuName}', style: TextStyle(fontSize: 16)),
                        ),
                        Expanded(
                          child: Text('수량: ${item.amount}', style: TextStyle(fontSize: 16)),
                        ),
                        Expanded(
                          child: Text('가격: ${item.price}원', style: TextStyle(fontSize: 16)),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: ElevatedButton(
                            onPressed: () {
                              showEditOrderedMenu(context, item.menuName, item.amount.toInt(), currentSeat.tableNumber);
                            },
                            child: Text('메뉴 수정하기'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white, backgroundColor: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}