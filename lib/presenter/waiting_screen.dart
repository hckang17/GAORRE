import 'dart:async';
import 'dart:js';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/presenter/management_screen.dart';
import 'package:orre_manager/presenter/table_status_screen.dart';
import 'package:orre_manager/provider/stomp_client_future_provider.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import '../Model/login_data_model.dart';
import '../Model/waiting_data_model.dart';
import '../provider/waiting_provider.dart';

class StoreScreenWidget extends ConsumerWidget {
  final LoginData loginResponse;
  StoreScreenWidget({required this.loginResponse});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stompClientAsyncValue = ref.watch(stompClientProvider);

    return stompClientAsyncValue.when(
      data: (stompClient) {
        return _StoreScreenBody(loginData: loginResponse);
      },
      loading: () {
        // 로딩 중이면 로딩 스피너를 표시합니다.
        return _LoadingScreen();
      },
      error: (error, stackTrace) {
        // 에러가 발생하면 에러 메시지를 표시합니다.
        return _ErrorScreen(error);
      },
    );
  }
}

class _StoreScreenBody extends ConsumerWidget {
  final LoginData loginData;
  late int storeCode;
  int minutesToAdd = 1;
  WaitingData? currentWaitingData;
  bool isSubscribed = false;
  Timer? _timer;

  _StoreScreenBody({required this.loginData});

  void subscribeProcess(WidgetRef ref, BuildContext context) {
    if (currentWaitingData == null && !isSubscribed) {
      storeCode = loginData.storeCode;
      final waitingNotifier = ref.read(waitingProvider.notifier);
      waitingNotifier.subscribeToWaitingData(storeCode);
      // waitingNotifier.subscribeToCallGuest(context, storeCode);
      isSubscribed = true; // sendWaitingData가 한 번만 호출되도록 설정
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //waitingData의 값을 감시할것.
    currentWaitingData = ref.watch(waitingProvider);

    // 최초 빌드 시 한 번만 서브스크립션을 설정합니다.
    subscribeProcess(ref, context);

    // 웨이팅정보요청을 build될 때 마다 보내면, 무한루프 즉 BadStateException에 빠지는 것을 확인했음.
    // 따라서.. 수동으로 1회 정보요청을
    if (currentWaitingData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Store Page'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '매장코드 : $storeCode',
                style: TextStyle(fontSize: 20),
              ),
              ElevatedButton(
                onPressed: () {
                  ref.read(waitingProvider.notifier).sendWaitingData(storeCode);
                },
                child: Text("웨이팅정보 수신하기"),
              ),
            ],
          ),
        ),
      );
    }

    _startTimerForTeamDeletion(ref);

    return Scaffold(
      appBar: AppBar(
        title: Text('Store Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Consumer(
              builder: (context, ref, child) {
                print('waitingData에 변동점이 생겼으므로 리빌드합니다.');
                ref.watch(waitingProvider);
                final int currentWaitingCount = ref
                    .watch(waitingProvider
                        .select((data) => data?.teamInfoList.length ?? 0));
                return Text(
                  '현재 대기 팀수 : $currentWaitingCount',
                  // ignore: prefer_const_constructors
                  style: TextStyle(fontSize: 24),
                );
              },
            ),
            // 여기서 ListView 를 사용하도록 수정합니다.
            Expanded(
              child: ListView.builder(
                itemCount: currentWaitingData!.teamInfoList.length,
                itemBuilder: (context, index) {
                  WaitingTeam? team =
                      currentWaitingData!.teamInfoList[index];
                  Color textColor;
                  String? guestStatus;
                  switch (team.status) {
                    case 1:
                      textColor = Colors.blue;
                      guestStatus = '대기중';
                      break;
                    case 2:
                      textColor = Colors.green;
                      guestStatus = '착석 완료';
                      break;
                    case 3:
                      textColor = Colors.red;
                      guestStatus = '삭제 완료';
                      break;
                    default:
                      textColor = Colors
                          .black; // 기본값, 필요에 따라 변경 가능
                  }

                  // 마감까지 남은 시간 계산
                  Duration? timeRemaining;
                  String? remainingTimeString;

                  if (team.entryTime != null) {
                    timeRemaining =
                        team.entryTime!.difference(DateTime.now());
                    remainingTimeString =
                        '${timeRemaining.inMinutes.remainder(60).toString().padLeft(2, '0')}:${timeRemaining.inSeconds.remainder(60).toString().padLeft(2, '0')}';
                  } else {
                    remainingTimeString = 'Unknown';
                  }

                  return ListTile(
                    title:
                        Text('예약 번호 : ${team.waitingNumber}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '상태 : $guestStatus',
                          style: TextStyle(
                            color: textColor,
                          ),
                        ),
                        Text('연락처 : ${team.phoneNumber}'),
                        if (team.entryTime != null)
                          StreamBuilder<Duration>(
                            stream: startCountdown(team.entryTime),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Text('Calculating...');
                              } else if (snapshot.hasData) {
                                final remainingTimeString =
                                    '${snapshot.data!.inMinutes.remainder(60).toString().padLeft(2, '0')}:${snapshot.data!.inSeconds.remainder(60).toString().padLeft(2, '0')}';
                                return Text(
                                    '입장마감까지 남은 시간 : $remainingTimeString');
                              } else {
                                return Text('Unknown');
                              }
                            },
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            ref.read(waitingProvider.notifier).requestUserCall(
                                  context,
                                  team.waitingNumber,
                                  storeCode,
                                  minutesToAdd,
                                );
                          },
                          child: const Text('호출하기'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            ref.read(waitingProvider.notifier)
                                .requestUserDelete(
                              context,
                              storeCode,
                              team.waitingNumber,
                            );
                          },
                          child: const Text('웨이팅 삭제하기'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    ref.read(waitingProvider.notifier).requestUserCall(
                      context,
                      currentWaitingData!.teamInfoList[0].waitingNumber,
                      storeCode,
                      minutesToAdd);
                  },
                  child: Text('다음손님 호출하기'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) =>
                        ManagementScreenWidget(loginResponse: loginData)));
                  },
                  child: Text('가게 정보 수정하기'), // '가게 관리하기' 버튼 추가
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) =>
                        TableManagementScreen(loginResponse: loginData)));
                  },
                  child: Text('테이블 관리하기'), // '테이블 관리하기' 버튼 추가
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 카운트다운을 시작하는 메서드
  Stream<Duration> startCountdown(DateTime? startTime) {
    if (startTime != null) {
      final countdownStream = Stream<Duration>.periodic(
        Duration(seconds: 1),
        (count) => startTime.difference(DateTime.now()),
      );
      return countdownStream.map((duration) => Duration(seconds: duration.inSeconds.abs()));
    } else {
      return Stream<Duration>.value(Duration(seconds: 0));
    }
  }

  void _startTimerForTeamDeletion(WidgetRef ref) {
    _timer?.cancel(); // 기존 타이머가 있으면 취소

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      // 각 팀의 입장 마감 시간을 확인하고, 시간이 지났으면 삭제 요청을 보냄
      for (WaitingTeam team in currentWaitingData!.teamInfoList) {
        if (team.entryTime != null) {
          Duration timeRemaining = team.entryTime!.difference(DateTime.now());
          if (timeRemaining <= Duration.zero) {
            ref.read(waitingProvider.notifier).requestUserDelete(
              ref.context,
              storeCode,
              team.waitingNumber,
            );
          }
        }
      }
    });
  }
}

class _LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manager screen'),
      ),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final dynamic error;

  _ErrorScreen(this.error);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manager screen'),
      ),
      body: Center(
        child: Text('Error: $error'),
      ),
    );
  }
}