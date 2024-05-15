import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/presenter/MainScreen/waiting_screen.dart';
import 'package:orre_manager/provider/Data/loginDataProvider.dart';
import 'package:orre_manager/provider/Network/websocketRefreshServiceProvider.dart';
import 'package:orre_manager/provider/errorStateNotifier.dart';
import 'package:orre_manager/provider/firstBootFutureProvider.dart';
import 'package:orre_manager/services/hive_service.dart';
import 'presenter/MainScreen/login_screen.dart';


void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final loginData = ref.watch(loginProvider);
    print("MyApp build() called");
    return MaterialApp(
      home: FlutterSplashScreen.fadeIn(
        backgroundColor: Colors.white,
        onInit: () async {
          debugPrint("Init화면");
          await FirstBootService.firstBoot(ref);
          ref.read(websocketRefreshServiceProvider);

          // ref.watch(firstBootFutureProvider);
          // await HiveService.initHive(); // 하이브 저장소를 초기화 해줌.
          // ref.read(websocketRefreshServiceProvider);
        },
        onEnd: () {
          final first = ref.watch(firstBootState.notifier).state;
          final error = ref.watch(errorStateNotifierProvider);
          
          print("firstBootState: $first [main.dart]");
          print("errorStateNotifier: $error [main.dart]");
          if (first && error.isEmpty) {
            debugPrint("On End [main.dart]");
          }
        },
        childWidget: SizedBox(
          height: 200,
          width: 200,
          child: Image.asset("Assets/Image/gaorre.png"),
        ),
        onAnimationEnd: () => debugPrint("On Fade In End [main.dart]"),
        nextScreen: ref.read(loginProvider.notifier).getLoginData() == null ? LoginScreenWidget() : StoreScreenWidget(),
      ),
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
