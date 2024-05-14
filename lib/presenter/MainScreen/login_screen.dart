import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/presenter/MainScreen/waiting_screen.dart';
import 'package:orre_manager/presenter/Widget/alertDialog.dart';
import '../../provider/Data/loginDataProvider.dart';
import '../../Coding_references/stompClientFutureProvider.dart';

class LoginScreenWidget extends ConsumerWidget {
  const LoginScreenWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final stompClientAsyncValue = ref.watch(stompClientProvider);
    return _LoginScreenBody(context: context, ref: ref);
    // return stompClientAsyncValue.when(
    //   data: (stompClient) {
    //     // stompClient가 준비되면 위젯을 반환합니다.
    //     return _LoginScreenBody(context: context, ref: ref); // 별도의 위젯으로 분리
    //   },
    //   loading: () {
    //     // 로딩 중이면 로딩 스피너를 표시합니다.
    //     return _LoadingScreen();
    //   },
    //   error: (error, stackTrace) {
    //     // 에러가 발생하면 에러 메시지를 표시합니다.
    //     return _ErrorScreen(error);
    //   },
    // );
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
    print('로그인 프로세스');
    if(true == await ref.read(loginProvider.notifier).requestLoginData(_idController.text, _pwController.text)){
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder : (context) => StoreScreenWidget(),
        )
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              decoration: InputDecoration(labelText: 'Admin PhoneNumber'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _pwController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => loginProcess(ref),
              child: Text('로그인'),
            ),
          ],
        ),
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
