import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
 
// 채팅 목록을 저장할 리스트
List<Msg> messages = [];
int chatRoomId = 1;

class StompScreen extends StatefulWidget {
  const StompScreen({super.key});

  @override
  State<StompScreen> createState() => _StompScreenState();
}

class _StompScreenState extends State<StompScreen> {
  late StompClient stompClient;
  ScrollController scrollController = ScrollController();
  void onConnect(StompClient stompClient, StompFrame frame) {
    stompClient.subscribe(
      destination: '/topic/1',
      callback: (frame) {
        //List<dynamic>? result = json.decode(frame.body!);
        Map<String, dynamic> obj = json.decode(frame.body!);
        Msg message = Msg(
            detailMessage: obj['detailMessage'],
            roomId: obj['roomId'],
            senderId: obj['senderId'],
            senderName: obj['senderName'],
            type: obj['type']);
        setState(() => {
              messages.add(message),
           
        });

        
      },
    );

 
  }
 
  @override
  void initState() {
    super.initState();

   
    stompClient = StompClient(
      config: StompConfig(
          url: 'ws://localhost:8080/ws/chat',
          onConnect: (frame) => onConnect(stompClient, frame),
          beforeConnect: () async {
            print('waiting to connect...');
            await Future.delayed(const Duration(milliseconds: 200));
            print('connecting...');
          },
          onWebSocketError: (dynamic error) => print(error.toString())
          //stompConnectHeaders: {'Authorization': 'Bearer yourToken'},
          //webSocketConnectHeaders: {'Authorization': 'Bearer yourToken'},
          ),
    );
    stompClient.activate();
  }

  @override
  void dispose() {
    super.dispose();
    // 웹소켓에서 연결 해제
    stompClient.deactivate();
    // 텍스트 입력 컨트롤러 해제
    textController.dispose();
  }

  // 텍스트 입력 컨트롤러
  TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('widget.title'),
      ),
      body: Column(
        children: [
          // 채팅 목록을 표시하는 ListView
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(messages[index].detailMessage),
                );
              },
            ),
          ),
          // 텍스트 입력 필드와 전송 버튼을 가진 Row
          Row(
            children: [
              // 텍스트 입력 필드
              Expanded(
                child: TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your message',
                  ),
                ),
              ),
              // 전송 버튼
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  // 텍스트 입력 필드의 내용을 가져옴
                  String message = textController.text;
                  if (message.isNotEmpty) {
                    // destination에 메시지 전송
                    stompClient.send(
                      destination: '/app/message', // 전송할 destination
                      body: json.encode({
                        "type": "TALK",
                        "roomId": 1,
                        "senderId": 1,
                        "detailMessage": message,
                        "senderName": "Kim"
                      }), // 메시지의 내용
                    );
                    // 텍스트 입력 필드를 비움
                    textController.clear();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Msg {
  String type;
  int roomId;
  int senderId;
  String detailMessage;
  String senderName;

  Msg(
      {required this.type,
      required this.roomId,
      required this.senderId,
      required this.detailMessage,
      required this.senderName});
}