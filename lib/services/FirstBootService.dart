// 처음 부팅할 때 필요한 초기화 작업을 수행하는 Provider

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/provider/Data/loginDataProvider.dart';
import 'package:orre_manager/provider/Data/storeDataProvider.dart';
import 'package:orre_manager/provider/Network/connectivityStateNotifier.dart';
import 'package:orre_manager/provider/Network/stompClientStateNotifier.dart';
import 'package:orre_manager/provider/errorStateNotifier.dart';
import 'package:orre_manager/services/HIVE_service.dart';
import 'package:permission_handler/permission_handler.dart';

final firstBootState = StateProvider<bool>((ref) => false);

// final firstBootServiceProvider = Provider<FirstBootService>((ref) {
//   return FirstBootService(ref);
// });

Future<int> firstBoot(WidgetRef ref) async {
  try{
    var networkStatus = ref.read(networkStateProvider);
    var stompCompleter = Completer<void>();
    var requestLoginData = Completer<void>();
    var requestStoreInfoCompleter = Completer<void>();
    var hiveInitializeCompleter = Completer<void>();

    // 하이브 저장소 초기화 
    print('하이브 저장소를 초기화합니다. [FIrstBootService]');
    bool hiveSuccess = await HiveService.initHive();
    if(hiveSuccess){
      hiveInitializeCompleter.complete();
    }else{
      hiveInitializeCompleter.completeError('하이브 초기화 실패..[firstBootService]');
    }
    await hiveInitializeCompleter.future;

    // 네트워크 연결 확인
    final networkStatusSubscription = networkStatus.listen((isConnected) {
      if (isConnected) {
        ref.read(networkStateNotifierProvider.notifier).state = true;
      } else {
        ref.read(networkStateNotifierProvider.notifier).state = false;
      }
    });
    
    // 10초 후에 타임아웃 처리
    final networkTimeout = Future.delayed(const Duration(seconds: 10), () {
      networkStatusSubscription.cancel();
      ref.read(networkStateNotifierProvider.notifier).state = false;
    });


    // 네트워크 연결되었을때
    print("네트워크 연결 성공! [FirstBootService]");
    final stompStatusStream =
        ref.read(stompClientStateNotifierProvider.notifier).configureClient();
    bool isStompConnected = false;
    StreamSubscription<StompStatus>? stompSubscription;

    stompSubscription = stompStatusStream.listen((status) {
      if (status == StompStatus.CONNECTED) {
        isStompConnected = true;
        stompSubscription?.cancel();
        stompCompleter.complete();
      }
    });

    // 10초 후에 타임아웃 처리
    final stompTimeout = Future.delayed(const Duration(seconds: 5), () {
      if (!stompCompleter.isCompleted) {
        stompSubscription?.cancel();
        stompCompleter.completeError('STOMP timeout');
      }
    });

    await Future.any([stompCompleter.future, stompTimeout]);

    if(!isStompConnected) { // 스텀프 연결 실패
      print('STOMP 연결 실패... [firstBootService]');
      return 2; // 2는 STOMP 연결 에러
    } // STOMP초기화가 완료되었다면 다음 초기화 작업 수행...

    // SMS 권한 요청 확인
    var permissionStatus = await Permission.sms.status;
    if (!permissionStatus.isGranted) { await Permission.sms.request(); }

    // 자동로그인 시도
    bool autoLoginResult = await ref.read(loginProvider.notifier).requestAutoLogin();
    if(!autoLoginResult){
      requestLoginData.completeError("최초 로그인 정보가 존재하지 않음");
      return 0; // 최초 화면으로..
    }else{
      requestLoginData.complete();
    }

    await requestLoginData.future;

    // 가게 정보 취득 시도
    bool retrieveStoreDataResult = await ref.read(storeDataProvider.notifier).requestStoreData(
      ref.read(loginProvider.notifier).getLoginData()!.storeCode
    );
    if(!retrieveStoreDataResult){
      requestStoreInfoCompleter.completeError('가게정보 수신 실패');
      return 0; // 최초 화면으로
    }else{
      requestStoreInfoCompleter.complete();
    }

    await requestStoreInfoCompleter.future;

  } catch (e) {
      print("에러 발생 : $e [firstBootService]");
      return 4; // 에러 발생 시 4 반환
  }

  return 1;   // 아무 문제없음! MainScreen으로~
}

class FirstBootLegacy {
// class FirstBootService {
//     try{
//       print('SMS전송 권한을 확인합니다... [FirstBootService]');
//       var permissionStatus = await Permission.sms.status;
//       if (!permissionStatus.isGranted) { await Permission.sms.request(); }
      
//       print('하이브 저장소를 초기화합니다. [FIrstBootService]');
//       await HiveService.initHive().whenComplete(() => print('하이브 저장소를 초기화 했습니다! [FirstBootService]')); // 하이브 저장소를 초기화 해줌.
//       print('자동 로그인을 실행합니다. [FIrstBootService]');
//       await ref.read(loginProvider.notifier).requestAutoLogin().whenComplete(() => print('자동로그인 요청을 끝냈습니다. [FirstBootService]'));
//       print('Websocket을 구동합니다. [FIrstBootService]');
//       await ref.read(stompClientStateNotifierProvider.notifier).configureClient().listen((event) {
//         print("!!!!!!!!!!!!!!!! 발생한 이벤트: $event [FIrstBootService]");
//         if (event == StompStatus.CONNECTED) {
//           print("웹소켓 연결됨..... [FIrstBootService]");
//           ref.read(errorStateNotifierProvider.notifier).deleteError(Error.websocket);
//         } else {
//           print("웹소켓 연결되지 않음... [FIrstBootService]");
//           ref.read(errorStateNotifierProvider.notifier).addError(Error.websocket);
//         }
//         print("웹소켓 부팅 서비스를 완료했습니다..... [FIrstBootService]");
//       });
//       print('가게정보를 로드합니다.. [FIrstBootService]');
//       await ref.read(storeDataProvider.notifier).requestStoreData(ref.read(loginProvider.notifier).getLoginData()!.storeCode).whenComplete(
//         () => print('가게정보 요청처리를 완료했습니다. [FirstBootService]')
//       );
//     }catch(error){
//       print('최초부팅 오류 감지 : $error [FIrstBootService]');
//       return false;
//     } finally{
//       ref.watch(firstBootState.notifier).state = true;
//       print('최초부팅 완료... [firstBootService]');
//     }
//     return true;
// }


// final signInProvider = FutureProvider<void>((ref) async {
//   print("로그인 프로바이더 start [SignInProvider]");
//   Completer<void> completer = Completer();
//   bool alreadyLogged = false;  // 로그인 시도 여부를 추적하기 위한 변수

//   // networkStreamProvider를 구독하고, true가 되면 작업을 수행
//   ref.listen<bool>(networkStateNotifier, (prevState, newState) {
//     print("네트워크 status: $newState [SignInProvider]");
//     if (newState && !alreadyLogged) {  // newState가 true이고, alreadyLogged가 false인 경우에만 로그인 시도
//       alreadyLogged = true;  // 로그인 시도 시작을 표시
//       print("네트워크 연결 성공.. 로그인 준비중... [SignInProvider]");
//       ref.read(loginProvider.notifier).requestLoginData(null, null).then((value) {
//         if (value && !completer.isCompleted) {
//           print("로그인 성공 [SignInProvider]");
//           completer.complete();
//         } else if (!completer.isCompleted) {
//           print("로그인 실패: $value [SigninProvider]");
//           completer.completeError("로그인 실패 [SigninProvider]");
//         }
//       }).catchError((error) {
//         if (!completer.isCompleted) {
//           print("최초접속 로그인 에러: $error [SignInProvider]");
//           completer.completeError(error);
//         }
//       });
//     } else if (!newState) {
//       print("네트워크 대기중... [signInProvider]");
//     } 
//   });

//   // Completer의 Future를 반환하여, 외부에서 signInProvider의 완료를 기다릴 수 있도록 함
//   await completer.future;
// });

// final firstBootFutureProvider = FutureProvider<void>((ref) async {
//   final Completer<void> completer = Completer();
//   if (ref.watch(firstBootState.notifier).state) {
//     print("already booted [firstBoot]");
//     return;
//   }

//   print("[First Boot]시작됨");
//   try {
//     await ref.read(signInProvider.future);
//   } catch (error) {
//     print("로그인 에러 in error: $error [FirstBootProvider]");
//     completer.completeError(error);
//   } finally {
//     print('최초실행 로그인 프로세스 종료 ... STOMP 설정... [FIrstBootFutureProvider]');
//     if(ref.read(stompClientStateNotifierProvider) != null){
//       print('이미 STOMP Configure이 진행되어있습니다. [FirstBootFutureProvider]');
//       completer.complete();
//     } else {
//       await ref.read(stompClientStateNotifierProvider.notifier).configureClient().listen((event) {
//         print("!!!!!!!!!!!!!!!! 발생한 이벤트: $event [FirstBootFutureProvider]");
//         if (event == StompStatus.CONNECTED) {
//           print("웹소켓 연결됨..... [FirstBootFutureProvider]");
//           ref.read(errorStateNotifierProvider.notifier).deleteError(Error.websocket);
//         } else {
//           print("웹소켓 연결되지 않음... [FirstBootFutureProvider]");
//           ref.read(errorStateNotifierProvider.notifier).addError(Error.websocket);
//         }
//         // print("웹소켓 이벤트 문제없음~! [FirstBootFutureProvider]");
//         // print('이 프로바이더의 state는 ? -> ${ref.read(firstBootState).toString()} [FirstBootFutureProvider]');
//         completer.complete();
//       });
//     }
//   }
// });

}
