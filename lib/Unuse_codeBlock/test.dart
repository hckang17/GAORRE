// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:orre_manager/presenter/table_status_screen.dart';
// import 'package:orre_manager/provider/stomp_client_future_provider.dart';
// import 'package:stomp_dart_client/stomp.dart';
// import 'package:stomp_dart_client/stomp_frame.dart';
// import '../Model/login_data_model.dart';
// import '../Model/waiting_data_model.dart';
// import '../provider/waiting_provider.dart';

// import 'package:lite_rolling_switch/lite_rolling_switch.dart';
// import 'waiting_adding_screen.dart';

// class StoreScreenWidget extends ConsumerWidget {
//   final LoginData loginResponse;
//   StoreScreenWidget({required this.loginResponse});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final stompClientAsyncValue = ref.watch(stompClientProvider);

//     return stompClientAsyncValue.when(
//       data: (stompClient) {
//         return _StoreScreenBody(loginData: loginResponse);
//       },
//       loading: () {
//         // 로딩 중이면 로딩 스피너를 표시합니다.
//         return _LoadingScreen();
//       },
//       error: (error, stackTrace) {
//         // 에러가 발생하면 에러 메시지를 표시합니다.
//         return _ErrorScreen(error);
//       },
//     );
//   }
// }

// class _StoreScreenBody extends ConsumerWidget {
//   final LoginData loginData;
//   late int storeCode;
//   int minutesToAdd = 6;
//   WaitingData? currentWaitingData;
//   bool isSubscribed = false;

//   var switchValue = true; // 스위치를 위한 부울변수, true 일때 웨이팅 활성화
//   bool buttonPressed = false; // 알림버튼이 눌렸는지 확인할 변수

//   _StoreScreenBody({required this.loginData});

//   void subscribeProcess(WidgetRef ref, BuildContext context) {
//     if (currentWaitingData == null && !isSubscribed) {
//       storeCode = loginData!.storeCode;
//       final waitingNotifier = ref.read(waitingProvider.notifier);
//       waitingNotifier.subscribeToWaitingData(storeCode);
//       waitingNotifier.subscribeToCallGuest(context, storeCode);
//       isSubscribed = true; // sendWaitingData가 한 번만 호출되도록 설정
//     }
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     //waitingData의 값을 감시할것.
//     currentWaitingData = ref.watch(waitingProvider);

//     // 최초 빌드 시 한 번만 서브스크립션을 설정합니다.
//     subscribeProcess(ref, context);

//     bool button_on_pressed = false;

//     // 웨이팅정보요청을 build될 때 마다 보내면, 무한루프 즉 BadStateException에 빠지는 것을 확인했음.
//     // 따라서.. 수동으로 1회 정보요청을
//     if (currentWaitingData == null) {
//       return Scaffold(
//         appBar: AppBar(
//           title: Text('Store Page'),
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 '매장코드 : $storeCode',
//                 style: TextStyle(fontSize: 20),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   ref.read(waitingProvider.notifier).sendWaitingData(storeCode);
//                 },
//                 child: Text("웨이팅정보 수신하기"),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       body: Center(
//         child: Column(
//           children: [
//             Container(
//               width: MediaQuery.of(context).size.width,
//               height: MediaQuery.of(context).size.height * 0.23,
//               decoration: BoxDecoration(
//                 color: Color(0xFF72AAD8),
//                 borderRadius: BorderRadius.only(
//                   bottomLeft: Radius.circular(30),
//                   bottomRight: Radius.circular(30),
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   Padding(
//                     padding: EdgeInsets.only(top: 50, right: 20),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.end, // 오른쪽으로 정렬
//                       children: [
//                         Text(
//                           '웨이팅 설정',
//                           style: TextStyle(
//                             fontFamily: 'Dovemayo_gothic',
//                             fontSize: 24,
//                             color: Colors.white,
//                           ),
//                         ),
//                         SizedBox(width: 10), // 간격 조절
//                         LiteRollingSwitch(
//                           //initial value
//                           value: switchValue,
//                           textOn: 'ON',
//                           textOff: 'OFF',
//                           colorOn: Color(0xFFE6F4FE),
//                           colorOff: Color(0xFFDFDFDF),
//                           textOnColor: Color(0xFF72AAD8),
//                           textOffColor: Colors.white,
//                           iconOn: Icons.done,
//                           iconOff: Icons.remove_circle_outline,
//                           textSize: 16.0,
//                           onTap: () {}, // null 값을 전달하여 콜백 함수를 사용하지 않음
//                           onDoubleTap: () {}, // null 값을 전달하여 콜백 함수를 사용하지 않음
//                           onSwipe: () {}, // null 값을 전달하여 콜백 함수를 사용하지 않음
//                           onChanged: (bool state) {
//                             //Use it to manage the different states
//                             print('Current State of SWITCH IS: $state');
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 15),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Consumer(
//                           builder: (context, ref, child) {
//                             print('waitingData에 변동점이 생겼으므로 리빌드합니다.');
//                             ref.watch(waitingProvider);
//                             final int currentWaitingCount = ref.watch(
//                               waitingProvider.select(
//                                   (data) => data?.teamInfoList.length ?? 0),
//                             );
//                             return Padding(
//                               padding: EdgeInsets.only(left: 20),
//                               child: Row(
//                                 children: [
//                                   Text(
//                                     '현재 대기 팀수',
//                                     style: TextStyle(
//                                       fontFamily: 'Dovemayo_gothic',
//                                       fontSize: 32,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                   Text(
//                                     '  $currentWaitingCount',
//                                     style: TextStyle(
//                                       fontFamily: 'Dovemayo_gothic',
//                                       fontSize: 42,
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   Text(
//                                     ' 팀',
//                                     style: TextStyle(
//                                       fontFamily: 'Dovemayo_gothic',
//                                       fontSize: 32,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                       Padding(
//                         padding: EdgeInsets.only(right: 20),
//                         child: InkWell(
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => WaitingAddingScreen()),
//                             );
//                           },
//                           child: Image.asset(
//                               'assets/images/button/waiting adding.png'),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             // 여기서 ListView 를 사용하도록 수정합니다.
//             Expanded(
//               child: ListView.builder(
//                 itemCount: currentWaitingData!.teamInfoList.length,
//                 itemBuilder: (context, index) {
//                   WaitingTeam? team = currentWaitingData!.teamInfoList[index];
//                   Color textColor;
//                   String? guestStatus;
//                   switch (team.status) {
//                     case 1:
//                       textColor = Colors.blue;
//                       guestStatus = '대기중';
//                       break;
//                     case 2:
//                       textColor = Colors.green;
//                       guestStatus = '착석 완료';
//                       break;
//                     case 3:
//                       textColor = Colors.red;
//                       guestStatus = '삭제 완료';
//                       break;
//                     default:
//                       textColor = Colors.black; // 기본값, 필요에 따라 변경 가능
//                   }

//                   // 마감까지 남은 시간 계산
//                   Duration? timeRemaining;
//                   String? remainingTimeString;

//                   if (team.entryTime != null) {
//                     timeRemaining = team.entryTime!.difference(DateTime.now());
//                     remainingTimeString =
//                         '${timeRemaining.inHours.toString().padLeft(2, '0')}:${(timeRemaining.inMinutes % 60).toString().padLeft(2, '0')}';
//                   } else {
//                     remainingTimeString = 'Unknown';
//                   }

//                   return Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Expanded(
//                             child: IconButton(
//                               onPressed: () {
//                                 ref
//                                     .read(waitingProvider.notifier)
//                                     .sendNoShowMessage(
//                                         storeCode, team.waitingNumber);
//                               },
//                               icon:
//                                   Icon(Icons.delete, color: Color(0xFFDFDFDF)),
//                               iconSize: 30,
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             flex: 3, // 더 넓은 공간을 차지하도록 설정
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   children: [
//                                     Text(
//                                       '대기번호 ${team.waitingNumber}번',
//                                       style: TextStyle(
//                                         fontFamily: 'Dovemayo_gothic',
//                                         fontSize: 20,
//                                       ),
//                                     ),
//                                     SizedBox(width: 20),
//                                     Text(
//                                       '${team.personNumber}명',
//                                       style: TextStyle(
//                                         fontFamily: 'Dovemayo_gothic',
//                                         fontSize: 16,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 Text(
//                                   '상태 : $guestStatus',
//                                   style: TextStyle(
//                                     fontFamily: 'Dovemayo_gothic',
//                                     fontSize: 16,
//                                     color: textColor,
//                                   ),
//                                 ),
//                                 Text(
//                                   '${team.phoneNumber}',
//                                   style: TextStyle(
//                                     fontFamily: 'Dovemayo_gothic',
//                                     fontSize: 16,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           // 알람 버튼을 클릭하면, 해당 위치에 이미지와 타이머 뜨게 구현
//                           Expanded(
//                             child: IconButton(
//                               onPressed: () {
//                                 IconButton.setState(() {
//                                   buttonPressed = true;
//                                 });
//                                 ref
//                                     .read(waitingProvider.notifier)
//                                     .sendCallRequest(
//                                       context,
//                                       team.waitingNumber,
//                                       storeCode,
//                                       minutesToAdd,
//                                     );
//                               },
//                               icon: Icon(Icons.notifications,
//                                   color: Color(0xFF72AAD8)),
//                               iconSize: 30,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Padding(
//                         padding: EdgeInsets.all(10),
//                         child: Divider(
//                           color: Color(0xFFDFDFDF),
//                           thickness: 1,
//                         ),
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ),

//             Row(
//               mainAxisAlignment:
//                   MainAxisAlignment.spaceEvenly, // 가로로 공간을 균등하게 배치합니다.
//               children: [
//                 ElevatedButton(
//                   onPressed: () {
//                     ref.read(waitingProvider.notifier).sendCallRequest(
//                         context,
//                         currentWaitingData!.teamInfoList[0].waitingNumber,
//                         storeCode,
//                         minutesToAdd);
//                   },
//                   child: Text('손님 호출하기'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.of(context).push(MaterialPageRoute(
//                         builder: (BuildContext context) =>
//                             TableManagementScreen(loginResponse: loginData)));
//                   },
//                   child: Text('좌석 관리페이지 오픈하기'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _LoadingScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Store Page'),
//       ),
//       body: Center(
//         child: CircularProgressIndicator(),
//       ),
//     );
//   }
// }

// class _ErrorScreen extends StatelessWidget {
//   final dynamic error;

//   _ErrorScreen(this.error);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Store Page'),
//       ),
//       body: Center(
//         child: Text('Error: $error'),
//       ),
//     );
//   }
// }