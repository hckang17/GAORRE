import 'package:flutter_riverpod/flutter_riverpod.dart';

class CallButtonNotifier extends StateNotifier<bool> {
  CallButtonNotifier() : super(false);

  void pressButton() {
    state = true;
  }

  void resetButton() {
    state = false;
  }
}

final callButtonProvider = StateNotifierProvider.family<CallButtonNotifier, bool, int>((ref, id) => CallButtonNotifier());