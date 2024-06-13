import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaorre/provider/Network/stompClientStateNotifier.dart';
import 'package:gaorre/widget/text/text_widget.dart';

class WebsocketErrorScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final stomp = ref.watch(stompClientStateNotifierProvider);
    // final stompStack = ref.watch(stompErrorStack);
    // final networkError = ref.watch(networkStateProvider);
    final websocketStatus = ref.watch(stompState);

    // print("ServerErrorScreen : $stompStack");
    // 네트워크 연결은 정상이나 웹소켓 연결을 5번 이상 실패했을 경우
    // if (stompStack > 5 && networkError == true) {
    //   // 서버 에러로 판단하여 서버 에러 화면으로 이동
    //   Navigator.pushReplacement(context,
    //       MaterialPageRoute(builder: (context) => ServerErrorScreen()));
    // } else {
    //   print("다시 시도하기");
    //   ref.read(stompClientStateNotifierProvider.notifier).configureClient();
    // }
    if (websocketStatus == StompStatus.CONNECTED) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
      });
    }

    return WillPopScope(
        onWillPop: () async => false, // 물리적 뒤로 가기 버튼 비활성화
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextWidget('웹소켓을 불러오는데 실패했습니다.'),
                TextWidget('웹소켓이 연결되면 자동으로 닫힙니다.'),
              ],
            ),
          ),
        ));
  }
}
