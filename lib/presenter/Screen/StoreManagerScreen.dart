// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, avoid_print, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaorre/Model/StoreDataModel.dart';
import 'package:gaorre/presenter/Screen/setting_screen.dart';
import 'package:gaorre/presenter/Widget/AlertDialog.dart';
import 'package:gaorre/presenter/Widget/ManagerPage/Menu/AddMenuPopup.dart';
import 'package:gaorre/presenter/Widget/ManagerPage/Menu/MenuList.dart';
import 'package:gaorre/presenter/Widget/ManagerPage/Menu/AddCategoryPopup.dart';
import 'package:gaorre/presenter/Widget/ManagerPage/StoreBasicInfoWidget.dart';
import 'package:gaorre/provider/Data/loginDataProvider.dart';
import 'package:gaorre/provider/Data/storeDataProvider.dart';
import 'package:gaorre/widget/popup/custom_popup_widget.dart';
import 'package:gaorre/widget/text/text_widget.dart';
import '../../Model/LoginDataModel.dart';

final textEditProvider =
    StateProvider<TextEditingController>((ref) => TextEditingController());

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
  Widget build(BuildContext context) {
    currentStoreData = ref.watch(storeDataProvider);
    final controller = ref.watch(textEditProvider);
    return Scaffold(
      body: Container(
          color: Colors.white,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Color(0xFF72AAD8), // 배경색 설정
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25), // 아래쪽 모서리 둥글게
                    bottomRight: Radius.circular(25),
                  ),
                ),
                // leading: IconButton(
                //   // 왼쪽 상단 뒤로가기 아이콘
                //   icon: Icon(Icons.arrow_back, color: Colors.white),
                //   onPressed: () {
                //     Navigator.pop(context);
                //   },
                // ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.event_busy, color: Colors.white),
                    onPressed: () async {
                      // if (true ==
                      //     await showConfirmDialogWithConfirmText(
                      //         context, "영업 종료", "영업 종료를 진행하면 모든 웨이팅을 취소합니다.")) {
                      //   if (true ==
                      //       await ref
                      //           .read(storeDataProvider.notifier)
                      //           .requestCloseStore(ref)) {
                      //     if (ref
                      //             .read(storeDataProvider.notifier)
                      //             .getWaitingAvailable() ==
                      //         0) {
                      //       print(
                      //           '현재 웨이팅 접수 상태가 "가능"임으로 "불가능"으로 변경합니다. [StoreManagerScreen - close] ');
                      //       await ref
                      //           .read(storeDataProvider.notifier)
                      //           .changeAvailableStatus(loginData ??
                      //               ref
                      //                   .read(loginProvider.notifier)
                      //                   .getLoginData()!);
                      //     }
                      //     showAlertDialog(context, "영업 종료",
                      //         "성공적으로 영업종료를 처리 완료하였습니다.", null);
                      //   } else {
                      //     showAlertDialog(
                      //         context, "영업 종료", "영업종료를 처리를 실패하였습니다.", null);
                      //   }
                      // } else {
                      //   showAlertDialog(
                      //       context, "영업 종료", "인증문자를 정확히 입력해주세요.", null);
                      // }
                      final String confirmText = "GAORRE";
                      showDialog(
                        context: context,
                        builder: (context) {
                          return CustomPopupDialog(
                            isCloseBtn: false,
                            title: "영업 종료",
                            content: Column(
                              children: [
                                TextWidget(
                                  "정말로 진행하시려면 검증문자 입력창에 \'$confirmText\'를 정확히 입력해주세요.",
                                  fontSize: 16.sp,
                                ),
                                SizedBox(height: 8.h),
                                TextField(
                                  controller: controller,
                                  decoration: InputDecoration(
                                    hintText: "검증문자를 입력하세요",
                                    hintStyle: TextStyle(
                                      fontSize: 16.sp,
                                      fontFamily: "Dovemayo_gothic",
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xFF72AAD8),
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xFF72AAD8),
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontFamily: "Dovemayo_gothic",
                                  ),
                                  cursorColor: Color(0xFF72AAD8),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            mainBtnText: "영업 종료",
                            mainBtnFunc: () async {
                              if (controller.text == confirmText) {
                                final isTrue = await ref
                                    .read(storeDataProvider.notifier)
                                    .requestCloseStore(ref);

                                final waitingAvailable = ref
                                    .watch(storeDataProvider.notifier)
                                    .getWaitingAvailable();

                                print("waitingAvailable: $waitingAvailable");
                                print("isTrue: $isTrue");
                                if (isTrue) {
                                  final userInfo = ref
                                      .read(loginProvider.notifier)
                                      .getLoginData();

                                  if (userInfo == null) {
                                    // TODO: 로그인 정보가 없을 때 처리
                                    return;
                                  } else {
                                    bool done = true;
                                    if (waitingAvailable == 0) {
                                      print(
                                          '현재 웨이팅 접수 상태가 "가능"임으로 "불가능"으로 변경합니다. [StoreManagerScreen - close] ');
                                      done = await ref
                                          .read(storeDataProvider.notifier)
                                          .changeAvailableStatus(userInfo);
                                    }
                                    await showAlertDialog(
                                        context,
                                        "영업 종료",
                                        done
                                            ? "성공적으로 영업종료를 처리 완료하였습니다."
                                            : "영업종료를 처리를 실패하였습니다.",
                                        null);

                                    print("test");
                                    Navigator.pop(context);
                                  }
                                }
                              } else {
                                showAlertDialog(context, "영업 종료",
                                    "인증문자를 정확히 입력해주세요.", null);
                              }
                            },
                            mainBtnColor: Colors.red,
                            subBtnText: "취소",
                            subBtnFunc: () {
                              Navigator.pop(context);
                            },
                          );
                        },
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.settings, color: Colors.white),
                    onPressed: () async {
                      // 세팅화면으로 전환
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => SettingScreen()));
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
                      color: Color(0xFF72AAD8), // 원모양 배경색
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: SizedBox(
                        width: 130,
                        height: 130,
                        child: Image.network(currentStoreData!.storeImageMain,
                            fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
                pinned: true, // 스크롤시 고정
                floating: true, // 스크롤 올릴 때 축소될지 여부
                snap: true, // 스크롤을 빨리 움직일 때 자동으로 확장/축소될지 여부
              ),
              StoreBasicInfoWidget(),
              MenuListWidget(),
              PopScope(
                child: SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
                onPopInvoked: (didPop) {
                  if (didPop) {}
                },
              ),
            ],
          )),
      floatingActionButton: Stack(
        children: <Widget>[
          Positioned(
            bottom: 80.0,
            right: 10.0,
            child: FloatingActionButton(
              heroTag: "addCategoryButton",
              onPressed: () {
                showAddCategoryDialog(
                    ref, null, null, currentStoreData!.menuCategories, []);
              },
              backgroundColor: Color(0xFFE6F4FE),
              foregroundColor: Color(0xFF72AAD8),
              child: Icon(Icons.edit),
              tooltip: '카테고리 추가하기',
            ),
          ),
          Positioned(
            bottom: 10.0,
            right: 10.0,
            child: FloatingActionButton(
              heroTag: "addMenuButton",
              onPressed: () {
                showAddMenuModal(context, currentStoreData!.menuCategories,
                    currentStoreData!.menuInfo);
              },
              backgroundColor: Color(0xFFE6F4FE),
              foregroundColor: Color(0xFF72AAD8),
              child: Icon(Icons.add),
              tooltip: '메뉴 추가하기',
            ),
          ),
        ],
      ),
    );
  }
}
