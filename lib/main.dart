// ignore_for_file: unused_local_variable, library_private_types_in_public_api, use_key_in_widget_constructors, camel_case_types

import 'dart:async';

import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaorre/firebase_options.dart';
import 'package:gaorre/presenter/Error/error_screen.dart';
import 'package:gaorre/presenter/Error/network_error_screen.dart';
import 'package:gaorre/presenter/Error/websocket_error_screen.dart';
import 'package:gaorre/presenter/Screen/StartScreen.dart';
import 'package:gaorre/presenter/MainScreen.dart';
import 'package:gaorre/presenter/Screen/UpdateScreen.dart';
import 'package:gaorre/presenter/Widget/LoadingDialog.dart';
import 'package:gaorre/provider/Data/loginDataProvider.dart';
import 'package:gaorre/provider/Data/storeDataProvider.dart';
import 'package:gaorre/provider/Network/connectivityStateNotifier.dart';
import 'package:gaorre/provider/Network/stompClientStateNotifier.dart';
import 'package:gaorre/services/Booting_service.dart';

final notifications = FlutterLocalNotificationsPlugin();
late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  initializeFirebaseMessaging(); // Firebase 메시징 초기화
  await requestPermission(); // 권한 요청

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp]); // 화면 방향을 세로로 고정

  runApp(
    ProviderScope(
      child: Builder(
        builder: (context) {
          ScreenUtil.init(
            context,
            designSize: Size(360, 800),
            minTextAdapt: true,
          );
          return MaterialApp(
            home: GAORRE_APP(),
          );
        },
      ),
    ),
  );
}

final initStateProvider = StateProvider<int>((ref) => 3);
final lastLifeCycleState =
    StateProvider<AppLifecycleState>((ref) => AppLifecycleState.inactive);

class GAORRE_APP extends ConsumerStatefulWidget {
  @override
  _GAORRE_APPState createState() => _GAORRE_APPState();
}

class _GAORRE_APPState extends ConsumerState<GAORRE_APP>
    with WidgetsBindingObserver {
  List<Widget> nextScreen = [
    StartScreen(),
    MainScreen(),
    WebsocketErrorScreen(),
    NetworkCheckScreen(),
    ErrorScreen(),
    UpdateAppScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
        print('앱이 inactive 상태입니다... [main.dart]');
        ref.read(lastLifeCycleState.notifier).state =
            AppLifecycleState.inactive;
        break;
      case AppLifecycleState.paused:
        // 앱이 일시 정지 상태일 때 실행할 코드
        print('앱이 paused 상태입니다... [main.dart]');
        ref.read(lastLifeCycleState.notifier).state = AppLifecycleState.paused;
        break;
      case AppLifecycleState.resumed:
        // 앱이 활성 상태로 돌아왔을 때 실행할 코드
        print('앱이 resumed 상태입니다... [main.dart]');
        if (ref.read(lastLifeCycleState) == AppLifecycleState.paused) {
          ref.read(lastLifeCycleState.notifier).state =
              AppLifecycleState.resumed;
        } else {
          ref.read(lastLifeCycleState.notifier).state =
              AppLifecycleState.resumed;
          _executeReboot(ref);
        }
        break;
      case AppLifecycleState.detached:
        // 앱이 종료 상태일 때 실행할 코드
        print('앱이 detached 상태입니다... [main.dart]');
        ref.read(lastLifeCycleState.notifier).state =
            AppLifecycleState.detached;
        break;
      case AppLifecycleState.hidden:
        // TODO: Handle this case.
        print('앱이 hidden 상태입니다... [main.dart]');
        ref.read(lastLifeCycleState.notifier).state = AppLifecycleState.hidden;
    }
  }

  void _executeReboot(WidgetRef ref) async {
    print("백그라운드 -> 포그라운드 돌아옴.... [main.dart - executeReboot]");

    if (ref.read(isNowRebootState) == true) {
      print('이미 Reboot이 실행중입니다... [executeReboot]');
      return;
    }
    // 반투명 로딩 스크린 표시
    showLoadingDialog(context);

    int rebootState = await reboot(ref);
    Navigator.pop(context); // 로딩 스크린 제거
    if (rebootState == -1) {
      print('아무것도 하지 않습니다 [_executeReboot]');
      return;
    } else if (rebootState != 1) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => nextScreen[rebootState]));
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
      print(
          "STOMP 연결 실패, WebsocketErrorScreen() 호출 [StompCheckScreen - main.dart]");
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
          ref.read(loginProvider.notifier).getLoginData()!.storeCode),
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

Future<void> initializeFirebaseMessaging() async {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('alert'),
  );

  await notifications
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await notifications.initialize(initializationSettings);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    print('메세지 수신... [initializeFirebaseMessaging]');

    if (notification != null && android != null) {
      notifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: android.smallIcon,
            playSound: true,
            sound: const RawResourceAndroidNotificationSound('alert'),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: "slow_spring_board.aiff",
          ),
        ),
      );
    }
  });

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message ${message.messageId}');
}

Future<void> requestPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  print('FCMTOken알림 허용 요청이 접수되었습니다. [requestPermission]');
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('유저가 권한을 허가하였습니다. User granted permission [requestPermission]');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission [requestPermission]');
  } else {
    print('User declined or has not accepted permission [requestPermission]');
  }
}
