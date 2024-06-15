import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaorre/widget/button/small_button_widget.dart';
import 'package:gaorre/widget/text/text_widget.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionRequestPhoneScreen extends ConsumerStatefulWidget {
  @override
  _PermissionRequestPhoneScreenState createState() =>
      _PermissionRequestPhoneScreenState();
}

class _PermissionRequestPhoneScreenState
    extends ConsumerState<PermissionRequestPhoneScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextWidget("웨이팅 고객 호출시에 메세지를 전송하는 기능이 포함되어 있습니다. 권한을 거부하시면 메세지가 전송되지 않아요."),
            SizedBox(height: 16),
            SmallButtonWidget(
              text: "권한 부여하기",
              onPressed: () {
                openAppSettings();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
