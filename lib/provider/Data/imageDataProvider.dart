import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final imageBytesProvider = StateNotifierProvider<Uint8ListNotifier, Uint8List?>((ref) {
  Uint8ListNotifier notifier = Uint8ListNotifier();
  notifier.loadInitialImage(); // 비동기 초기 이미지 로드 호출
  return notifier;
});

class Uint8ListNotifier extends StateNotifier<Uint8List?> {
  Uint8ListNotifier() : super(null);

  Future<void> loadInitialImage() async {
    ByteData bytes = await rootBundle.load('assets/image/Duck_with_bell.png');
    state = bytes.buffer.asUint8List();
  }

  Uint8List? getState() {
    return state;
  }

  void resetState() {
    loadInitialImage();
  }

  void setState(Uint8List? newState) {
    state = newState;
  }
}
