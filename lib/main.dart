import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:orre_manager/references/reference2.dart';
import 'presenter/login_screen.dart';
import 'presenter/store_screen.dart';


void main() {
  runApp(ProviderScope(child : MyApp()));
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreenWidget(),
        // '/store': (context) => StoreScreenWidget(), // StorePage에 StompClient 전달
      },
    );
  }
}
