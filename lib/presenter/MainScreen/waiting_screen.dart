import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:orre_manager/presenter/Widget/WaitingPage/AddWaitingPopup.dart';
import 'package:orre_manager/presenter/Widget/WaitingPage/CallButton.dart';
import 'package:orre_manager/presenter/MainScreen/management_screen.dart';
import 'package:orre_manager/presenter/MainScreen/table_status_screen.dart';
import 'package:orre_manager/presenter/Widget/WaitingPage/waiting_adding_screen.dart';
import 'package:orre_manager/provider/Data/loginDataProvider.dart';
import 'package:orre_manager/Coding_references/stompClientFutureProvider.dart';
import 'package:orre_manager/provider/Data/waitingAvailableStatusProvider.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import '../../Model/login_data_model.dart';
import '../../Model/waiting_data_model.dart';
import '../../provider/Data/waitingDataProvider.dart';

class StoreScreenWidget extends ConsumerWidget {
  StoreScreenWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final stompClientAsyncValue = ref.watch(stompClientProvider);

    // return stompClientAsyncValue.when(
    //   data: (stompClient) => StoreScreenBody(loginData: loginResponse),
    //   loading: () => _LoadingScreen(),
    //   error: (error, stackTrace) => _ErrorScreen(error),
    // );
    return StoreScreenBody();
  }
}

class StoreScreenBody extends ConsumerStatefulWidget {
  StoreScreenBody();

  @override
  StoreScreenBodyState createState() => StoreScreenBodyState();
}

class StoreScreenBodyState extends ConsumerState<StoreScreenBody> {
  late int storeCode;
  late LoginData? loginData;
  late int waitingAvailableState;
  int minutesToAdd = 1;
  WaitingData? currentWaitingData;
  bool isSubscribed = false;
  late bool switchValue;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    loginData = ref.read(loginProvider.notifier).getLoginData();
    storeCode = loginData!.storeCode;
    // waitingAvailableState = ref.read(waitingAvailableStatusStateProvider.notifier).loadWaitingAvailableStatus();
    final waitingNotifier = ref.read(waitingProvider.notifier);
    if (!isSubscribed) {
      waitingNotifier.subscribeToWaitingData(storeCode);
      waitingNotifier.sendWaitingData(storeCode);
      isSubscribed = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    waitingAvailableState = ref.watch(waitingAvailableStatusStateProvider);
    currentWaitingData = ref.watch(waitingProvider);
    switchValue = waitingAvailableState == 0 ? true : false;
    
    if(currentWaitingData == null){
      return _LoadingScreen();
    }
    
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.23,
              decoration: BoxDecoration(
                color: Color(0xFF72AAD8),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 50, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end, // 오른쪽으로 정렬
                      children: [
                        Text(
                          '웨이팅 설정',
                          style: TextStyle(
                            fontFamily: 'Dovemayo_gothic',
                            fontSize: 24,
                            color: Color(0xFFE6F4FE),
                          ),
                        ),
                        SizedBox(width: 10), // 간격 조절
                        LiteRollingSwitch(
                          //initial value
                          value: switchValue,
                          textOn: 'ON',
                          textOff: 'OFF',
                          colorOn: Color(0xFFE6F4FE),
                          colorOff: Color(0xFFDFDFDF),
                          textOnColor: Color(0xFF72AAD8),
                          textOffColor: Colors.white,
                          iconOn: Icons.done,
                          iconOff: Icons.remove_circle_outline,
                          textSize: 16.0,
                          onTap: () {}, // null 값을 전달하여 콜백 함수를 사용하지 않음
                          onDoubleTap: () {}, // null 값을 전달하여 콜백 함수를 사용하지 않음
                          onSwipe: () {}, // null 값을 전달하여 콜백 함수를 사용하지 않음
                          onChanged: (bool state) {
                            //Use it to manage the different states
                            print('Current State of SWITCH IS: $state');
                          },
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Consumer(
                          builder: (context, ref, child) {
                            print('waitingData에 변동점이 생겼으므로 리빌드합니다.');
                            ref.watch(waitingProvider);
                            final int currentWaitingCount = ref.watch(
                              waitingProvider.select(
                                  (data) => data?.teamInfoList.length ?? 0),
                            );
                            return Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: Row(
                                children: [
                                  Text(
                                    '현재 대기 팀수',
                                    style: TextStyle(
                                      fontFamily: 'Dovemayo_gothic',
                                      fontSize: 32,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '  $currentWaitingCount',
                                    style: TextStyle(
                                      fontFamily: 'Dovemayo_gothic',
                                      fontSize: 42,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    ' 팀',
                                    style: TextStyle(
                                      fontFamily: 'Dovemayo_gothic',
                                      fontSize: 32,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 20),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) =>
                                WaitingAddingScreen()
                              )
                            );
                          },
                          child: Image.asset(
                            'assets/image/button/waiting adding.png',
                            width: 30,
                            height: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 여기서 ListView 를 사용하도록 수정합니다.
            Expanded(
              child: ListView.builder(
                itemCount: currentWaitingData!.teamInfoList.length,
                itemBuilder: (context, index) {
                  WaitingTeam? team = currentWaitingData!.teamInfoList[index];
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
                      textColor = Colors.black; // 기본값, 필요에 따라 변경 가능
                  }

                  // 마감까지 남은 시간 계산
                  Duration? timeRemaining;
                  String? remainingTimeString;

                  if (team.entryTime != null) {
                    timeRemaining = team.entryTime!.difference(DateTime.now());
                    remainingTimeString =
                        '${timeRemaining.inHours.toString().padLeft(2, '0')}:${(timeRemaining.inMinutes % 60).toString().padLeft(2, '0')}';
                  } else {
                    remainingTimeString = 'Unknown';
                  }

                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 1,
                            child: IconButton(
                              onPressed: () {
                                ref
                                    .read(waitingProvider.notifier)
                                    .requestUserDelete(
                                        context, storeCode, team.waitingNumber);
                              },
                              icon:
                                  Icon(Icons.delete, color: Color(0xFFDFDFDF)),
                              iconSize: 30,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 4, // 더 넓은 공간을 차지하도록 설정
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '대기번호 ${team.waitingNumber}번',
                                      style: TextStyle(
                                        fontFamily: 'Dovemayo_gothic',
                                        fontSize: 20,
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    Text(
                                      '${team.personNumber}명',
                                      style: TextStyle(
                                        fontFamily: 'Dovemayo_gothic',
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '상태 : $guestStatus',
                                  style: TextStyle(
                                    fontFamily: 'Dovemayo_gothic',
                                    fontSize: 16,
                                    color: textColor,
                                  ),
                                ),
                                Text(
                                  '${team.phoneNumber}',
                                  style: TextStyle(
                                    fontFamily: 'Dovemayo_gothic',
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // 알람 버튼을 클릭하면, 해당 위치에 이미지와 타이머 뜨게 구현
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                if(team.entryTime != null)
                                  IconButton(
                                    icon: Icon(Icons.check_box), // 초록색 체크박스 아이콘
                                    onPressed: () async {
                                      print('${team.waitingNumber}번 입장처리 요청 [waitinScreen]');
                                      await ref.read(waitingProvider.notifier).confirmEnterance(
                                        ref.context, loginData!, team.waitingNumber
                                      );
                                      // print('Checked options for ${team.waitingNumber}');
                                    },
                                  )
                                else
                                  SizedBox(width: 48),
                                CallIconButton(
                                  waitingNumber: team.waitingNumber,
                                  storeCode: storeCode,
                                  minutesToAdd: minutesToAdd,
                                  ref: ref, phoneNumber: team.phoneNumber,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Divider(
                          color: Color(0xFFDFDFDF),
                          thickness: 1,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly, // 가로로 공간을 균등하게 배치합니다.
              children: [
                // ElevatedButton(
                //   onPressed: () {
                //     ref.read(waitingProvider.notifier).requestUserCall(
                //         context,
                //         currentWaitingData!.teamInfoList[0].phoneNumber,
                //         currentWaitingData!.teamInfoList[0].waitingNumber,
                //         storeCode,
                //         minutesToAdd);
                //   },
                //   child: Text('손님 호출하기'),
                // ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) =>
                            TableManagementScreen()));
                  },
                  child: Text('좌석페이지'),
                ),

              ],
            ),
          ],
        ),
      ),
    );

    // return Scaffold(
    //   appBar: AppBar(title: Text('Store Page')),
    //   body: currentWaitingData == null
    //       ? _LoadingScreen()
    //       : buildWaitingScreen(),
    //   floatingActionButton: buildAddingWaitingTeam(),
    // );
  }

  Widget buildInitialScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('매장코드 : $storeCode', style: TextStyle(fontSize: 20)),
          ElevatedButton(
            onPressed: () {ref.read(waitingProvider.notifier).sendWaitingData(loginData!.storeCode);}, // No action needed, already subscribed and data sent
            child: Text("웨이팅정보 수신하기"),
          ),
        ],
      ),
    );
  }

  Widget buildWaitingScreen() {
    _startTimerForTeamDeletion(ref);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Consumer(
            builder: (context, ref, child) {
              ref.watch(waitingProvider);
              final currentWaitingCount = ref.watch(waitingProvider.select((data) => data?.teamInfoList.length ?? 0));
              return Text('현재 대기 팀수 : $currentWaitingCount', style: TextStyle(fontSize: 24));
            },
          ),
          ElevatedButton(onPressed: () {
            ref.read(loginProvider.notifier).logout();
            Navigator.pop(context);
            }, child: Text('로그아웃')),
          ElevatedButton(onPressed: () {
            ref.read(waitingAvailableStatusStateProvider.notifier).changeAvailableStatus(loginData!);
            }, 
            child: Text('현재 웨이팅 가능 상태 : $waitingAvailableState. 0이면 웨이팅추가가능, 1이면 웨이팅추가불가')
            ),
          Expanded(
            child: ListView.builder(
              itemCount: currentWaitingData!.teamInfoList.length,
              itemBuilder: (context, index) {
                WaitingTeam? team = currentWaitingData!.teamInfoList[index];
                return ListTile(
                  title: Text('예약 번호 : ${team.waitingNumber}'),
                  subtitle: buildSubtitle(team),
                  trailing: buildTrailingButtons(team, ref),
                );
              },
            ),
          ),
          buildFooterButtons(),
        ],
      ),
    );
  }

  Column buildSubtitle(WaitingTeam team) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('상태 : ${_getGuestStatus(team.status)}'),
        Text('연락처 : ${team.phoneNumber}'),
        if (team.entryTime != null)
          StreamBuilder<Duration>(
            stream: startCountdown(team.entryTime),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text('Calculating...');
              } else if (snapshot.hasData) {
                final mins = snapshot.data!.inMinutes.remainder(60).toString().padLeft(2, '0');
                final secs = snapshot.data!.inSeconds.remainder(60).toString().padLeft(2, '0');
                return Text('입장마감까지 남은 시간 : $mins:$secs');
              } else {
                return Text('Time expired');
              }
            },
          ),
      ],
    );
  }

  Row buildTrailingButtons(WaitingTeam team, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CallIconButton(
          phoneNumber: team.phoneNumber,
          waitingNumber: team.waitingNumber,
          storeCode: storeCode,
          minutesToAdd: minutesToAdd,
          ref: ref,
        ),
        SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => ref.read(waitingProvider.notifier).requestUserDelete(ref.context, storeCode, team.waitingNumber),
          child: const Text('웨이팅 삭제하기'),
        ),
      ],
    );
  }

  Row buildFooterButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {
            ref.read(waitingProvider.notifier).requestUserCall(
              ref.context,
              currentWaitingData!.teamInfoList[0].phoneNumber,
              currentWaitingData!.teamInfoList[0].waitingNumber,
              storeCode,
              minutesToAdd);
          },
          child: Text('다음손님 호출하기'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(ref.context).push(MaterialPageRoute(
              builder: (BuildContext context) =>
                ManagementScreenWidget()));
          },
          child: Text('가게 정보 수정하기'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(ref.context).push(MaterialPageRoute(
              builder: (BuildContext context) =>
                TableManagementScreen()));
          },
          child: Text('테이블 관리하기'),
        ),
      ],
    );
  }

  Widget buildAddingWaitingTeam() {
    return FloatingActionButton(
      onPressed: () => showAddWaitingDialog(ref.context),
      child: Icon(Icons.person_add),
      tooltip: '웨이팅팀 수동 추가하기',);
  }

  String _getGuestStatus(int status) {
    switch (status) {
      case 1: return '대기중';
      case 2: return '착석 완료';
      case 3: return '삭제 완료';
      default: return 'Unknown';
    }
  }

  Stream<Duration> startCountdown(DateTime? startTime) {
    return Stream.periodic(Duration(seconds: 1), (count) {
      return startTime!.difference(DateTime.now());
    }).map((duration) => Duration(seconds: duration.inSeconds.abs()));
  }

  void _startTimerForTeamDeletion(WidgetRef ref) {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      for (var team in currentWaitingData!.teamInfoList) {
        if (team.entryTime != null && team.entryTime!.difference(DateTime.now()) <= Duration.zero) {
          await ref.read(waitingProvider.notifier).requestUserDelete(ref.context, storeCode, team.waitingNumber);
          break;
        }
      }
    });
  }
}


class _LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manager screen')),
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

// class _ErrorScreen extends StatelessWidget {
//   final dynamic error;
  
//   _ErrorScreen(this.error);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Manager screen')),
//       body: Center(child: Text('Error: $error')),
//     );
//   }
// }

