import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/presenter/Widget/AlertDialog.dart';
import 'package:orre_manager/provider/Network/connectivityStateNotifier.dart';
import 'package:orre_manager/provider/Network/stompClientStateNotifier.dart';
import 'package:orre_manager/widget/button/text_button_widget.dart';
import 'package:orre_manager/widget/text/text_widget.dart';

class NetworkErrorScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextWidget('네트워크 정보를 불러오는데 실패했습니다.'),
            TextButtonWidget(
              onPressed: () {
                if(ref.read(networkStateProvider)){
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    ref.refresh(stompClientStateNotifierProvider.notifier).configureClient();
                  });
                }
                // ref.read(networkStateProvider).listen((event) {
                //   if (event) {
                //     WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
                //       ref.refresh(stompClientStateNotifierProvider.notifier);
                //     });
                //   }
                // });
              },
              text: '다시 시도하기',
            ),
          ],
        ),
      ),
    );
  }
}
