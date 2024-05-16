import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// 사용법 : 원하는 텍스트만 사용하여 팝업을 생성하시면 됩니다^^
// showDialog (
// context : context,
// builder : (context) {
//  return CustomAlertDialog.build(context: context, title : '여기다가 제목^^', text : '여기다가 이쁜 말 써주세요^^');
// }

class CustomConfirmDialog extends StatelessWidget {
  final String title;
  final String text;
  final BuildContext context;

  CustomConfirmDialog({required this.context, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Dovemayo_gothic',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 83, 107, 118),
        ),
      ),
      content: Text(
        text,
        textAlign: TextAlign.center,
        softWrap: true,
        style: TextStyle(
            fontFamily: 'Dovemayo_gothic',
            fontSize: 20,
            color: Color.fromARGB(255, 83, 107, 118)),
      ),
      actions: <Widget>[
        Container(
          width: double.infinity,
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Color(0xFF72AAD8),
              ),
              padding: EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              child: Text(
                '확인',
                style: TextStyle(
                  fontFamily: 'Dovemayo_gothic',
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Color.fromARGB(255, 255, 58, 104),
              ),
              padding: EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              child: Text(
                '취소',
                style: TextStyle(
                  fontFamily: 'Dovemayo_gothic',
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
