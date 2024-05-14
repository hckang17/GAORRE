// 처음 부팅할 때 필요한 초기화 작업을 수행하는 Provider

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/provider/Data/loginDataProvider.dart';
import 'package:orre_manager/provider/Network/connectivityStateNotifier.dart';
import 'package:orre_manager/provider/Network/stompClientStateNotifier.dart';
import 'package:orre_manager/provider/errorStateNotifier.dart';


final firstBootState = StateProvider<bool>((ref) => false);

final signInProvider = FutureProvider<void>((ref) async {
  print("로그인 프로바이더 start");
  Completer<void> completer = Completer();

  // networkStreamProvider를 구독하고, true가 되면 작업을 수행
  ref.listen<bool>(networkStateNotifier, (prevState, newState) {
    print("네트워크 status: $newState");
    if (newState) {
      print("네트워크 연결 성공.. attempting to sign in...");
      ref.read(loginProvider.notifier).requestLoginData(null, null).then((value) {
        if (value == false) {
          print("최초접속 로그인 실패: $value");
          completer.completeError("sigin in failed");
        } else {
          print("최초접속 로그인 성공");
          completer.complete();
        }
      }).catchError((error) {
        print("최초접속 로그인 에러: $error");
        completer.completeError(error);
      });
    } else {
      print("네트워크 연결됨, 대기중...");
    }
  });

  // Completer의 Future를 반환하여, 외부에서 signInProvider의 완료를 기다릴 수 있도록 함
  await completer.future;
});

final firstBootFutureProvider = FutureProvider<void>((ref) async {
  final Completer<void> completer = Completer();
  if (ref.watch(firstBootState.notifier).state) {
    print("already booted");
    return;
  }

  print("[First Boot]시작됨");
  try {
    await ref.read(signInProvider.future);
  } catch (error) {
    print("로그인 에러 in error: $error [FirstBootProvider]");
    completer.completeError(error);
  } finally {
    await ref
        .read(stompClientStateNotifierProvider.notifier)
        .configureClient()
        .listen((event) {
      print("!!!!!!!!!!!!!!!! 발생한 이벤트: $event");
      if (event == StompStatus.CONNECTED) {
        print("웹소켓 연결됨.....");
        ref
            .read(errorStateNotifierProvider.notifier)
            .deleteError(Error.websocket);
        // ref
        //     .read(nowLocationProvider.notifier)
        //     .updateNowLocation()
        //     .then((value) {
        //   if (value == LocationInfo.nullValue()) {
        //     print("nowLocation not updated");
        //     ref
        //         .read(errorStateNotifierProvider.notifier)
        //         .addError(Error.locationPermission);
        //   } else {
        //     print("nowLocation updated");
        //     ref
        //         .read(errorStateNotifierProvider.notifier)
        //         .deleteError(Error.locationPermission);
        //     ref.watch(firstBootState.notifier).state = true;
        //   }
        // });
      } else {
        print("웹소켓 연결 끊김...");
        ref.read(errorStateNotifierProvider.notifier).addError(Error.websocket);
      }
      print("웹소켓 이벤트 End");
      completer.complete();
    });
  }
});
