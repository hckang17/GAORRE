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

Future<bool> showConfirmDialogWithConfirmText(BuildContext context, String title, String content) async {
  TextEditingController _textEditingController = TextEditingController();
  String confirmText = "GAORRE";
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('$content'),
            Text('정말로 진행하시려면 검증문자 입력창에 \'$confirmText\'를 정확히 입력해주세요.'),
            TextField(
              controller: _textEditingController,
              decoration: InputDecoration(
                hintText: "검증문자를 입력하세요",
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text("취소"),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: Text("확인"),
            onPressed: () {
              if (_textEditingController.text == confirmText) {
                Navigator.of(context).pop(true);
              } else {
                Navigator.of(context).pop(false);
              }
            },
          ),
        ],
      );
    },
  ) ?? false; // 사용자가 대화상자 밖을 클릭하여 대화상자를 닫은 경우 false를 반환
}