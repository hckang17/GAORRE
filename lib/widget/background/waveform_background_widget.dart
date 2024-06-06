import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

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
        SvgPicture.asset(
            "assets/image/waveform/gaorre_wave_shadow.svg",
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
        ),
        SvgPicture.asset(
            "assets/image/waveform/gaorre_wave.svg",
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
        ),
        child,
      ],
    );
  }
}
