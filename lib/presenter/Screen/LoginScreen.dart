import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/presenter/Widget/AlertDialog.dart';
import 'package:orre_manager/presenter/MainScreen.dart';
import 'package:orre_manager/provider/Data/storeDataProvider.dart';
import 'package:orre_manager/widget/text_field/text_input_widget.dart';
import '../../provider/Data/loginDataProvider.dart';

final isObscureProvider = StateProvider<bool>((ref) => true);

class LoginScreenWidget extends ConsumerWidget {
  const LoginScreenWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _LoginScreenBody(context: context, ref: ref);
  }
}

// ignore: must_be_immutable
class _LoginScreenBody extends ConsumerWidget {
  final BuildContext context;
  final WidgetRef ref;
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  final FocusNode phoneNumberFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  
  _LoginScreenBody({required this.context, required this.ref});
  
  Future<void> loginProcess(WidgetRef ref) async {
    print('로그인 프로세스. [LoginScreen - loginProces]');
    if(true == await ref.read(loginProvider.notifier).requestLoginData(_idController.text, _pwController.text)){
      await showAlertDialog(ref.context, "로그인", "성공!", null);
      final requestStoreDataCompleter = Completer<void>();
      if(true == await ref.read(storeDataProvider.notifier).requestStoreData(
        ref.read(loginProvider.notifier).getLoginData()!.storeCode
      )){
        requestStoreDataCompleter.complete();
      }else{
        requestStoreDataCompleter.completeError('가게정보 취득 실패');
      }
      await requestStoreDataCompleter.future;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder : (context) => MainScreen(),
        )
      );
    }else{
      showAlertDialog(ref.context, "로그인", "로그인에 실패했습니다!", null);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isObscure = ref.watch(isObscureProvider);

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
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              "로그인",
              style: TextStyle(
                fontFamily: 'Dovemayo_gothic',
                fontSize: 32,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: TextInputWidget(
                      prefixIcon: Icon(Icons.phone),
                      hintText: '전화번호를 입력해주세요.',
                      isObscure: false,
                      type: TextInputType.number,
                      ref: ref,
                      autofillHints: [AutofillHints.telephoneNumber],
                      controller: _idController,
                      minLength: 11,
                      maxLength: 11,

                      focusNode: phoneNumberFocusNode, // Passing FocusNode
                    )),
                Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: TextInputWidget(
                        hintText: '비밀번호를 입력해주세요.',
                        isObscure: isObscure,
                        type: TextInputType.text,
                        ref: ref,
                        controller: _pwController,
                        // autofillHints: [AutofillHints.password],
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          onPressed: () {
                            ref.read(isObscureProvider.notifier).state =
                                !ref.watch(isObscureProvider.notifier).state;
                          },
                          icon: Icon((isObscure == false)
                              ? (Icons.visibility)
                              : (Icons.visibility_off)),
                        ),
                        minLength: 4,
                        focusNode: passwordFocusNode, // Passing FocusNode
                      )),
                SizedBox(height: 35),
                ElevatedButton(
                  onPressed: () => loginProcess(ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF72AAD8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize:
                        Size(MediaQuery.of(context).size.width * 0.9, 60),
                  ),
                  child: const Text(
                    "로그인",
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
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 20,
              color: Color(0xFF72AAD8),
            ),
          ),
        ],
      ),
    );
  }
}
