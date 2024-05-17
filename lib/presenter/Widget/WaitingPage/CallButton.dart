import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/provider/Data/waitingDataProvider.dart';
import 'package:orre_manager/provider/WidgetProvider/CallButtonProvider.dart';
import 'package:orre_manager/provider/WidgetProvider/WaitingTimerProvider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/provider/Data/waitingDataProvider.dart';
import 'package:orre_manager/provider/WidgetProvider/CallButtonProvider.dart';
import 'package:orre_manager/provider/WidgetProvider/WaitingTimerProvider.dart';

class CallIconButton extends ConsumerWidget {
  final int waitingNumber;
  final int storeCode;
  final int minutesToAdd;
  final String phoneNumber;
  final WidgetRef ref;

  CallIconButton({
    required this.waitingNumber,
    required this.storeCode,
    required this.minutesToAdd,
    Key? key,
    required this.ref,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPressed = ref.watch(callButtonProvider(waitingNumber));

    return Row(
      children: [
        isPressed
            ? TimerWidget(minutesToAdd: minutesToAdd)
            : IconButton(
                icon: Icon(
                  Icons.notifications,
                  color: Color(0xFF72AAD8),
                ),
                iconSize: 30,
                onPressed: () async {
                  if(true == await ref.read(waitingProvider.notifier).requestUserCall(
                    ref,phoneNumber,waitingNumber,storeCode,minutesToAdd)
                  ){
                    ref.read(callButtonProvider(waitingNumber).notifier).pressButton(); // 상태 변경
                  }
                },
              ),
      ],
    );
  }
}
