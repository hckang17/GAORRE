import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaorre/Model/WaitingDataModel.dart';
import 'package:gaorre/provider/Data/waitingDataProvider.dart';
import 'package:gaorre/provider/WidgetProvider/CallButtonProvider.dart';
import 'package:gaorre/provider/WidgetProvider/WaitingTimerProvider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaorre/provider/Data/waitingDataProvider.dart';
import 'package:gaorre/provider/WidgetProvider/CallButtonProvider.dart';
import 'package:gaorre/provider/WidgetProvider/WaitingTimerProvider.dart';

class CallIconButton extends ConsumerWidget {
  final WaitingTeam waitingTeam;
  final int storeCode;
  final int minutesToAdd;
  final String phoneNumber;
  final WidgetRef ref;
  bool isPressed = false;

  CallIconButton({
    required this.waitingTeam,
    required this.storeCode,
    required this.minutesToAdd,
    Key? key,
    required this.ref,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final isPressed = ref.watch(callButtonProvider(waitingTeam.waitingNumber));
    final DateTime? entryTime = waitingTeam.entryTime;

    return Row(
      children: [
        entryTime != null
            ? TimerWidget(
                minutesToAdd: minutesToAdd,
                waitingNumber: waitingTeam.waitingNumber)
            : IconButton(
                icon: Icon(
                  Icons.notifications,
                  color: Color(0xFF72AAD8),
                ),
                iconSize: 30,
                onPressed: () async {
                  if(isPressed){
                    print("이미 CallGuest가 작동중입니다.");
                    return;
                  }else{
                    isPressed = true;
                  }
                  if (true ==
                    await ref.read(waitingProvider.notifier).requestUserCall(
                      ref,
                      phoneNumber,
                      waitingTeam.waitingNumber,
                      storeCode,
                      minutesToAdd)) {
                    ref.read(callButtonProvider(waitingTeam.waitingNumber).notifier).pressButton(); // 상태 변경
                  }
                  isPressed = false;
                },
              ),
      ],
    );
  }
}
