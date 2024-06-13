import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gaorre/presenter/Widget/alertDialog.dart';
import 'package:gaorre/provider/Data/loginDataProvider.dart';
import 'package:gaorre/services/HTTP_service.dart';

final requestAuthCodeButtonStateProvider = StateProvider((ref) => true);

class ResetPasswordScreen extends ConsumerStatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _currentPWController = TextEditingController();
  final _newPWController = TextEditingController();
  final _confirmNewPWController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _confirmCodeController = TextEditingController();

  Future<bool> requestAuthCode(WidgetRef ref, String phoneNumber) async {
    ref.read(requestAuthCodeButtonStateProvider.notifier).state = false;
    final jsonBody = json.encode({"adminPhoneNumber": phoneNumber});
    try {
      final response = await HttpsService.postRequest(
          '/StoreAdmin/generate-verification-code', jsonBody);
      if (response.statusCode == 200) {
        final responseBody = json.decode(utf8.decode(response.bodyBytes));
        if (responseBody['status'] == '200') {
          await showAlertDialog(
              ref.context, "인증번호 요청", "성공! SMS를 확인해주세요", null);
          return true;
        } else {
          throw Exception(responseBody['status']);
        }
      } else {
        throw Exception("HTTP:${response.statusCode}");
      }
    } catch (error) {
      print('requestAuthCode 오류발생 오류내용:$error [requestAuthCode]');
      await showAlertDialog(
          ref.context, "비밀번호 변경", "인증코드 요청오류\n에러내용$error", null);
      return false;
    } finally {
      ref.read(requestAuthCodeButtonStateProvider.notifier).state = true;
    }
  }

  @override
  void dispose() {
    _currentPWController.dispose();
    _newPWController.dispose();
    _confirmNewPWController.dispose();
    _phoneNumberController.dispose();
    _confirmCodeController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      var adminPhoneNumber = _phoneNumberController.text;
      var newPassword = _newPWController.text;
      var authCode = _confirmCodeController.text;
      if (true ==
          await ref
              .read(loginProvider.notifier)
              .resetPassword(ref, adminPhoneNumber, newPassword, authCode)) {
        await showAlertDialog(ref.context, "비밀번호 변경", "비밀번호 변경 성공!", null);
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SvgPicture.asset(
            "assets/image/waveform/gaorre_wave_shadow.svg",
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          ),
          SvgPicture.asset(
            "assets/image/waveform/gaorre_wave.svg",
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          ),
          SingleChildScrollView(
            padding: EdgeInsets.only(top: 150),
            child: Center(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: TextFormField(
                        controller: _phoneNumberController,
                        obscureText: false, //
                        decoration: InputDecoration(
                          labelText: '연락처',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: Color(0xFF77AAD8),
                              width: 3.0,
                            ),
                          ),
                          labelStyle: TextStyle(
                            fontFamily: 'Dovemayo_gothic',
                            fontSize: 20,
                            color: Color(0xFFD9D9D9),
                          ),
                          prefixIcon:
                              Icon(Icons.phone, color: Color(0xFF77AAD8)),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    ElevatedButton(
                        onPressed: () => {
                              ref
                                      .read(requestAuthCodeButtonStateProvider
                                          .notifier)
                                      .state
                                  ? requestAuthCode(
                                      ref, _phoneNumberController.text)
                                  : null
                            },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ref
                                  .watch(requestAuthCodeButtonStateProvider
                                      .notifier)
                                  .state
                              ? Color(0xFF77AAD8)
                              : Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize:
                              Size(MediaQuery.of(context).size.width * 0.7, 60),
                        ),
                        child: Text(
                          "인증번호 요청하기",
                          style: TextStyle(
                            fontFamily: 'Dovemayo_gothic',
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        )),
                    SizedBox(height: 15),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: TextFormField(
                          controller: _confirmCodeController,
                          obscureText: false, //
                          decoration: InputDecoration(
                            labelText: '인증번호 입력',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Color(0xFF77AAD8),
                                width: 3.0,
                              ),
                            ),
                            labelStyle: TextStyle(
                              fontFamily: 'Dovemayo_gothic',
                              fontSize: 20,
                              color: Color(0xFFD9D9D9),
                            ),
                            prefixIcon:
                                Icon(Icons.phone, color: Color(0xFF77AAD8)),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.length != 6) {
                              return '6자리 숫자로 입력해주세요';
                            }
                            return null;
                          }),
                    ),
                    SizedBox(height: 15),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: TextFormField(
                        controller: _newPWController,
                        obscureText: true, // 비밀번호를 숨김 처리
                        decoration: InputDecoration(
                          labelText: '새 비밀번호',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: Color(0xFF77AAD8),
                              width: 3.0,
                            ),
                          ),
                          labelStyle: TextStyle(
                            fontFamily: 'Dovemayo_gothic',
                            fontSize: 20,
                            color: Color(0xFFD9D9D9),
                          ),
                          prefixIcon:
                              Icon(Icons.password, color: Color(0xFF77AAD8)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '비밀번호를 입력해주세요.';
                          } else if (value.length < 8) {
                            return '비밀번호는 8자 이상이어야 합니다.';
                          } else if (!value
                              .contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                            return '비밀번호에는 특수문자가 포함되어야 합니다.';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 15),
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: TextFormField(
                          controller: _confirmNewPWController,
                          obscureText: true, // 비밀번호를 숨김 처리
                          decoration: InputDecoration(
                            labelText: '새 비밀번호 확인',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Color(0xFF77AAD8),
                                width: 3.0,
                              ),
                            ),
                            labelStyle: TextStyle(
                              fontFamily: 'Dovemayo_gothic',
                              fontSize: 20,
                              color: Color(0xFFD9D9D9),
                            ),
                            prefixIcon:
                                Icon(Icons.password, color: Color(0xFF77AAD8)),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '비밀번호 확인을 입력해주세요.';
                            } else if (value != _newPWController.text) {
                              return '비밀번호가 일치하지 않습니다.';
                            }
                            return null;
                          },
                        )),
                    SizedBox(height: 15),
                    ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF72AAD8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize:
                              Size(MediaQuery.of(context).size.width * 0.7, 60),
                        ),
                        child: Text(
                          "비밀번호 변경하기",
                          style: TextStyle(
                            fontFamily: 'Dovemayo_gothic',
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        )),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize:
                            Size(MediaQuery.of(context).size.width * 0.7, 60),
                      ),
                      child: Text(
                        "닫기",
                        style: TextStyle(
                          fontFamily: 'Dovemayo_gothic',
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
