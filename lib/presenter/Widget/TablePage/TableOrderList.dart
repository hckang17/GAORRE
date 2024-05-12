import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/Model/restaurant_table_model.dart';

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
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('주문 내역', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('총 주문 금액: ${widget.table.orderInfo!.totalPrice}원'),
          SizedBox(height: 10),
          Container(
            height: 200, // 주문 항목 리스트의 높이 제한
            child: ListView.builder(
              itemCount: widget.table.orderInfo!.orderedItemList?.length ?? 0,
              itemBuilder: (context, index) {
                var item = widget.table.orderInfo!.orderedItemList![index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('상품명: ${item.menuName}', style: TextStyle(fontSize: 16)),
                    Text('수량: ${item.amount}', style: TextStyle(fontSize: 16)),
                    Text('가격: ${item.price}원', style: TextStyle(fontSize: 16)),
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
