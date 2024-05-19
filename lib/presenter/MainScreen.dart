import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/presenter/Screen/StoreManagerScreen.dart';
import 'package:orre_manager/presenter/Screen/WaitingScreen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:orre_manager/provider/Network/connectivityStateNotifier.dart'; // 경고 아이콘 사용을 위해 추가

final selectedIndexProvider = StateProvider<int>((ref) {
  return 0; // 기본적으로 '웨이팅 목록 화면'을 선택 상태로 시작합니다.
});

class MainScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    final networkStatus = ref.watch(networkStateNotifierProvider);

    // 탭에 따라 표시될 페이지 리스트
    final pages = [
      WaitingScreenWidget(),
      ManagementScreenWidget(),
    ];

    return WillPopScope(
      onWillPop: () async => false, // 물리적 뒤로 가기 버튼 비활성화
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: pages[selectedIndex], // 선택된 인덱스에 따른 페이지 표시
              ),
            ),
            if (!networkStatus) // 네트워크 연결이 끊어졌을 때 경고 메시지 표시
              Container(
                width: double.infinity,
                color: Colors.red[600],
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: Row(
                  children: [
                    Icon(FontAwesomeIcons.exclamationTriangle, color: Colors.white),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "네트워크 연결이 끊어졌습니다. 네트워크 연결을 체크해주세요.",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
          ],
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
