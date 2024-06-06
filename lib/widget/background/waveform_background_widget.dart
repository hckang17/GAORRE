import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WaveformBackgroundWidget extends ConsumerWidget {
  final Color backgroundColor;
  final Widget child;

  const WaveformBackgroundWidget(
      {Key? key, required this.child, this.backgroundColor = Colors.white})
      : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        Container(
          color: backgroundColor,
        ),
        Image.asset(
          "assets/image/waveform/wave_shadow.png",
          width: MediaQuery.sizeOf(context).width,
          fit: BoxFit.cover,
        ),
        Image.asset(
          "assets/image/waveform/wave.png",
          width: MediaQuery.sizeOf(context).width,
          fit: BoxFit.cover,
        ),
        child,
      ],
    );
  }
}
