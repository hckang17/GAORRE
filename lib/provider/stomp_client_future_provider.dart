// stomp_client_provider.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/provider/admin_login_provider.dart';
import 'package:orre_manager/provider/waiting_provider.dart';
import 'package:orre_manager/provider/table_provider.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import '../services/websocket_services.dart';

final stompClientProvider = FutureProvider<StompClient>((ref) async {
  final completer = Completer<StompClient>();
  late StompClient client;

  client = StompClient(
    config: StompConfig(
      url: WebSocketService.url,
      onConnect: (StompFrame frame) {
        print("connected");
        // 필요한 초기화 수행, 여기서 client는 이미 정의되어 있으므로 사용 가능합니다.
       
        ref.read(loginProvider.notifier).setClient(client);
        ref.read(waitingProvider.notifier).setClient(client);
        ref.read(tableProvider.notifier).setClient(client);
        completer.complete(client);
      },
      beforeConnect: () async {
        print('Connecting to websocket...');
      },
      onWebSocketError: (dynamic error) {
        print(error.toString());
        completer.completeError(error);
      },
    ),
  );

  client.activate();
  return completer.future; // onConnect에서 complete가 호출될 때까지 대기합니다.
});