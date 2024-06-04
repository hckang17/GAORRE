import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:gaorre/presenter/Widget/AlertDialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:telephony/telephony.dart';
import 'package:flutter_sms/flutter_sms.dart';

class SendSMSService {
  /// 전화번호로 제목과 내용을 포함하는 SMS를 보냄.
  ///
  /// [phoneNumber] SMS를 받을 전화번호.
  /// [title] SMS 제목.
  /// [content] SMS 내용.
  ///
  final String linkPageSMS = '웨이팅 연기는 링크에서(아래 링크 클릭)';

  static Future<bool> requestSendSMS(BuildContext context, String phoneNumber,
      String title, String content) async {
    String message = "[$title] $content";
    List<String> recipients = [phoneNumber];

    // 권한 요청
    var permissionStatus = await Permission.sms.status;
    if (!permissionStatus.isGranted) {
      var requestedStatus = await Permission.sms.request();
      if (!requestedStatus.isGranted && Platform.isAndroid) {
        print('SMS 전송 권한이 거부되었습니다.');
        showAlertDialog(context, "SMS전송", "권한이 거부되어 호출 메세지 전송이 불가능합니다.", null);
        return false;
      }
    }

    print('[SMS send service]');
    print('연락처 $phoneNumber 님에게 SMS를 전송합니다');

    try {
      // SMS 메시지 보내기
      if (Platform.isIOS) {
        String result = await sendSMS(
                message: message, recipients: recipients, sendDirect: false)
            .catchError((onError) {
          print(onError);
          return 'SMS 전송 실패';
        });
        if (result == 'SMS 전송 성공') {
          print("SMS 전송 성공");
          return true;
        } else {
          print("SMS 전송 실패: $result");
          return false;
        }
      } else {
        String result = await sendSMS(
                message: message, recipients: recipients, sendDirect: true)
            .catchError((onError) {
          print(onError);
          return 'SMS 전송 실패';
        });
        if (result == 'SMS 전송 성공') {
          print("SMS 전송 성공");
          return true;
        } else {
          print("SMS 전송 실패: $result");
          return false;
        }
      }
    } catch (e) {
      // 예외 로깅
      print("SMS 전송 실패: $e");
      return false;
    }
  }
}


// class SendSMSService {
//   /// 전화번호로 제목과 내용을 포함하는 SMS를 보냄.
//   /// 
//   /// [phoneNumber] SMS를 받을 전화번호.
//   /// [title] SMS 제목.
//   /// [content] SMS 내용.
//   ///
//   final String linkPageSMS = '웨이팅 연기는 링크에서(아래 링크 클릭)';

//   static Future<bool> requestSendSMS(BuildContext context, String phoneNumber, String title, String content) async {
//     String message = "[$title] $content";
//     String recipients = phoneNumber;
//     final telephony = Telephony.instance;

//     // 권한 요청
//     var permissionStatus = await Permission.sms.status;
//     if (!permissionStatus.isGranted) {
//       var requestedStatus = await Permission.sms.request();
//       if (!requestedStatus.isGranted) {
//         print('SMS 전송 권한이 거부되었습니다.');
//         showAlertDialog(context, "SMS전송", "권한이 거부되어 호출 메세지 전송이 불가능합니다.", null);
//         return false;
//       }
//     }

//     print('[SMS send service]');
//     print('연락처 $phoneNumber 님에게 SMS를 전송합니다');

//     try {
//       // SMS 메시지 보내기
//       await telephony.sendSms(
//         to: recipients,
//         message: message,
//       );
//       // 성공적으로 SMS 전송 완료
//       print("SMS 전송 성공");
//       return true;
//     } catch (e) {
//       // 예외 로깅
//       print("SMS 전송 실패: $e");
//       return false;
//     }
//   }
// }
