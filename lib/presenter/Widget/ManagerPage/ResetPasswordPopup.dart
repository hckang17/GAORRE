import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaorre/presenter/Widget/alertDialog.dart';
import 'package:gaorre/provider/Data/loginDataProvider.dart';
import 'package:gaorre/provider/Data/waitingDataProvider.dart';
import 'package:gaorre/services/HIVE_service.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _currentPWController = TextEditingController();
  final _newPWController = TextEditingController();
  final _confirmNewPWController = TextEditingController();

  @override
  void dispose() {
    _currentPWController.dispose();
    _newPWController.dispose();
    _confirmNewPWController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      var adminPhoneNumber = await HiveService.retrieveData('phoneNumber');
      var currentPW = await HiveService.retrieveData('password');
      if(currentPW != _currentPWController.text){
        await showAlertDialog(ref.context, "비밀번호 변경", "변경전 비밀번호를 확인해주세요", null);
        return;
      }else{
        if(true == await ref.read(loginProvider.notifier).resetPassword(ref, adminPhoneNumber!, _currentPWController.text, _newPWController.text)){
          await showAlertDialog(ref.context, "비밀번호 변경", "비밀번호 변경 성공!", null);
          Navigator.of(context).pop();
        }
      }
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Image.asset(
            "assets/image/waveform/wave_shadow.png",
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          ),
          Image.asset(
            "assets/image/waveform/wave.png",
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          ),
          Center(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: TextFormField(
                      controller: _currentPWController,
                      obscureText: true, // 비밀번호를 숨김 처리
                      decoration: InputDecoration(
                        labelText: '현재 비밀번호',
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
                        prefixIcon: Icon(Icons.password, color: Color(0xFF77AAD8)),
                      ),
                    ),
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
                        } else if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
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
                    )
                  ),
                  SizedBox(height:15),
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
                    )
                  ),
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
        ],
      ),
    );
  }
}
