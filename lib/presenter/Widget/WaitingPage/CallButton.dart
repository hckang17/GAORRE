import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../provider/WidgetProvider/call_button_provider.dart';
import '../../../provider/DataProvider/waiting_provider.dart';

class CallIconButton extends ConsumerWidget {
  final int waitingNumber;
  final int storeCode;
  final int minutesToAdd;
  final String phoneNumber;
  final WidgetRef ref;

  CallIconButton({
    required this.phoneNumber,
    required this.waitingNumber,
    required this.storeCode,
    required this.minutesToAdd,
    Key? key, 
    required this.ref,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPressed = ref.watch(callButtonProvider(waitingNumber));

    return IconButton(
      icon: Icon(isPressed ? Icons.call : Icons.call_outlined),
      onPressed: () {
        ref.read(callButtonProvider(waitingNumber).notifier).pressButton();  // 상태 변경
        ref.read(waitingProvider.notifier).requestUserCall(
              context,
              phoneNumber,
              waitingNumber,
              storeCode,
              minutesToAdd,
            );
      },
      color: isPressed ? Colors.green : Colors.grey,
    );
  }
}