import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/Model/StoreDataModel.dart';
import 'package:orre_manager/presenter/Screen/StartScreen.dart';
import 'package:orre_manager/presenter/Widget/AlertDialog.dart';
import 'package:orre_manager/presenter/Widget/ManagerPage/Menu/AddMenuPopup.dart';
import 'package:orre_manager/presenter/Widget/ManagerPage/Menu/EditCategoryPopup.dart';
import 'package:orre_manager/presenter/Widget/ManagerPage/Menu/MenuList.dart';
import 'package:orre_manager/presenter/Widget/ManagerPage/StoreBasicInfoWidget.dart';
import 'package:orre_manager/provider/Data/AddWaitingTimeProider.dart';
import 'package:orre_manager/provider/Data/loginDataProvider.dart';
import 'package:orre_manager/provider/Data/storeDataProvider.dart';
import 'package:orre_manager/widget/custom_scroll_view/csv_divider_widget.dart';
import 'package:orre_manager/widget/text/text_widget.dart';
import '../../Model/LoginDataModel.dart';

class ManagementScreenWidget extends ConsumerWidget {

  ManagementScreenWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    ref.watch(storeDataProvider);
    return ManagementScreenBody();
  }
}

class ManagementScreenBody extends ConsumerStatefulWidget {

  ManagementScreenBody();

  @override
  _ManagementScreenBodyState createState() => _ManagementScreenBodyState();
}

class _ManagementScreenBodyState extends ConsumerState<ManagementScreenBody> {
  late LoginData? loginData;
  StoreData? currentStoreData;
  bool isSubscribed = false;
  late int minutesToAdd;

  @override
  void initState() {
    super.initState();
    // 데이터 요청 로직을 initState로 이동하여 최초 1회만 실행
    loginData = ref.read(loginProvider.notifier).getLoginData();
    ref.read(storeDataProvider.notifier).requestStoreData(loginData!.storeCode);
  }

  @override
  Widget build(BuildContext context){
    currentStoreData = ref.watch(storeDataProvider);
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: CustomScrollView(
          slivers: [  // sliver 리스트로 감싸줘야 정상적으로 작동함.
            SliverAppBar( // -> 이곳에 앱바 ( 로그아웃 버튼, 영업종료 버튼은 여기에다 배치! )
              backgroundColor: Color.fromARGB(255, 77, 196, 255), // 배경색 설정
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25), // 아래쪽 모서리 둥글게
                  bottomRight: Radius.circular(25),
                ),
              ),
              leading: IconButton(
                // 왼쪽 상단 뒤로가기 아이콘
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              actions: [
                IconButton(
                  // 오른쪽 상단 로그아웃 아이콘
                  icon: Icon(Icons.logout, color: Colors.white),
                  onPressed: () async {
                    // 로그아웃 기능 사용.
                    if(await showConfirmDialog(context, "로그아웃", "정말 로그아웃 하시겠습니까?")){
                      ref.read(loginProvider.notifier).logout();
                      // 모든 subscribe와 websocket을 해제하는게 맞겠지?
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => StartScreen()),
                        (_) => false,  // 조건이 항상 거짓이므로 모든 이전 화면을 제거
                      );
                    }else{
                      return;
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.event_busy, color: Colors.white),
                  onPressed: () async {
                      if(true == await showConfirmDialogWithConfirmText(context, "영업 종료", "영업 종료를 진행하면 모든 웨이팅을 취소합니다.")){
                        if(true == await ref.read(storeDataProvider.notifier).requestCloseStore(ref)){
                          showAlertDialog(context, "영업 종료", "성공적으로 영업종료를 처리 완료하였습니다.", null);
                        }else{
                          showAlertDialog(context, "영업 종료", "영업종료를 처리를 실패하였습니다.", null);
                        }
                      }
                    },
                ),
              ],
              expandedHeight: 240, // 높이 설정
              flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  titlePadding: const EdgeInsets.only(bottom: 12),
                  title: TextWidget(
                    currentStoreData!.storeName,
                    color: Colors.white,
                    fontSize: 24,
                    textAlign: TextAlign.center,
                  ),
                background: Container(
                  width: 130,
                  height: 130,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromARGB(255, 77, 196, 255), // 원모양 배경색
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: SizedBox(
                      width: 130,
                      height: 130,
                      child: Image.network(currentStoreData!.storeImageMain, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
              pinned: true, // 스크롤시 고정
              floating: true, // 스크롤 올릴 때 축소될지 여부
              snap: true, // 스크롤을 빨리 움직일 때 자동으로 확장/축소될지 여부
            ),
            StoreBasicInfoWidget(), // -> 이곳에 가게 상태 (오프닝시간, 클로징시간, 브레이크타임, 호출시간 설정 )
            CSVDividerWidget(), // -> 디바이더
            MenuListWidget(),
            // PopScope() 이 안에 SliverToBoxAdaper( child : ~ , onPopInvoked : (did))
            PopScope(
              child: SliverToBoxAdapter(
                child: SizedBox(
                  height: 80
                ),
              ),
              onPopInvoked: (didPop) {
                if (didPop) {
                  // 별도의 로직은 필요해 보이지 않음.
                }
              },
            ),
          ],
        )
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          Positioned(
            bottom: 80.0,
            right: 10.0,
            child: FloatingActionButton(
              onPressed: () {
                // 카테고리 수정 관련 모달
                showEditCategoryModal(ref, null, null, currentStoreData!.menuCategories, []);
              },
              child: Icon(Icons.edit),
              tooltip: '카테고리 추가하기',
            ),
          ),
          Positioned(
            bottom: 10.0,
            right: 10.0,
            child: FloatingActionButton(
              onPressed: () {
                showAddMenuModal(context, currentStoreData!.menuCategories, currentStoreData!.menuInfo);
              },
              child: Icon(Icons.add),
              tooltip: '메뉴 추가하기',
            ),
          ),
        ],
      ),
    );
  }
}



  // @override
  // Widget build(BuildContext context) {
  //   currentStoreData = ref.watch(storeDataProvider);
  //   minutesToAdd = ref.watch(minutesToAddProvider);

  //   return Scaffold(
  //     appBar: AppBar(title: Text('가게 정보 관리 화면')),
  //     body: Column(
  //       children: [
  //         Expanded(
  //           flex: 1,
  //           child: Center(
  //             child: currentStoreData!.storeImageMain.isNotEmpty
  //               ? SizedBox(
  //                   width: 200,
  //                   height: 200,
  //                   child: Image.network(currentStoreData!.storeImageMain, fit: BoxFit.cover),
  //                 )
  //               : SizedBox.shrink(),
  //           ),
  //         ),
  //         Expanded(
  //           flex: 2,
  //           child: SingleChildScrollView(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               children: [
  //                 Padding(
  //                   padding: const EdgeInsets.all(8.0),
  //                   child: Text(currentStoreData!.storeName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
  //                 ),
  //                 buildTimeRow('영업시간', currentStoreData!.openingTime, currentStoreData!.closingTime, () {
  //                   // 영업시간 수정 로직
  //                 }),
  //                 buildTimeRow('라스트오더', currentStoreData!.lastOrderTime, '', () {
  //                   // 라스트오더 수정 로직
  //                 }),
  //                 buildTimeRow('브레이크타임', currentStoreData!.startBreakTime, currentStoreData!.endBreakTime, () {
  //                   // 브레이크타임 수정 로직
  //                 }),
  //                 ElevatedButton(
  //                   onPressed: () {
  //                     Navigator.of(context).push(MaterialPageRoute(
  //                       builder: (BuildContext context) => MenuListWidget(loginResponse: loginData!)
  //                     ));
  //                   },
  //                   child: Text('메뉴 관리하기'),
  //                 ),
  //                 ElevatedButton(
  //                   onPressed: () {
  //                     ref.read(storeDataProvider.notifier).requestStoreData(loginData!.storeCode);
  //                   },
  //                   child: Text('새로고침'),
  //                 ),
  //                 ListTile(
  //                   title: Text('웨이팅 시간 설정'),
  //                   subtitle: Text('$minutesToAdd 분'),
  //                   onTap: () => _selectWaitingTime(context),
  //                 ),
  //                 ElevatedButton(
                    // onPressed: () async {
                    //   if(true == await showConfirmDialogWithConfirmText(context, "영업 종료", "영업 종료를 진행하면 모든 웨이팅을 취소합니다.")){
                    //     if(true == await ref.read(storeDataProvider.notifier).requestCloseStore(ref)){
                    //       showAlertDialog(context, "영업 종료", "성공적으로 영업종료를 처리 완료하였습니다.", null);
                    //     }else{
                    //       showAlertDialog(context, "영업 종료", "영업종료를 처리를 실패하였습니다.", null);
                    //     }
                    //   }
                    // },
  //                   child: Text('영업종료하기'),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget buildTimeRow(String label, String time1, String time2, VoidCallback onPressed) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       Text('$label: $time1 ${time2.isNotEmpty ? '~ $time2' : ''}', style: TextStyle(fontSize: 18)),
  //       TextButton(
  //         onPressed: onPressed,
  //         child: Text('$label 수정하기'),
  //       ),
  //     ],
  //   );
  // }

// void _selectWaitingTime(BuildContext context) {
//   int selectedMinutes = 0;  // 초기 선택값

//   showModalBottomSheet(
//     context: context,
//     builder: (BuildContext builder) {
//       return Container(
//         height: MediaQuery.of(context).copyWith().size.height / 3,
//         child: Column(
//           children: <Widget>[
//             Expanded(
//               child: CupertinoPicker(
//                 magnification: 1.0,
//                 children: List<Widget>.generate(13, (int index) {
//                   return Center(child: Text('${index * 5} 분'));
//                 }),
//                 itemExtent: 30, // 각 항목의 높이
//                 onSelectedItemChanged: (int index) {
//                   selectedMinutes = index * 5;
//                 },
//               ),
//             ),
//             TextButton(
//               child: Text('확인하기'),
//               onPressed: () async {
//                 ref.read(minutesToAddProvider.notifier).updateState(selectedMinutes);
//                 Navigator.pop(context);  // Picker 닫기
//                 await showAlertDialog(context, "호출시간 변경", "기본 호출시간을 $selectedMinutes 분으로 설정하였습니다.", null);
//               },
//             )
//           ],
//         ),
//       );
//     }
//   );
// }
