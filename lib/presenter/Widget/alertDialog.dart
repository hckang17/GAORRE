import 'package:flutter/material.dart';
import 'package:orre_manager/widget/popup.dart';

Future<void> showAlertDialog(BuildContext context, String title, String content, Function? effect) async {
  await showDialog<void>(
    context: context,
    builder: (context) {
      return CustomAlertDialog(
        context: context,
        title: title,
        text: content,
      );
    }
  );
}