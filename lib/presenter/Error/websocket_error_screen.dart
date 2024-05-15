import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/provider/Network/stompClientStateNotifier.dart';

class WebsocketErrorScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final stomp = ref.watch(stompClientStateNotifierProvider);
    Future.delayed(Duration(milliseconds: 0),
        () => ref.read(stompClientStateNotifierProvider.notifier).reconnect());
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('웹소켓을 불러오는데 실패했습니다.'),
            ElevatedButton(
              onPressed: () => ref
                  .read(stompClientStateNotifierProvider.notifier)
                  .reconnect(),
              child: Text('다시 시도하기'),
            ),
          ],
        ),
      ),
    );
  }
}
