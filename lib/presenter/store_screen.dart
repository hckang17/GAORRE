import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/presenter/store_screen.dart';
import 'package:orre_manager/provider/stomp_client_future_provider.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import '../Model/login_data_model.dart';
import '../Model/store_data_model.dart';
import '../provider/store_provider.dart';

class StoreScreenWidget extends ConsumerWidget {
  final LoginData? loginResponse;
  StoreScreenWidget({this.loginResponse});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stompClientAsyncValue = ref.watch(stompClientProvider);

    return stompClientAsyncValue.when(
      data: (stompClient) {
        return _StoreScreenBody(storeCode: loginResponse!.storeCode);
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
  final int storeCode;
  int minutesToAdd = 6;
  WaitingData? currentWaitingData;
  bool isSubscribed = false;

  _StoreScreenBody({required this.storeCode});

  void subscribeProcess(WidgetRef ref, BuildContext context){
    if (currentWaitingData == null && !isSubscribed) {
      final waitingNotifier = ref.read(waitingProvider.notifier);
      waitingNotifier.subscribeToWaitingData(storeCode);
      waitingNotifier.subscribeToCallGuest(context, storeCode);
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
                }, child: Text("웨이팅정보 수신하기"),
              )
            ],
          ),
        ),
      );
    }

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
                  print('rebuilded only this part');
                  final int currentWaitingCount = ref.watch(waitingProvider.select((data) => data?.teamInfoList?.length ?? 0));
                  return Text(
                    '현재 대기 팀수 : $currentWaitingCount',
                    style: TextStyle(fontSize: 24),
                  );
                },
            ),
            ElevatedButton(
              onPressed: () {
                _showReservationList(context, ref);
              },
              child: Text('대기팀 확인하기')
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(waitingProvider.notifier).sendCallRequest(
                  context, 
                  currentWaitingData!.teamInfoList[0].waitingTeam, 
                  storeCode, 
                  minutesToAdd
                );
              },
              child: Text('손님 호출하기'),
            ),
          ],
        ),
      ),
    );
  }
}



class _LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Screen'),
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
        title: Text('Login Screen'),
      ),
      body: Center(
        child: Text('Error: $error'),
      ),
    );
  }
}

void _showReservationList(BuildContext context, WidgetRef ref) {
  List<WaitingTeam?> teamList = ref.watch(waitingProvider.select((value) => value!.teamInfoList));
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Waiting Team List'),
        content: SingleChildScrollView(
          child: Column(
            children: teamList.map((team) {
              return ListTile(
                title: Text('Reservation Number: ${team?.waitingTeam}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name: ${team?.enteringTeam}'),
                    Text('Contact: ${team?.phoneNumber}'),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
        ],
      );
    },
  );
}

// class WaitingUserListWidget extends ConsumerWidget {
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final AsyncValue<WaitingData?> userList = ref.watch(waitingProvider);
//     return SingleChildScrollView(
//       child: userList.when(
//         data: (waitingData) {
//           if (waitingData == null || waitingData.teamInfoList.isEmpty) {
//             return Center(
//               child: Text('현재 웨이팅이 존재하지 않습니다.'),
//             );
//           } else {
//             return ListBody(
//               children: waitingData.teamInfoList.map((team) {
//                 return ListTile(
//                   title: Text('Reservation Number: ${team.waitingTeam}'),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('Name: ${team.enteringTeam}'),
//                       Text('Contact: ${team.phoneNumber}'),
//                     ],
//                   ),
//                 );
//               }).toList(),
//             );
//           }
//         },
//         loading: () => Center(
//           child: CircularProgressIndicator(),
//         ),
//         error: (error, stackTrace) => Center(
//           child: Text('Error: $error'),
//         ),
//       ),
//     );
//   }
// }

  // void _showReservationList(BuildContext context, WidgetRef ref) {
  //   final waitingData = ref.read(waitingProvider);
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Reservation List'),
  //         content: SingleChildScrollView(
  //           child: context.waitingData!.when(
  //             data: (data) {
  //               return ListBody(
  //                 children: List.generate(data.teamInfoList.length, (index) {
  //                   return ListTile(
  //                     title: Text('Reservation Number: ${data.teamInfoList[index].waitingTeam}'),
  //                     subtitle: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Text('Name: ${data.teamInfoList[index].enteringTeam}'),
  //                         Text('Contact: ${data.teamInfoList[index].phoneNumber}'),
  //                       ],
  //                     ),
  //                   );
  //                 }),
  //               );
  //             },
  //             loading: () => CircularProgressIndicator(),
  //             error: (error, stackTrace) => Text('Error: $error'),
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: Text('Close'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
