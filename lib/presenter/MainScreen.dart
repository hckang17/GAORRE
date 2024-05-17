import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/presenter/Screen/StoreManagerScreen.dart';
import 'package:orre_manager/presenter/Screen/WaitingScreen.dart';

final selectedIndexProvider = StateProvider<int>((ref) {
  return 0; // 기본적으로 '웨이팅 목록 화면'을 선택 상태로 시작합니다.
});

enum pageIndex {
  homeScreen,
  storeInfoScreen;
}

class MainScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);

    // 탭에 따라 표시될 페이지 리스트
    final pages = [
      WaitingScreenWidget(),    
      ManagementScreenWidget(),
    ];

    return WillPopScope(
      onWillPop: () async => false, // 이 부분을 추가함으로써 물리적 뒤로 가기 버튼이 동작하지 않게 됩니다.
      child: Scaffold(
        body: Center(
          child: pages[selectedIndex], // 선택된 인덱스에 따른 페이지 표시
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: '웨이팅 목록',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.store),
              label: '가게 정보 수정',
            ),
          ],
          selectedItemColor: Color.fromARGB(255, 33, 174, 255),
          unselectedItemColor: Color(0xFFDFDFDF),
          currentIndex: selectedIndex,
          onTap: (index) {
            ref.read(selectedIndexProvider.notifier).state = index;
          },
        ),
      ),
    );
  }
}
