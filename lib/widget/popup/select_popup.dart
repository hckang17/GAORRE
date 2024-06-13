import 'package:flutter/material.dart';
import 'package:gaorre/widget/text/text_widget.dart';

// 사용법 : 원하는 텍스트만 사용하여 팝업을 생성하시면 됩니다^^
// showDialog (
// context : context,
// builder : (context) {
//  return CustomAlertDialog.build(context: context, title : '여기다가 제목^^', text : '여기다가 이쁜 말 써주세요^^');
// }

class CustomSelectDialog extends StatelessWidget {
  final String title;
  final String text;
  final String firstButtonText;
  final String secondButtonText;
  final BuildContext context;

  CustomSelectDialog(
      {required this.context,
      required this.title,
      required this.text,
      required this.firstButtonText,
      required this.secondButtonText});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      title: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Dovemayo_gothic',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 83, 107, 118),
            ),
          ),
          Spacer(),
          IconButton(
            onPressed: () {
              Navigator.of(context).pop(0); // 그냥 나가면 0
            },
            icon: Container(
              decoration: BoxDecoration(
                color: Color(0xFF72AAD8),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(Icons.close, color: Colors.white),
              padding: EdgeInsets.all(8),
            ),
          ),
        ],
      ),
      // title: Text(
      //   title,
      //   style: TextStyle(
      //     fontFamily: 'Dovemayo_gothic',
      //     fontSize: 24,
      //     fontWeight: FontWeight.bold,
      //     color: Color.fromARGB(255, 83, 107, 118),
      //   ),
      // ),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop(1);
                }, // firstBtnText버튼 선택하면 1 배출
                child: TextWidget(
                  firstButtonText,
                  fontSize: 16,
                  color: Color(0xFF72AAD8),
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop(2);
                }, // secondBtnText버튼 선택하면 2 배출
                child: TextWidget(
                  secondButtonText,
                  fontSize: 16,
                  color: Color(0xFF72AAD8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
