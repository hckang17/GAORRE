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

    return Scaffold(
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
        currentIndex: selectedIndex, // 현재 선택된 인덱스
        onTap: (index) {
          // 사용자가 탭을 선택할 때 상태 업데이트
          ref.read(selectedIndexProvider.notifier).state = index;
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     if (nfcAvailable) {
      //       startNFCScan(ref, context);
      //     } else {
      //       print(nfcAvailable);
      //     }
      //   },
      //   child: Icon(Icons.nfc),
      //   backgroundColor: (nfcAvailable
      //       ? Color.fromRGBO(255, 255, 255, 100)
      //       : Color.fromRGBO(0, 0, 0, 100)),
      // ),
    );
  }
}
