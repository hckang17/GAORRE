import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connectivity_checker/internet_connectivity_checker.dart';


final networkStateProvider =
    StateNotifierProvider<NetworkStateNotifier, bool>((ref) {
  return NetworkStateNotifier();
});

class NetworkStateNotifier extends StateNotifier<bool> {
  final Connectivity _connectivity = Connectivity();

  NetworkStateNotifier() : super(false) {
    // 객체 생성 시 네트워크 상태를 체크
    _initNetworkState();
    _connectivity.onConnectivityChanged.listen((result) {
      // 네트워크가 연결된 상태인지 확인
      bool isConnected = (result != ConnectivityResult.none);
      if (state != isConnected) {
        print('네트워크 상태 변경... 현재 : $isConnected');
        state = isConnected;
      }
    });
  }

  Future<void> _initNetworkState() async {
    // 현재 네트워크 상태를 체크
    var currentResult = await _connectivity.checkConnectivity();
    bool isConnected = (currentResult != ConnectivityResult.none);
    // StateNotifier의 상태를 현재 네트워크 상태로 설정
    state = isConnected;
    print('초기 네트워크 상태 : $isConnected');
  }
}
//--

// final networkStateProvider = Provider<Stream<bool>>((ref) {
//   return ConnectivityChecker(interval: const Duration(seconds: 5)).stream;
// });

// final networkStateNotifierProvider =
//     StateNotifierProvider<NetworkStateNotifier, bool>((ref) {
//   return NetworkStateNotifier(ref);
// });

// class NetworkStateNotifier extends StateNotifier<bool> {
//   late final Ref ref;

//   NetworkStateNotifier(this.ref) : super(false) {
//     _checkNetworkStatus();
//   }

//   void _checkNetworkStatus() {
//     ref.watch(networkStateProvider).listen((isConnected) {
//       if (state != isConnected) {
//         state = isConnected;
//       }
//     });
//   }
// }

//--

// final networkStreamProvider = StreamProvider<bool>((ref) {
//   return ConnectivityChecker(interval: const Duration(seconds: 5)).stream;
// });

// final networkStateNotifier = StateNotifierProvider<NetworkStateNotifier, bool>(
//     (ref) => NetworkStateNotifier());

// class NetworkStateNotifier extends StateNotifier<bool> {
//   NetworkStateNotifier() : super(false) {
//     updateNetworkState();
//   }

//   void updateNetworkState() async {
//     ConnectivityChecker(interval: const Duration(seconds: 5))
//         .stream
//         .listen((event) {
//       print("NetworkStateNotifier: $event");
//       state = event;
//     });
//   }
// }
