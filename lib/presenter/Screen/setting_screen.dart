// ignore_for_file: prefer_const_constructors, avoid_print, unnecessary_brace_in_string_interps

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaorre/Model/StoreDataModel.dart';
import 'package:gaorre/presenter/Widget/ManagerPage/ResetPasswordPopup.dart';
import 'package:gaorre/presenter/Widget/alertDialog.dart';
import 'package:gaorre/provider/Data/loginDataProvider.dart';
import 'package:gaorre/provider/Data/storeDataProvider.dart';
import 'package:gaorre/provider/PushNotificationProvider.dart';
import 'package:gaorre/widget/appbar/static_app_bar_widget.dart';
import 'package:gaorre/widget/background/waveform_background_widget.dart';
import 'package:gaorre/widget/button/big_button_widget.dart';
import 'package:gaorre/widget/button/text_button_widget.dart';
import 'package:gaorre/widget/text/text_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:restart_app/restart_app.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final StoreData storeData = ref.read(storeDataProvider.notifier).getStoreData()!;
    String storeName = storeData.storeName;

    return WaveformBackgroundWidget(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(0.25.sh),
          child: StaticAppBarWidget(
            title: '설정',
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () {
                print('뒤로가기 버튼 클릭됨 [settingScreen]');
                Navigator.pop(context);
              },
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget(
                            '${storeName}점주 님.',
                            fontFamily: 'Dovemayo_gothic',
                            fontSize: 24,
                          ),
                          TextWidget(
                            '만나서 반갑습니다. :)',
                            fontFamily: 'Dovemayo_gothic',
                            fontSize: 15,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 60,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      BigButtonWidget(
                        onPressed: () async {;
                          print('푸쉬알림 상태를 변경합니다');
                          openAppSettings();
                        },
                        backgroundColor: Color(0xFFDFDFDF),
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        text: '푸쉬알림 설정하기',
                        textColor: Colors.black,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      BigButtonWidget(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ResetPasswordScreen()));
                        },
                        backgroundColor: Color(0xFFDFDFDF),
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        text: '비밀번호 초기화하기',
                        textColor: Colors.black,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButtonWidget(
                            text: '로그아웃',
                            fontSize: 16,
                            textColor: Color(0xFFDFDFDF),
                            onPressed: () async {
                              // 로그아웃 기능 사용.
                              if (await showConfirmDialog(context, "로그아웃","정말 로그아웃 하시겠습니까? 로그아웃 이후에는 앱을 다시 시작합니다.")) {
                                ref.read(loginProvider.notifier).logout(ref);
                                Restart.restartApp();
                              } else {
                                return;
                              }
                            },
                          ),
                          SizedBox(width: 10),
                          Container(
                            width: 1,
                            height: 18,
                            color: Color(0xFFDFDFDF),
                          ),
                          SizedBox(width: 10),
                          TextButtonWidget(
                            text: '회원탈퇴',
                            fontSize: 16,
                            textColor: Color(0xFFDFDFDF),
                            onPressed: () {
                              showAlertDialog(ref.context, 
                                "회원탈퇴",
                                "회원탈퇴는 관리자에게 문의해주세요.\n연락처 : 010-3546-3360",
                                null
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 20,
                color: Color.fromARGB(255, 98, 189, 255),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
