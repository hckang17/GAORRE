import 'dart:async';
import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';

class SendSMSService {
  /// 전화번호로 제목과 내용을 포함하는 SMS를 보냅니다.
  /// 
  /// [phoneNumber] SMS를 받을 전화번호.
  /// [title] SMS 제목.
  /// [content] SMS 내용.
  ///
  final String linkPageSMS = '웨이팅 연기는 링크에서(아래 링크 클릭)';

  static Future<bool> requestSendSMS(String phoneNumber, String title, String content) async {
    String message = "[$title] $content";
    String recipients = phoneNumber;
    final telephony = Telephony.instance;

    print('[SMS send service]');
    print('연락처 $phoneNumber 님에게 SMS를 전송합니다');

    try {
      // SMS 메시지 보내기
      await telephony.sendSms(
        to: recipients,
        message: message,
      );
      // 성공적으로 SMS 전송 완료
      print("SMS 전송 성공");
      return true;
    } catch (e) {
      // 예외 로깅
      print("SMS 전송 실패: $e");
      return false;
    }
  }
}