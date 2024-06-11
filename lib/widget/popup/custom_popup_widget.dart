import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaorre/widget/button/pop_button_widget.dart';
import 'package:gaorre/widget/text/text_widget.dart';

class CustomPopupDialog extends ConsumerWidget {
  final String title;
  final Widget content;
  final String mainBtnText;
  final Function mainBtnFunc;
  final Color? mainBtnColor;
  final String? subBtnText;
  final Function? subBtnFunc;
  final Color? subBtnColor;
  final bool isSubBtn;
  final bool isCloseBtn;

  CustomPopupDialog({
    required this.title,
    required this.content,
    required this.mainBtnText,
    required this.mainBtnFunc,
    this.mainBtnColor,
    required this.subBtnText,
    required this.subBtnFunc,
    this.subBtnColor,
    this.isSubBtn = true,
    this.isCloseBtn = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      elevation: 0,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: [
                TextWidget(
                  title,
                ),
                Spacer(),
                if (isCloseBtn) PopButtonWidget(),
              ],
            ),
            SizedBox(height: 16.h),
            content,
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                if (isSubBtn)
                  TextButton(
                    onPressed: () {
                      subBtnFunc!();
                    },
                    child: TextWidget(
                      subBtnText!,
                      color: subBtnColor ?? Colors.grey,
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        subBtnColor ?? Colors.transparent,
                      ),
                    ),
                  ),
                TextButton(
                  onPressed: () {
                    mainBtnFunc();
                  },
                  child: TextWidget(
                    mainBtnText,
                    color: Colors.white,
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      mainBtnColor ?? Color(0xFF72AAD8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
