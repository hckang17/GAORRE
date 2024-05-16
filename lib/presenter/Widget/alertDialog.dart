import 'package:flutter/material.dart';
import 'package:orre_manager/widget/popup/confirm_popup.dart';
import 'package:orre_manager/widget/popup/popup.dart';

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

Future<bool> showConfirmDialog(BuildContext context, String title, String content) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return CustomConfirmDialog(
        context: context,
        title: title,
        text: content,
      );
    }
  ) ?? false; // 사용자가 대화상자 밖을 클릭하여 대화상자를 닫은 경우 false를 반환
}