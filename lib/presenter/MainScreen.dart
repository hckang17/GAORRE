import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaorre/presenter/Screen/StoreManagerScreen.dart';
import 'package:gaorre/presenter/Screen/WaitingScreen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gaorre/presenter/Widget/alertDialog.dart';
import 'package:gaorre/provider/Network/connectivityStateNotifier.dart'; // 경고 아이콘 사용을 위해 추가

final selectedIndexProvider = StateProvider<int>((ref) {
  return 0; // 기본적으로 '웨이팅 목록 화면'을 선택 상태로 시작합니다.
});

class MainScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    // ignore: unused_local_variable
    final networkStatus = ref.watch(networkStateProvider);
    final connectStatus = ref.watch(connectNotifierProvider);

    // 탭에 따라 표시될 페이지 리스트
    final pages = [
      WaitingScreenWidget(),
      ManagementScreenWidget(),
    ];

    Future<bool> _onWillPop() async {
      bool confirm =
          await showConfirmDialog(ref.context, "앱 종료", "정말 앱을 종료하시겠습니까?");
      if (confirm) {
        if (Theme.of(ref.context).platform == TargetPlatform.android) {
          SystemNavigator.pop(); // Android에서 앱 종료
        } else if (Theme.of(ref.context).platform == TargetPlatform.iOS) {
          return false;
        }
      }
      return false;
    }

    return WillPopScope(
      onWillPop: _onWillPop, // 물리적 뒤로 가기 버튼 비활성화
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: pages[selectedIndex], // 선택된 인덱스에 따른 페이지 표시
              ),
            ),
            if (!connectStatus) // 네트워크 연결이 끊어졌을 때 경고 메시지 표시
              Container(
                width: double.infinity,
                color: Colors.red[600],
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: Row(
                  children: [
                    Icon(FontAwesomeIcons.exclamationTriangle,
                        color: Colors.white),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "네트워크를 확인해주세요.",
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
          selectedItemColor: Color(0xFF72AAD8),
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
