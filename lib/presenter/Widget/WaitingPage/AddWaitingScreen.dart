import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gaorre/presenter/Widget/alertDialog.dart';
import 'package:gaorre/provider/Data/loginDataProvider.dart';
import 'package:gaorre/provider/Data/waitingDataProvider.dart';

class WaitingAddingScreen extends ConsumerStatefulWidget {
  @override
  _WaitingAddingScreenState createState() => _WaitingAddingScreenState();
}

class _WaitingAddingScreenState extends ConsumerState<WaitingAddingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _personCountController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _personCountController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // 폼 유효성 검사 통과 후 실행할 로직
      print("전화번호: ${_phoneController.text}");
      print("인원 수: ${_personCountController.text}");
      // 여기서 ref를 사용하여 Riverpod 상태를 관리하거나 액션을 수행할 수 있습니다.
      // 예: ref.read(yourProvider.notifier).someAction();
      int waitingCount = int.parse(_personCountController.text);
      bool result = await ref.read(waitingProvider.notifier).addWaitingTeam(
          ref.context,
          ref.read(loginProvider.notifier).getLoginData()!,
          _phoneController.text,
          waitingCount);
      if (result) {
        await showAlertDialog(
            context, "수동 웨이팅 추가", "추가 요청을 보냈습니다! 반영까지 몇초가량 소요될 수 있습니다.", null);
        Navigator.pop(context);
      } else {
        await showAlertDialog(
            context,
            "수동 웨이팅 추가",
            "수동 추가 실패했습니다. 동일한 휴대폰번호의 고객이 이미 웨이팅중이거나, 서버 문제일 수 있습니다. 본 오류가 반복되면 관리자에게 문의하세요.",
            null);
      }

      // 여기에다가 이제~ 웨이팅 수동 등록 코드 작성하기.

      return;
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
          Center(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width *
                        0.7, // 전화번호 입력창 크기 조정
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: '전화번호',
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
                        prefixIcon: Icon(Icons.phone, color: Color(0xFF77AAD8)),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                      ],
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.length != 11) {
                          return '정확히 11자리 전화번호를 입력해주세요.';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: MediaQuery.of(context).size.width *
                        0.7, // 인원 수 입력창 크기 조정
                    child: TextFormField(
                      controller: _personCountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '인원 수',
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
                            Icon(Icons.people, color: Color(0xFF77AAD8)),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '인원 수를 입력해주세요.';
                        } else if (int.tryParse(value) == null) {
                          return '유효한 숫자를 입력해주세요.';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      _submitForm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF72AAD8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize:
                          Size(MediaQuery.of(context).size.width * 0.7, 60),
                    ),
                    child: Text(
                      "수동 웨이팅 추가",
                      style: TextStyle(
                        fontFamily: 'Dovemayo_gothic',
                        fontSize: 24,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
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
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
