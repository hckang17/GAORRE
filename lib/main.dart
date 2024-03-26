import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:orre_manager/references/reference2.dart';
import 'presenter/login.dart';
import 'presenter/login_screen.dart';
import 'store.dart';
import 'dart:async';
import 'dart:convert';

import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
// import 'stomp_websocket.dart'; // StompService 파일 import 추가

void main() {
  late StompClient stompClient;
  stompClient = StompClient(
    config: StompConfig(
      url: 'ws://192.168.0.13:8080/ws',
      onConnect: onConnect,
      beforeConnect: () async {
        print('waiting to connect...');
        await Future.delayed(const Duration(milliseconds: 200));
        print('connecting...');
      },
      onWebSocketError: (dynamic error) => print(error.toString()),
      // stompConnectHeaders: {'Authorization': 'Bearer yourToken'},
      // webSocketConnectHeaders: {'Authorization': 'Bearer yourToken'},
      ),
  );
  runApp(ProviderScope(child : MyApp()));
}

void onConnect(StompFrame frame) {
  print('stomp websocket connected. this message came from (main.dart)');
}


class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreenWidget(),
        '/store': (context) => StorePage(storeCode: 9999), // StorePage에 StompClient 전달
      },
    );
  }
}
