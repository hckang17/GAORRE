import 'package:flutter/material.dart';

Future<void> showAlertDialog(BuildContext context, String title, String content, Function? effect) async {
  await showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('확인'),
          )
        ]
      );
    }
  );
}