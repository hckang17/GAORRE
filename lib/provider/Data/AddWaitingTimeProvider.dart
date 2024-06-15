import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaorre/services/HIVE_service.dart';
import 'dart:async';

final minutesToAddProvider =
    StateNotifierProvider<minutesToAddNotifier, int>((ref) {
  return minutesToAddNotifier(10); // 초기 상태를 10으로 설정합니다.
});

// StateNotifier를 확장하여 UserLogDataList 객체를 관리하는 클래스를 정의합니다.
class minutesToAddNotifier extends StateNotifier<int> {
  minutesToAddNotifier(initialState) : super(initialState) {
    _initialize();
  }

  Future<void> _initialize() async {
    String? rawData = await HiveService.retrieveData('minutesToAdd');
    if (rawData == null) {
      print('기존 데이터가 존재하지 않음으로.. 기본값 8분으로 설정합니다. [waitingAvailableStatus]');
      state = 10;
    } else {
      print('기존 데이터가 존재합니다! [waitingAvailableStatus]');
      int loadedState = int.parse(rawData); // 여기서 오류가 발생하지 않음
      state = loadedState;
    }
  }

  int getState() {
    return state;
  }

  void updateState(newState) {
    state = newState;
    saveData();
  }

  void saveData() async {
    // 변경사항 하이브에 저장하기.
    try {
      int currentState = state;
      await HiveService.saveIntData('minutesToAdd', currentState);
    } catch (error) {
      print('에러 : $error [minutesToAddProvider]');
    }
  }
}
