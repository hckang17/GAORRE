import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/Model/login_data_model.dart';
import 'package:orre_manager/Model/restaurant_table_model.dart';
import 'package:orre_manager/provider/DataProvider/stomp_client_future_provider.dart';
import 'package:orre_manager/provider/DataProvider/table_provider.dart';
import 'Widget/ShowTableInfo.dart' as my_widget;

class TableManagementScreen extends ConsumerWidget {
  final LoginData loginResponse;
  TableManagementScreen({required this.loginResponse});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stompClientAsyncValue = ref.watch(stompClientProvider);

    return stompClientAsyncValue.when(
      data: (stompClient) {
        return _TableManagementBody(loginData: loginResponse);
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

class _TableManagementBody extends ConsumerWidget {
  final LoginData loginData;
  // late int storeCode;
  RestaurantTable? restaurantTable;
  bool isSubscribed = false;  

  _TableManagementBody({required this.loginData});

  void subscribeProcess(WidgetRef ref, BuildContext context){
    if (restaurantTable == null && !isSubscribed) {
      // storeCode = loginData.storeCode;
      final restaurantTableNotifier = ref.read(tableProvider.notifier);
      restaurantTableNotifier.subscribeToLockTableData(loginData!.storeCode);
      restaurantTableNotifier.subscribeToUnlockTableData(loginData!.storeCode);
      restaurantTableNotifier.subscribeToTableData(loginData!.storeCode);
      restaurantTableNotifier.sendStoreCode(loginData!.storeCode);
      isSubscribed = true; // sendWaitingData가 한 번만 호출되도록 설정
    }
  }
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    restaurantTable = ref.watch(tableProvider);
    subscribeProcess(ref, context);

    if (restaurantTable == null) {
      return _LoadingScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('TableManagement Screen'),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _addNewTable(ref, context, loginData);
                      // '테이블 추가하기' 버튼 동작 정의
                    },
                    child: Text('테이블 추가하기'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _deleteTable(ref, context, loginData);
                      // '테이블 삭제하기' 버튼 동작 정의
                    },
                    child: Text('테이블 삭제하기'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20), // 버튼과 GridView 사이 간격 조절

            Consumer(builder: (context, ref, child) {
              List<Seat> currentSeats = ref.watch(tableProvider)!.table;
              
              return LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return SizedBox(
                    width: constraints.maxWidth * 0.8, // 전체 너비의 80%
                    height: constraints.maxWidth * 0.8, // 전체 너비의 80%
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 10.0,
                        crossAxisSpacing: 10.0,
                        childAspectRatio: 3 / 2, // 각 항목의 가로:세로 비율 설정
                      ),
                      itemCount: currentSeats.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () async {
                            // 메뉴리스트를 받아올 때 까지 기다림. 만약, 
                            await ref.read(tableProvider.notifier).requestTableOrderList(loginData!.storeCode, currentSeats[index].tableNumber);
                            // requestTableOrderList가 완료된 후에 _showTableInfoPopup 함수를 호출합니다.
                            my_widget.showTableInfoPopup(ref, context, currentSeats[index], loginData);
                          },
                          child: Container(
                            color: currentSeats[index].tableStatus == 0 ? Colors.red : Colors.green, // 사용 가능 여부에 따라 색상 변경
                            child: Center(
                              child: Text(
                                currentSeats[index].tableNumber.toString(),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
  
  void _addNewTable(WidgetRef ref, BuildContext context, LoginData loginData) {
    TextEditingController _tableNumberController = TextEditingController();
    TextEditingController _personNumberController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('새로운 테이블 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _tableNumberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: '추가할 테이블 번호'),
              ),
              TextField(
                controller: _personNumberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: '최대 착석가능 인원 수'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                int tableNumber = int.tryParse(_tableNumberController.text) ?? -1;
                int personNumber = int.tryParse(_personNumberController.text) ?? -1;
                ref.read(tableProvider.notifier).requestAddNewTable(
                  loginData.storeCode, tableNumber, personNumber, loginData.loginToken!);
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: Text('추가'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: Text('취소'),
            ),
          ],
        );
      },
    );
  }

  void _deleteTable(WidgetRef ref, BuildContext context, LoginData loginData) {
    TextEditingController _tableNumberController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('테이블 제거'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _tableNumberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: '제거할 테이블 번호'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                int tableNumber = int.tryParse(_tableNumberController.text) ?? -1;
                ref.read(tableProvider.notifier).requestDeleteTable(
                  loginData.storeCode, tableNumber, loginData.loginToken!);
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: Text('제거'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: Text('취소'),
            ),
          ],
        );
      },
    );
  }
}


class _LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TableManagement Screen'),
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
        title: Text('TableManagement Screen'),
      ),
      body: Center(
        child: Text('Error: $error'),
      ),
    );
  }
}