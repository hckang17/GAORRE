import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaorre/provider/Data/waitingDataProvider.dart';

class TimerWidget extends ConsumerStatefulWidget {
  final int minutesToAdd;
  final int waitingNumber;

  TimerWidget({required this.minutesToAdd, required this.waitingNumber});

  @override
  _TimerWidgetState createState() => _TimerWidgetState();
}

class _TimerWidgetState extends ConsumerState<TimerWidget> {
  late Timer _timer;
  late Duration _remainingTime;
  late String _timerText;
  String? _imagePath;
  late int waitingNumber;

  @override
  void initState() {
    super.initState();
    var index = ref
        .read(waitingProvider.notifier)
        .getWaitingData()!
        .teamInfoList
        .indexWhere((team) => team.waitingNumber == widget.waitingNumber);
    final entryTime = ref
        .read(waitingProvider.notifier)
        .getWaitingData()!
        .teamInfoList[index]
        .entryTime!;
    _remainingTime = entryTime.difference(DateTime.now());
    _timerText = formatTime(_remainingTime);
    _imagePath = 'assets/image/timer_images/timer1.png';
    _startTimer();
  }

  // MM:SS 형태로 포맷팅하는 함수
  String formatTime(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    const oneSecond = Duration(seconds: 1);
    _timer = Timer.periodic(oneSecond, (timer) {
      if (_remainingTime.inSeconds > 0) {
        setState(() {
          _remainingTime -= oneSecond;
          _timerText = formatTime(_remainingTime);
          _updateImagePath();
        });
      } else {
        _timer.cancel();
        setState(() {
          _timerText = 'OUT';
          _imagePath = 'assets/image/timer_images/timer4.png';
        });
      }
    });
  }

  void _updateImagePath() {
    final int quarterTime = widget.minutesToAdd ~/ 4;
    final int halfTime = widget.minutesToAdd ~/ 2;
    final int threeQuarterTime = widget.minutesToAdd * 3 ~/ 4;

    if (_remainingTime.inMinutes <= quarterTime) {
      _imagePath = 'assets/image/timer_images/timer4.png';
    } else if (_remainingTime.inMinutes <= halfTime) {
      _imagePath = 'assets/image/timer_images/timer3.png';
    } else if (_remainingTime.inMinutes <= threeQuarterTime) {
      _imagePath = 'assets/image/timer_images/timer2.png';
    } else {
      _imagePath = 'assets/image/timer_images/timer1.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_imagePath != null)
          Image.asset(
            _imagePath!,
            width: 40,
            height: 40,
          ),
        SizedBox(height: 5),
        Text(
          _timerText,
          style: TextStyle(
            fontFamily: 'Dovemayo_gothic',
            fontSize: 20,
          ),
        ),
      ],
    );
  }
}
