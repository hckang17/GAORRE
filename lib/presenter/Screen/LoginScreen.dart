import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/presenter/Screen/WaitingScreen.dart';
import 'package:orre_manager/presenter/Widget/AlertDialog.dart';
import 'package:orre_manager/presenter/MainScreen.dart';
import 'package:orre_manager/provider/Data/storeDataProvider.dart';
import '../../provider/Data/loginDataProvider.dart';

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
  TextEditingController _idController = TextEditingController();
  TextEditingController _pwController = TextEditingController();
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
          Padding(
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
                    child: TextField(
                      controller: _idController,
                      keyboardType: TextInputType.number,
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
                      ),
                    ),
                    width: MediaQuery.of(context).size.width * 0.9),
                SizedBox(height: 20),
                Container(
                    child: TextField(
                      controller: _pwController,
                      decoration: InputDecoration(
                        labelText: '비밀번호',
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
                      ),
                    ),
                    width: MediaQuery.of(context).size.width * 0.9),
                SizedBox(height: 20),
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
                  child: Text(
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

// class _LoadingScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Login Screen'),
//       ),
//       body: Center(
//         child: CircularProgressIndicator(),
//       ),
//     );
//   }
// }

// class _ErrorScreen extends StatelessWidget {
//   final dynamic error;

//   _ErrorScreen(this.error);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Login Screen'),
//       ),
//       body: Center(
//         child: Text('Error: $error'),
//       ),
//     );
//   }
// }
