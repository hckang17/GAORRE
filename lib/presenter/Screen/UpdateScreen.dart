import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaorre/widget/text/text_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

class UpdateAppScreen extends ConsumerWidget {
  // AlertDialog를 표시하는 함수
  void showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("업데이트 확인"),
          content: Text("필수 업데이트가 있습니다!\n스토어에서 업데이트를 진행해주세요."),
          actions: <Widget>[
            TextButton(
              child: Text('업데이트하기'),
              onPressed: () => _launchURL(),
            ),
          ],
        );
      },
    );
  }

  // 플랫폼별로 앱 스토어 URL을 실행하는 함수
  void _launchURL() async {
    const urlIOS = 'https://apps.apple.com/kr/app/%EA%B0%80%EC%98%A4%EB%A6%AC/id6503666279'; // ID확인해야함.. 뭔지모름
    const urlAndroid = 'https://play.google.com/store/apps/details?id=com.aeioudev.gaorre';
    String url = Platform.isIOS ? urlIOS : urlAndroid;

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: TextWidget("필수 업데이트갖 존재합니다."),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => showUpdateDialog(context),
          child: TextWidget('업데이트하기'),
        ),
      ),
    );
  }
}
