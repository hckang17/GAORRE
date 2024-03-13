import 'package:flutter/material.dart';
import 'store.dart';

class LoginPage extends StatelessWidget {
  TextEditingController _idController = TextEditingController();
  TextEditingController _pwController = TextEditingController();

  void _login(BuildContext context) {
    // 여기서 로그인 처리를 수행하고 성공 시에는 '/store'로 이동. 여기서부터가 매장점주 관리화면임.
    String storeCode = _idController.text;
    String pw = _pwController.text;

    // 여기서 서버 엔드포인트로 API 자료교환이 이루어져야함.
    if (storeCode == 'danmoeum' && pw == 'mse1234!') {
      // 임시 storeCode = danmoeum
      // 임시 passWord = mse1234!

      // 로그인 성공시 나타나는 다이얼로그(디버그용)
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Login Succeed'),
            content: Text('Welcome!'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      // -다이얼로그

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => StorePage(storeCode: storeCode),
        ),
      );
      // Navigator.pushReplacementNamed(context, '/store/$storeCode');
      // context로 필요한 정보를 수신한 뒤, /store으로 넘겨줄거임.
    } else {
      // 로그인 실패 처리
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Login Failed'),
            content: Text('Invalid ID or Password.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ORRE(Manager) Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _idController,
              decoration: InputDecoration(labelText: 'Store Code'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _pwController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _login(context),
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}