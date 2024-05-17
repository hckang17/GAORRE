import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connectivity_checker/internet_connectivity_checker.dart';


final networkStateProvider = Provider<Stream<bool>>((ref) {
  return ConnectivityChecker(interval: const Duration(seconds: 5)).stream;
});

final networkStateNotifierProvider =
    StateNotifierProvider<NetworkStateNotifier, bool>((ref) {
  return NetworkStateNotifier(ref);
});

class NetworkStateNotifier extends StateNotifier<bool> {
  late final Ref ref;

  NetworkStateNotifier(this.ref) : super(false) {
    _checkNetworkStatus();
  }

  void _checkNetworkStatus() {
    ref.watch(networkStateProvider).listen((isConnected) {
      if (state != isConnected) {
        state = isConnected;
      }
    });
  }
}

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
