import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/presenter/Error/error_screen.dart';
import 'package:orre_manager/presenter/Error/network_error_screen.dart';
import 'package:orre_manager/presenter/Error/websocket_error_screen.dart';
import 'package:orre_manager/presenter/Screen/StartScreen.dart';
import 'package:orre_manager/presenter/MainScreen.dart';
import 'package:orre_manager/presenter/Widget/LoadingDialog.dart';
import 'package:orre_manager/provider/Data/loginDataProvider.dart';
import 'package:orre_manager/provider/Data/storeDataProvider.dart';
import 'package:orre_manager/provider/Network/connectivityStateNotifier.dart';
import 'package:orre_manager/provider/Network/stompClientStateNotifier.dart';
import 'package:orre_manager/services/Booting_service.dart';

late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message ${message.messageId}');
}


Future<void> main() async  {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );
  
  var initialzationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  // var initialzationSettingsIOS = IOSInitializationSettings(
  //   requestSoundPermission: true,
  //   requestBadgePermission: true,
  //   requestAlertPermission: true,
  // );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
      
  var initializationSettings = InitializationSettings(
      android: initialzationSettingsAndroid, 
      //iOS: initialzationSettingsIOS
    );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  
  runApp(
    ProviderScope(
      child: MaterialApp(
        home: GAORRE_APP(),
      ),
    ),
  );
}

final initStateProvider = StateProvider<int>((ref) => 3);

class GAORRE_APP extends ConsumerStatefulWidget {
  @override
  _GAORRE_APPState createState() => _GAORRE_APPState();
}

class _GAORRE_APPState extends ConsumerState<GAORRE_APP> with WidgetsBindingObserver {
  List<Widget> nextScreen = [
      StartScreen(),
      MainScreen(),
      WebsocketErrorScreen(),
      NetworkCheckScreen(),
      ErrorScreen(),
  ];  

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    //     RemoteNotification? notification = message.notification;
    //     AndroidNotification? android = message.notification?.android;
    //     var androidNotiDetails = AndroidNotificationDetails(
    //       channel.id,
    //       channel.name,
    //       channelDescription: channel.description,
    //     );
    //     // var iOSNotiDetails = const IOSNotificationDetails();
    //     var details =
    //         NotificationDetails(android: androidNotiDetails
    //         // , iOS: iOSNotiDetails
    //     );
    //     if (notification != null) {
    //       flutterLocalNotificationsPlugin.show(
    //         notification.hashCode,
    //         notification.title,
    //         notification.body,
    //         details,
    //       );
    //     }
    //   });

    //   FirebaseMessaging.onMessageOpenedApp.listen((message) {
    //     print(message);
    //   });
    // }
  }

  @override
  void dispose() {
    print('GAORRE_APP disposed [main.dart]');
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        // 앱이 비활성 상태일 때 실행할 코드
        print('앱이 비활성화 상태입니다... [main.dart]');
        break;
      case AppLifecycleState.paused:
        // 앱이 일시 정지 상태일 때 실행할 코드
        print('앱이 일시정지 상태입니다... [main.dart]');
        break;
      case AppLifecycleState.resumed:
        // 앱이 활성 상태로 돌아왔을 때 실행할 코드
        print('앱이 활성화 상태입니다... [main.dart]');
        _executeReboot(ref);
        break;
      case AppLifecycleState.detached:
        // 앱이 종료 상태일 때 실행할 코드
        print('앱이 종료된 상태입니다... [main.dart]');
        break;
      case AppLifecycleState.hidden:
        // TODO: Handle this case.
        print('앱이 숨겨진 상태입니다... [main.dart]');
    }
  }


  void _executeReboot(WidgetRef ref) async {
    print("백그라운드 -> 포그라운드 돌아옴.... [main.dart - executeReboot]");
    // 반투명 로딩 스크린 표시
    showLoadingDialog(context);

    int rebootState = await reboot(ref);
    Navigator.pop(context);  // 로딩 스크린 제거

    if (rebootState != 1) {
      Navigator.of(context).push(
        MaterialPageRoute(
        builder: (BuildContext context) =>
          nextScreen[rebootState]
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int initState = ref.watch(initStateProvider);
    print("GAORRE_APP build() called");
    return MaterialApp(
      home: FlutterSplashScreen.fadeIn(
        backgroundColor: Colors.white,
        onInit: () async {
          debugPrint("최초 실행 초기화중....");
          initState = await firstBoot(ref);
          ref.read(initStateProvider.notifier).state = initState;
        },
        onEnd: () {
          print('최초 초기화 완료... [main.dart]');
        },
        childWidget: SizedBox(
          height: 200,
          width: 200,
          child: Image.asset("assets/image/gaorre.png"),
        ),
        onAnimationEnd: () => debugPrint("On Fade In End [main.dart]"),
        nextScreen: nextScreen[initState],
      ),
      title: '가 오 리 ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}


class NetworkCheckScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = ref.watch(networkStateProvider);
    return isConnected ? StompCheckScreen() : NetworkErrorScreen();
  }
}

class StompCheckScreen extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final stomp = ref.watch(stompClientStateNotifierProvider);
    final stompS = ref.watch(stompState);

    if (stompS == StompStatus.CONNECTED) {
      // STOMP 연결 성공
      print("STOMP 연결 성공 [StompCheckScreen - main.dart]");
      return UserInfoCheckWidget();
    } else {
      // STOMP 연결 실패
      print("STOMP 연결 실패, WebsocketErrorScreen() 호출 [StompCheckScreen - main.dart]");
      return WebsocketErrorScreen();
    }
  }
}


class UserInfoCheckWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
        future: ref.watch(loginProvider.notifier).requestAutoLogin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data == true) {
              print("유저 정보 존재 : ${snapshot.data} [UserInfoCheck - main.dart]");
              return StoreDataCheckWidget();
            } else {
              print("최초 화면 호출");
              return StartScreen();
            }
          } else {
            print("유저 정보 로딩 중");
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
  }
}

class StoreDataCheckWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<bool>(
      future: ref.watch(storeDataProvider.notifier).requestStoreData(
        ref.read(loginProvider.notifier).getLoginData()!.storeCode
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data == true) {
            print("가게 정보 존재 : ${snapshot.data} [UserInfoCheck - main.dart]");
            return MainScreen();
          } else {
            print("최초 화면 호출");
            return StartScreen();
          }
        } else {
          print("유저 정보 로딩 중");
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}