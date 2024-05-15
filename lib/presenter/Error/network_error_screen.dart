import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/presenter/Widget/alertDialog.dart';
import 'package:orre_manager/provider/Network/connectivityStateNotifier.dart';

class NetworkErrorScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // showAlertDialog(context, "네트워크 오류", '네트워크 정보를 불러오는데 실패했습니다.', ref.refresh(networkStreamProvider));

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('네트워크 정보를 불러오는데 실패했습니다.'),
            ElevatedButton(
              onPressed: () => ref.refresh(networkStreamProvider),
              child: Text('다시 시도하기'),
            ),
          ],
        ),
      ),
    );
  }
}
