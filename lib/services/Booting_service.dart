// 처음 부팅할 때 필요한 초기화 작업을 수행하는 Provider

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaorre/provider/Data/loginDataProvider.dart';
import 'package:gaorre/provider/Data/storeDataProvider.dart';
import 'package:gaorre/provider/Data/waitingDataProvider.dart';
import 'package:gaorre/provider/Network/connectivityStateNotifier.dart';
import 'package:gaorre/provider/Network/stompClientStateNotifier.dart';
import 'package:gaorre/provider/errorStateNotifier.dart';
import 'package:gaorre/services/HIVE_service.dart';
import 'package:permission_handler/permission_handler.dart';

final firstBootState = StateProvider<bool>((ref) => false);
final container = ProviderContainer(); // 로딩창...때문에...
final isNowRebootState = StateProvider<bool>((ref) => false);

Future<int> reboot(WidgetRef ref) async {
  if (ref.read(firstBootState)) {
    print('최초 실행때는 Reboot을 실행하지 않습니다. [reboot]');
    return -1;
    // 아무것도 검사하지 않고 -1를 반환합니다. 최초실행입니다.
  }
  try {
    ref.read(isNowRebootState.notifier).state = true;
    var stompCompleter = Completer<void>();
    var networkCompleter = Completer<void>();
    var requestLoginData = Completer<void>();
    var requestStoreInfoCompleter = Completer<void>();
    var hiveInitializeCompleter = Completer<void>();

    // 하이브 저장소 초기화
    print('하이브 저장소 상태를 확인합니다. [RebootService]');
    if (HiveService.checkHive()) {
      print('하이브 저장소가 이미 활성화 되어있습니다... [RebootService]');
      hiveInitializeCompleter.complete();
    } else {
      print('하이브 저장소를 초기화합니다... [RebootService]');
      bool hiveSuccess = await HiveService.initHive();
      if (hiveSuccess) {
        hiveInitializeCompleter.complete();
      } else {
        hiveInitializeCompleter.completeError('하이브 초기화 실패..[RebootService]');
      }
    }
    await hiveInitializeCompleter.future;

    // 네트워크 상태 변화를 감지하는 리스너 설정
    print('네트워크를 점검합니다... [RebootService]');
    bool isNetworkConnected = false;
    if (ref.read(networkStateProvider)) {
      print('네트워크 연결이 확인되었습니다. [RebootService]');
      if (!networkCompleter.isCompleted) {
        isNetworkConnected = true;
        networkCompleter.complete();
      }
    } else {
      container.listen<bool>(networkStateProvider, (_, isConnected) {
        if (isConnected) {
          print("네트워크 연결이 확인되었습니다. [RebootService]");
          if (!networkCompleter.isCompleted) {
            isNetworkConnected = true;
            networkCompleter.complete();
          }
        }
      });
    }

    // 10초 후에 타임아웃을 설정하여 네트워크 연결이 없으면 에러를 반환합니다.
    final networkTimeout = Future.delayed(const Duration(seconds: 10), () {
      if (!networkCompleter.isCompleted) {
        print("네트워크 연결이 확인되지 않았습니다. [RebootService]");
        networkCompleter.completeError('Network connection timeout');
      }
    });

    // 네트워크 확인이 끝날때까지 대기
    await Future.any([networkTimeout, networkCompleter.future]);
    if (!isNetworkConnected) {
      print('네트워크 연결 없음! [RebootService]');
      return 3;
    } else {
      print("네트워크 연결 성공! [RebootService]");
      // networkStatusSubscription.cancel();
    }

    // 스텀프 연결을 확인합니다..
    StreamSubscription<StompStatus>? stompSubscription;
    bool isStompConnected = false;
    if (ref.read(stompState.notifier).state == StompStatus.CONNECTED) {
      // 스텀프 연결이 확인되어 있을 때
      print('STOMP웹소켓이 연결되어 있습니다.. [RebootService]');
      isStompConnected = true;
      stompCompleter.complete();
    } else {
      print('STOMP웹소켓이 연결되어있지 않아 ReConfigureClient를 진행합니다...');
      final stompStatusStream =
          ref.read(stompClientStateNotifierProvider.notifier).configureClient();
      stompSubscription = stompStatusStream.listen((status) {
        if (status == StompStatus.CONNECTED) {
          stompSubscription?.cancel();
          isStompConnected = true;
          stompCompleter.complete();
        }
      });
    }

    final stompTimeout = Future.delayed(const Duration(seconds: 5), () {
      if (!stompCompleter.isCompleted) {
        stompSubscription?.cancel();
        // stompCompleter.completeError('STOMP timeout [RebootService]');
      }
    });
    // 10초 후에 타임아웃 처리

    // 스텀프 연결상태 확인을 기다립니다..
    await Future.any([stompCompleter.future, stompTimeout]);

    if (!isStompConnected) {
      // 스텀프 연결 실패
      print('STOMP 연결 실패... [RebootService]');
      return 2; // 2는 웹소켓(STOMP) 연결 에러
    } // STOMP초기화가 완료되었다면 다음 초기화 작업 수행...

    // SMS 권한 요청 확인
    var permissionStatus = await Permission.sms.status;
    if (!permissionStatus.isGranted) {
      await Permission.sms.request();
    }

    // 로그인 정보 확인
    print('로그인 정보 확인... [RebootService]');
    if (ref.read(loginProvider.notifier).getLoginData() != null) {
      print('로그인 정보 확인 완료... [RebootService]');
      requestLoginData.complete();
    } else {
      print('로그인 정보가 확인되지 않음... 자동 로그인 시도... [RebootService]');
      bool autoLoginResult =
          await ref.read(loginProvider.notifier).requestAutoLogin();
      if (!autoLoginResult) {
        requestLoginData.completeError("최초 로그인 정보가 존재하지 않음");
        return 0; // 최초 화면으로..
      } else {
        requestLoginData.complete();
      }
    }
    await requestLoginData.future;

    // 가게 정보 취득 시도
    print('가게정보 취득 시도... [RebootService]');
    if (ref.read(storeDataProvider.notifier).getStoreData() != null) {
      print('가게정보 확인 완료. [RebootService]');
      requestStoreInfoCompleter.complete();
    } else {
      print('가게정보 확인 실패... 재취득 요청... [RebootService]');
      bool retrieveStoreDataResult = await ref
          .read(storeDataProvider.notifier)
          .requestStoreData(
              ref.read(loginProvider.notifier).getLoginData()!.storeCode);
      if (!retrieveStoreDataResult) {
        requestStoreInfoCompleter.completeError('가게정보 수신 실패');
        return 0; // 최초 화면으로
      } else {
        requestStoreInfoCompleter.complete();
        // 마지막으로 웨이팅 마감 시간 정보를 로딩합니다......
      }
    }
    await requestStoreInfoCompleter.future;
  } catch (e) {
    print("에러 발생 : $e [RebootService]");
    return 4; // 원인미상 에러 발생 시 4 반환
  } finally {
    print('마지막으로 각 웨이팅별 입장마감시간 정보를 가져옵니다... [Reboot]');
    ref.read(waitingProvider.notifier).reloadEntryTime();
    ref.read(isNowRebootState.notifier).state = false;
    return 1; // 아무 문제없음! MainScreen으로~
  }
  // print('마지막으로 각 웨이팅별 입장마감시간 정보를 가져옵니다... [Reboot]');
  // ref.read(waitingProvider.notifier).reloadEntryTime();
  // return 1;   // 아무 문제없음! MainScreen으로~
}

Future<int> firstBoot(WidgetRef ref) async {
  try {
    // var networkStatus = ref.read(networkStateProvider);
    var stompCompleter = Completer<void>();
    var networkCompleter = Completer<void>();
    var requestLoginData = Completer<void>();
    var requestStoreInfoCompleter = Completer<void>();
    var hiveInitializeCompleter = Completer<void>();

    // 하이브 저장소 초기화
    print('하이브 저장소를 초기화합니다. [FIrstBootService]');
    bool hiveSuccess = await HiveService.initHive();
    if (hiveSuccess) {
      hiveInitializeCompleter.complete();
    } else {
      hiveInitializeCompleter.completeError('하이브 초기화 실패..[firstBootService]');
    }
    await hiveInitializeCompleter.future;

    // 네트워크 연결 확인
    print('네트워크 연결을 확인합니다... [firstBootService]');
    bool isNetworkConnected = false;
    container.listen<bool>(networkStateProvider, (_, isConnected) {
      if (isConnected) {
        print("네트워크 연결이 확인되었습니다. [firstBootService]");
        if (!networkCompleter.isCompleted) {
          isNetworkConnected = true;
          networkCompleter.complete();
        }
      }
    });

    // 10초 후에 타임아웃을 설정하여 네트워크 연결이 없으면 에러를 반환합니다.
    final networkTimeout = Future.delayed(const Duration(seconds: 10), () {
      if (!networkCompleter.isCompleted) {
        print("네트워크 연결이 확인되지 않았습니다. [firstBootService]");
        networkCompleter.completeError('Network connection timeout');
      }
    });

    await networkCompleter.future;
    if (!isNetworkConnected) {
      return 3; // 네트워크 미연결 오류 페이지로 이동
    }

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

    if (!isStompConnected) {
      // 스텀프 연결 실패
      print('STOMP 연결 실패... [firstBootService]');
      return 2; // 2는 STOMP 연결 에러
    } // STOMP초기화가 완료되었다면 다음 초기화 작업 수행...

    // SMS 권한 요청 확인
    var permissionStatus = await Permission.sms.status;
    if (!permissionStatus.isGranted) {
      await Permission.sms.request();
    }

    // 자동로그인 시도
    bool autoLoginResult =
        await ref.read(loginProvider.notifier).requestAutoLogin();
    if (!autoLoginResult) {
      requestLoginData.completeError("최초 로그인 정보가 존재하지 않음");
      return 0; // 최초 화면으로..
    } else {
      requestLoginData.complete();
    }

    print('로그인정보 요청이 끝날때 까지 대기합니다.. [FirstBootService]');
    await requestLoginData.future;

    // 가게 정보 취득 시도
    print('가게정보 요청을 전송합니다. [FirstBootService]');
    bool retrieveStoreDataResult = await ref
        .read(storeDataProvider.notifier)
        .requestStoreData(
            ref.read(loginProvider.notifier).getLoginData()!.storeCode);

    // 웨이팅 마감 시간 정보를 로딩합니다......
    ref.read(waitingProvider.notifier).reloadEntryTime();

    if (!retrieveStoreDataResult) {
      requestStoreInfoCompleter.completeError('가게정보 수신 실패');
      return 0; // 최초 화면으로
    } else {
      requestStoreInfoCompleter.complete();
    }

    await requestStoreInfoCompleter.future;
  } catch (e) {
    print("에러 발생 : $e [firstBootService]");
    return 4; // 에러 발생 시 4 반환
  }

  // print('마지막으로 기존 웨이팅 데이터의 입장마감시간 정보를 가져옵니다... [FirstBoot]');
  // ref.read(firstBootState.notifier).state = true;
  return 1; // 아무 문제없음! MainScreen으로~
}
