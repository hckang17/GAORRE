import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/presenter/table_status_screen.dart';
import 'package:orre_manager/provider/stomp_client_future_provider.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import '../Model/login_data_model.dart';
import '../Model/waiting_data_model.dart';
import '../provider/waiting_provider.dart';

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
  
  _ManagementScreenBody({required this.loginData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Store Management'),
      ),
      body: Center(
        child: Text('가게 정보 수정 화면'),
      )
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Store Page'),
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

