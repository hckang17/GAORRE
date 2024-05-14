import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/Model/login_data_model.dart';
import 'package:orre_manager/Model/restaurant_table_model.dart';
import 'package:orre_manager/provider/Data/loginDataProvider.dart';
import 'package:orre_manager/Coding_references/stompClientFutureProvider.dart';
import 'package:orre_manager/provider/Data/tableDataProvider.dart';
import '../Widget/TablePage/ShowTableInfo.dart' as my_widget;

class TableManagementScreen extends ConsumerWidget {

  TableManagementScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final stompClientAsyncValue = ref.watch(stompClientProvider);

    // return stompClientAsyncValue.when(
    //   data: (stompClient) {
    //     return TableManagementBody(loginData: loginResponse);
    //   },
    //   loading: () {
    //     // 로딩 중이면 로딩 스피너를 표시합니다.
    //     return _LoadingScreen();
    //   },
    //   error: (error, stackTrace) {
    //     // 에러가 발생하면 에러 메시지를 표시합니다.
    //     return _ErrorScreen(error);
    //   },
    // );
    ref.watch(tableProvider);
    return TableManagementBody();
  }
}
  
class TableManagementBody extends ConsumerStatefulWidget {
  TableManagementBody();

  @override
  _TableManagementBodyState createState() => _TableManagementBodyState();
}

class _TableManagementBodyState extends ConsumerState<TableManagementBody> with AutomaticKeepAliveClientMixin {
  RestaurantTable? restaurantTable;
  late LoginData? loginData;
  bool isSubscribed = false;

  @override
  bool get wantKeepAlive => true; // 위젯이 pop 되어도 상태 유지

  @override
  void initState() {
    super.initState();
    loginData = ref.read(loginProvider.notifier).getLoginData();
    subscribeProcess();
  }

  void subscribeProcess() {
    if (restaurantTable == null && !isSubscribed) {
      final restaurantTableNotifier = ref.read(tableProvider.notifier);
      restaurantTableNotifier.subscribeToLockTableData(loginData!.storeCode);
      restaurantTableNotifier.subscribeToUnlockTableData(loginData!.storeCode);
      restaurantTableNotifier.subscribeToTableData(loginData!.storeCode);
      restaurantTableNotifier.sendStoreCode(loginData!.storeCode);
      isSubscribed = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    restaurantTable = ref.watch(tableProvider);
    
    if (restaurantTable == null) {
      return _LoadingScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Table Management Screen'),
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
                    onPressed: () => _addNewTable(ref, context, loginData!),
                    child: Text('테이블 추가하기'),
                  ),
                  ElevatedButton(
                    onPressed: () => _deleteTable(ref, context, loginData!),
                    child: Text('테이블 삭제하기'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Consumer(builder: (context, ref, child) {
              List<Seat> currentSeats = ref.watch(tableProvider)!.table;
              
              return LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return SizedBox(
                    width: constraints.maxWidth * 0.8,
                    height: constraints.maxWidth * 0.8,
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 10.0,
                        crossAxisSpacing: 10.0,
                        childAspectRatio: 3 / 2,
                      ),
                      itemCount: currentSeats.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () async {
                            await ref.read(tableProvider.notifier).requestTableOrderList(loginData!.storeCode, currentSeats[index].tableNumber);
                            my_widget.showTableInfoPopup(ref, context, currentSeats[index], loginData!);
                          },
                          child: Container(
                            color: currentSeats[index].tableStatus == 0 ? Colors.red : Colors.green,
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
                  loginData.storeCode, tableNumber, personNumber, ref.read(loginProvider.notifier).getLoginData().loginToken!);
                Navigator.of(context).pop();
              },
              child: Text('추가'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
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
                  loginData.storeCode, tableNumber, ref.read(loginProvider.notifier).getLoginData().loginToken!);
                Navigator.of(context).pop();
              },
              child: Text('제거'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context). pop();
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