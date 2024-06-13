import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PopButtonWidget extends ConsumerWidget {
  final double width;
  final double height;
  final Color backgroundColor;
  final Color iconColor;
  final double borderRadius;

  const PopButtonWidget({
    Key? key,
    this.width = 30,
    this.height = 30,
    this.backgroundColor = const Color(0xFF72AAD8),
    this.iconColor = Colors.white,
    this.borderRadius = 15,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: IconButton(
        icon: Icon(Icons.close),
        color: iconColor,
        padding: EdgeInsets.zero,
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
