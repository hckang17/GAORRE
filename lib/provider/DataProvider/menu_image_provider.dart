import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final imageBytesProvider = StateNotifierProvider<Uint8ListNotifier, Uint8List?>((ref) {
  return Uint8ListNotifier();
});

class Uint8ListNotifier extends StateNotifier<Uint8List?> {
  Uint8ListNotifier() : super(null);

  Uint8List getState() {
    return state!;
  }

  void resetState() {
    state = null;
  }
  
}