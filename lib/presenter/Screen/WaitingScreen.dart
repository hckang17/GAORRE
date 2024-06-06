import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaorre/Model/WaitingLogDataModel.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:gaorre/presenter/Widget/WaitingPage/CallButton.dart';
import 'package:gaorre/presenter/Screen/StoreManagerScreen.dart';
import 'package:gaorre/presenter/Screen/TableScreen.dart';
import 'package:gaorre/presenter/Widget/WaitingPage/ShowWaitingLog.dart';
import 'package:gaorre/presenter/Widget/WaitingPage/AddWaitingScreen.dart';
import 'package:gaorre/presenter/Widget/AlertDialog.dart';
import 'package:gaorre/provider/Data/AddWaitingTimeProvider.dart';
import 'package:gaorre/provider/Data/UserLogProvider.dart';
import 'package:gaorre/provider/Data/loginDataProvider.dart';
import 'package:gaorre/provider/Data/storeDataProvider.dart';
import 'package:gaorre/services/HIVE_service.dart';
import '../../Model/LoginDataModel.dart';
import '../../Model/WaitingDataModel.dart';
import '../../provider/Data/waitingDataProvider.dart';

class WaitingScreenWidget extends ConsumerWidget {
  WaitingScreenWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WaitingScreenBody();
  }
}

class WaitingScreenBody extends ConsumerStatefulWidget {
  WaitingScreenBody();

  @override
  WaitingScreenBodyState createState() => WaitingScreenBodyState();
}

class WaitingScreenBodyState extends ConsumerState<WaitingScreenBody> {
  late int storeCode;
  late LoginData? loginData;
  late int waitingAvailableState;
  WaitingData? currentWaitingData;
  bool isSubscribed = false;
  late bool switchValue;

  @override
  void initState() {
    super.initState();
    // loginData 가져오기 및 null 체크
    loginData = ref.read(loginProvider.notifier).getLoginData();
    if (loginData != null) {
      storeCode = loginData!.storeCode;
      final waitingNotifier = ref.read(waitingProvider.notifier);
      final userLogDataListNotifier = ref.read(userLogProvider.notifier);
      if (!isSubscribed) {
        waitingNotifier.subscribeToWaitingData(storeCode);
        waitingNotifier.sendWaitingData(storeCode);
        isSubscribed = true;
        // 마지막으로 기존에 있던 웨이팅 정보들 다시 읽어옴...
        // ref.read(waitingProvider.notifier).reloadEntryTime();
        userLogDataListNotifier.subscribeToLogData(storeCode);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    waitingAvailableState =
        ref.watch(storeDataProvider.select((value) => value!.waitingAvailable));
    currentWaitingData = ref.watch(waitingProvider);
    loginData = ref.watch(loginProvider);
    switchValue = waitingAvailableState == 0 ? true : false;

    if (currentWaitingData == null) {
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
                          value: switchValue,
                          textOn: '접수',
                          textOff: '미접수',
                          colorOn: Color(0xFFE6F4FE),
                          colorOff: Color(0xFFDFDFDF),
                          textOnColor: Color(0xFF72AAD8),
                          textOffColor: Colors.white,
                          iconOn: Icons.done,
                          iconOff: Icons.remove_circle_outline,
                          textSize: 16.0,
                          onChanged: (bool newState) async {
                            if (!newState) {
                              //false일 때, -> 웨이팅 안받음.
                              await showAlertDialog(ref.context, "웨이팅 접수",
                                  "지금부터 신규 웨이팅 접수를 받지 않습니다.", null);
                            } else {
                              await showAlertDialog(ref.context, "웨이팅 접수",
                                  "지금부터 신규 웨이팅 접수를 받습니다!", null);
                            }
                          },
                          onDoubleTap: () => null,
                          onSwipe: () => null,
                          onTap: () async {
                            bool success = await ref
                                .read(storeDataProvider.notifier)
                                .changeAvailableStatus(ref
                                    .read(loginProvider.notifier)
                                    .getLoginData()!);
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
                                    WaitingAddingScreen()));
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
                              onPressed: () async {
                                bool confirmation = await showConfirmDialog(
                                    ref.context,
                                    "대기 고객 삭제",
                                    "${team.waitingNumber}번 고객님을 정말 웨이팅 취소(노쇼)처리 하시겠습니까?");
                                if (confirmation) {
                                  ref
                                      .read(waitingProvider.notifier)
                                      .requestUserDelete(context, storeCode,
                                          team.waitingNumber);
                                }
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
                                if (team.entryTime != null)
                                  IconButton(
                                    icon: Icon(Icons.check_box,
                                        color: Colors.green), // 초록색 체크박스 아이콘
                                    onPressed: () async {
                                      print('${team.waitingNumber}번 입장처리 요청 [waitinScreen]');
                                      bool confirmation = await showConfirmDialog(ref.context, "고객 입장처리",
                                        "${team.waitingNumber}번 고객님을 입장처리 하시겠습니까?");
                                      if (confirmation) {
                                        print('입장처리를 진행하겠습니다. [waitingScreen]');
                                        bool result = await ref.read(waitingProvider.notifier).confirmEnterance(ref.context,
                                          loginData!, team.waitingNumber);
                                        if(result){
                                          print('입장처리 성공 [WaitingScreen]');
                                        }
                                      }
                                      // print('Checked options for ${team.waitingNumber}');
                                    },
                                  )
                                else
                                  SizedBox(width: 48),
                                CallIconButton(
                                  waitingTeam: team,
                                  storeCode: storeCode,
                                  minutesToAdd: ref.read(minutesToAddProvider.notifier).getState(),
                                  ref: ref,
                                  phoneNumber: team.phoneNumber,
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await ref.read(userLogProvider.notifier).retrieveUserLogData(
              ref.read(loginProvider.notifier).getLoginData()!);
          showWaitingLog(ref);
        },
        child: Icon(Icons.assignment,  color: Color(0xFF72AAD8),),
        backgroundColor: Colors.white // 로그 확인 아이콘
      ),
    );
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

// // class _ErrorScreen extends StatelessWidget {
// //   final dynamic error;

// //   _ErrorScreen(this.error);

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text('Manager screen')),
// //       body: Center(child: Text('Error: $error')),
// //     );
// //   }
// // }

///
/// 이 아래에 원래 메뉴버튼을 두려고 했으나...

// Row(
//   mainAxisAlignment:
//       MainAxisAlignment.spaceEvenly, // 가로로 공간을 균등하게 배치합니다.
//   children: [
//     // ElevatedButton(
//     //   onPressed: () {
//     //     ref.read(waitingProvider.notifier).requestUserCall(
//     //         context,
//     //         currentWaitingData!.teamInfoList[0].phoneNumber,
//     //         currentWaitingData!.teamInfoList[0].waitingNumber,
//     //         storeCode,
//     //         minutesToAdd);
//     //   },
//     //   child: Text('손님 호출하기'),
//     // ),
//     // ElevatedButton(
//     //   onPressed: () {
//     //     Navigator.of(context).push(MaterialPageRoute(
//     //         builder: (BuildContext context) =>
//     //             TableManagementScreen()));
//     //   },
//     //   child: Text('좌석페이지'),
//     // ),
//   ],
// ),
