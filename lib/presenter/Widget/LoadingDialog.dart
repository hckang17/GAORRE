import 'dart:async';

import 'package:flutter/material.dart';
import 'package:orre_manager/widget/text/text_widget.dart';

void showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // 사용자가 다이얼로그 바깥을 눌러도 닫히지 않도록 설정
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async => false, // Android 뒤로가기 버튼 비활성화
        child: LoadingDialog(),
      );
    },
  );
}

class LoadingDialog extends StatefulWidget {
  @override
  _LoadingDialogState createState() => _LoadingDialogState();
}

class _LoadingDialogState extends State<LoadingDialog> {
  int dotCount = 1;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      setState(() {
        dotCount = (dotCount % 5) + 1;
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String textToShow = '로딩중입니다${"." * dotCount}';

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          TextWidget(textToShow),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Center(
  //     child: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         CircularProgressIndicator(),
  //         SizedBox(height: 16),
  //         Text(
  //           '로딩중입니다' + '.'*dotCount,
  //           style: TextStyle(
  //             color: Color.fromARGB(255, 0, 0, 0),
  //             fontSize: 16,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}