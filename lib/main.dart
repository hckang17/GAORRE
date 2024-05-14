import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/presenter/MainScreen/waiting_screen.dart';
import 'package:orre_manager/provider/Data/loginDataProvider.dart';
import 'package:orre_manager/provider/errorStateNotifier.dart';
import 'package:orre_manager/provider/firstBootFutureProvider.dart';
import 'package:orre_manager/services/hive_service.dart';
// import 'package:orre_manager/references/reference2.dart';
import 'presenter/MainScreen/login_screen.dart';


void main() {
  runApp(ProviderScope(child : MyApp()));
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginData = ref.watch(loginProvider);
    print("MyApp build() called");
    return MaterialApp(
      home: FlutterSplashScreen.fadeIn(
        backgroundColor: Colors.white,
        onInit: () async {
          debugPrint("Init화면");
          await ref.watch(firstBootFutureProvider);
          await HiveService.initHive(); // 하이브 저장소를 초기화 해줌.
        },
        onEnd: () {
          final first = ref.watch(firstBootState.notifier).state;
          final error = ref.watch(errorStateNotifierProvider);
          print("firstBootState: $first");
          print("errorStateNotifier: $error");
          if (first && error.isEmpty) {
            debugPrint("On End");
          }
        },
        childWidget: SizedBox(
          height: 200,
          width: 200,
          child: Image.asset("Assets/Image/gaorre.png"),
        ),
        onAnimationEnd: () => debugPrint("On Fade In End"),
        nextScreen: loginData == null ? LoginScreenWidget() : StoreScreenWidget(),
      ),
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
