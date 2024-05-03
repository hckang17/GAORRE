import 'package:flutter/material.dart';

void showAlertDialog(BuildContext context, String title, String content, Function? effect){
  showDialog(
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