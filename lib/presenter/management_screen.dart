import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/Model/store_data_model.dart';
import 'package:orre_manager/presenter/Widget/menuList.dart';
import 'package:orre_manager/presenter/table_status_screen.dart';
import 'package:orre_manager/provider/DataProvider/stomp_client_future_provider.dart';
import 'package:orre_manager/provider/DataProvider/store_data_provider.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import '../Model/login_data_model.dart';
import '../Model/waiting_data_model.dart';
import '../provider/DataProvider/waiting_provider.dart';

class ManagementScreenWidget extends ConsumerWidget {
  final LoginData loginResponse;
  ManagementScreenWidget({required this.loginResponse});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stompClientAsyncValue = ref.watch(stompClientProvider);

    return stompClientAsyncValue.when(
      data: (stompClient) {
        return _ManagementScreenBody(loginData: loginResponse);
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

class _ManagementScreenBody extends ConsumerWidget {
  final LoginData loginData;
  bool isSubscribed = false;
  StoreData? currentStoreData;

  _ManagementScreenBody({required this.loginData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    currentStoreData = ref.watch(storeDataProvider);

    if (currentStoreData == null) {
      return Scaffold(
        appBar: AppBar(title: Text('가게 관리 화면')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('매장 코드 : ${loginData.storeCode}', style: TextStyle(fontSize: 20)),
              ElevatedButton(
                onPressed: () => ref.read(storeDataProvider.notifier).requestStoreData(loginData.storeCode),
                child: Text("가게 정보 수신하기"),
              ),
            ],
          ),
        ),
      );
    }

    // StoreData가 null이 아닐 때 화면
    return Scaffold(
      appBar: AppBar(
        title: Text('가게 정보 관리 화면'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Center(
              child: currentStoreData!.storeImageMain.isNotEmpty
                ? SizedBox(
                    width: 200,
                    height: 200,
                    child: Image.network(currentStoreData!.storeImageMain, fit: BoxFit.cover),
                  )
                : SizedBox.shrink(),
            ),
          ),
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(currentStoreData!.storeName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('영업시간: ${currentStoreData!.openingTime} ~ ${currentStoreData!.closingTime}', style: TextStyle(fontSize: 18)),
                      TextButton(
                        onPressed: () {
                          // 영업시간 수정 로직
                        },
                        child: Text('영업시간 수정하기'),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('라스트오더: ${currentStoreData!.lastOrderTime}', style: TextStyle(fontSize: 18)),
                      TextButton(
                        onPressed: () {
                          // 라스트오더 수정 로직
                        },
                        child: Text('라스트오더 수정하기'),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('브레이크타임: ${currentStoreData!.startBreakTime} ~ ${currentStoreData!.endBreakTime}', style: TextStyle(fontSize: 18)),
                      TextButton(
                        onPressed: () {
                          // 브레이크타임 수정 로직
                        },
                        child: Text('브레이크타임 수정하기'),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => MenuListWidget(
                          loginResponse: loginData, 
                          menuList: currentStoreData!.menuInfo, 
                          menuCategory: currentStoreData!.menuCategories,
                        )
                      ));
                    },
                    child: Text('메뉴 관리하기'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('가게관리페이지'),
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
        title: Text('Store Page'),
      ),
      body: Center(
        child: Text('Error: $error'),
      ),
    );
  }
}

