import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/Model/login_data_model.dart';
import 'package:orre_manager/Model/restaurant_table_model.dart';
import 'package:orre_manager/provider/stomp_client_future_provider.dart';
import 'package:orre_manager/provider/table_provider.dart';

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
  late int storeCode;
  RestaurantTable? restaurantTable;
  bool isSubscribed = false;  

  _TableManagementBody({required this.loginData});

  void subscribeProcess(WidgetRef ref, BuildContext context){
    if (restaurantTable == null && !isSubscribed) {
      storeCode = loginData.storeCode;
      final restaurantTableNotifier = ref.read(tableProvider.notifier);
      restaurantTableNotifier.subscribeToTableData(storeCode);
      restaurantTableNotifier.sendStoreCode(storeCode);
      isSubscribed = true; // sendWaitingData가 한 번만 호출되도록 설정
    }
  }
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    subscribeProcess(ref, context);

    restaurantTable = ref.watch(tableProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Table Management Page'),
      ),
      body: Center(
        child: Text('${restaurantTable.toString()}')
      )
    );
    // throw UnimplementedError();
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