import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/Model/StoreDataModel.dart';
import 'package:orre_manager/presenter/Widget/AlertDialog.dart';
import 'package:orre_manager/presenter/Widget/ManagerPage/Menu/MenuList.dart';
import 'package:orre_manager/provider/Data/AddWaitingTimeProider.dart';
import 'package:orre_manager/provider/Data/loginDataProvider.dart';
import 'package:orre_manager/provider/Data/storeDataProvider.dart';
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
    if(ref.read(storeDataProvider.notifier).getStoreData() != null){
      currentStoreData = ref.read(storeDataProvider.notifier).getStoreData();
    }else{
      ref.read(storeDataProvider.notifier).requestStoreData(loginData!.storeCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    currentStoreData = ref.watch(storeDataProvider);
    minutesToAdd = ref.watch(minutesToAddProvider);

    return Scaffold(
      appBar: AppBar(title: Text('가게 정보 관리 화면')),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Center(
              child: currentStoreData!.storeImageMain.isNotEmpty
                ? SizedBox(
                    width: 200,
                    height: 200,
                    child: Image.network(currentStoreData!.storeImageMain, fit: BoxFit.cover),
                  )
                : SizedBox.shrink(),
            ),
          ),
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(currentStoreData!.storeName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                  buildTimeRow('영업시간', currentStoreData!.openingTime, currentStoreData!.closingTime, () {
                    // 영업시간 수정 로직
                  }),
                  buildTimeRow('라스트오더', currentStoreData!.lastOrderTime, '', () {
                    // 라스트오더 수정 로직
                  }),
                  buildTimeRow('브레이크타임', currentStoreData!.startBreakTime, currentStoreData!.endBreakTime, () {
                    // 브레이크타임 수정 로직
                  }),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => MenuListWidget(loginResponse: loginData!)
                      ));
                    },
                    child: Text('메뉴 관리하기'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(storeDataProvider.notifier).requestStoreData(loginData!.storeCode);
                    },
                    child: Text('새로고침'),
                  ),
                  ListTile(
                    title: Text('웨이팅 시간 설정'),
                    subtitle: Text('$minutesToAdd 분'),
                    onTap: () => _selectWaitingTime(context),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if(true == await showConfirmDialogWithConfirmText(context, "영업 종료", "영업 종료를 진행하면 모든 웨이팅을 취소합니다.")){
                        if(true == await ref.read(storeDataProvider.notifier).requestCloseStore(ref)){
                          showAlertDialog(context, "영업 종료", "성공적으로 영업종료를 처리 완료하였습니다.", null);
                        }else{
                          showAlertDialog(context, "영업 종료", "영업종료를 처리를 실패하였습니다.", null);
                        }
                      }
                    },
                    child: Text('영업종료하기'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTimeRow(String label, String time1, String time2, VoidCallback onPressed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('$label: $time1 ${time2.isNotEmpty ? '~ $time2' : ''}', style: TextStyle(fontSize: 18)),
        TextButton(
          onPressed: onPressed,
          child: Text('$label 수정하기'),
        ),
      ],
    );
  }

  void _selectWaitingTime(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: MediaQuery.of(context).copyWith().size.height / 3,
          child: CupertinoPicker(
            magnification: 1.0,
            children: List<Widget>.generate(13, (int index) {
              return Center(
                child: Text('${index * 5} 분'),
              );
            }),
            itemExtent: 30, // 각 항목의 높이
            onSelectedItemChanged: (int index) async {
              ref.read(minutesToAddProvider.notifier).updateState(index*5);
              await showAlertDialog(context, "호출시간 변경", "기본 호출시간을 ${index*5}분으로 설정하였습니다.", null);
            },
          ),
        );
      }
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('가게관리페이지'),
      ),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final dynamic error;

  _ErrorScreen(this.error);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Store Page'),
      ),
      body: Center(
        child: Text('Error: $error'),
      ),
    );
  }
}

