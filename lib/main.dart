import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/presenter/Screen/StartScreen.dart';
import 'package:orre_manager/presenter/Screen/WaitingScreen.dart';
import 'package:orre_manager/presenter/MainScreen.dart';
import 'package:orre_manager/provider/Data/loginDataProvider.dart';
import 'package:orre_manager/provider/Network/websocketRefreshServiceProvider.dart';
import 'package:orre_manager/provider/errorStateNotifier.dart';
import 'package:orre_manager/services/FirstBootService.dart';
import 'package:orre_manager/services/HIVE_service.dart';
import 'presenter/Screen/LoginScreen.dart';


void main() {
  runApp(
    ProviderScope(
      child: GAORRE_APP(),
    ),
  );
}

class GAORRE_APP extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginData = ref.watch(loginProvider);
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
          child: Image.asset("assets/image/gaorre.png"),
        ),
        onAnimationEnd: () => debugPrint("On Fade In End [main.dart]"),
        nextScreen: loginData == null ? StartScreen() : MainScreen(),
      ),
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
