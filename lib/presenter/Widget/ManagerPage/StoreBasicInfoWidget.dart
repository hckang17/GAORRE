import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/Model/StoreDataModel.dart';
import 'package:orre_manager/presenter/Widget/AlertDialog.dart';
import 'package:orre_manager/provider/Data/AddWaitingTimeProider.dart';
import 'package:orre_manager/provider/Data/storeDataProvider.dart';
import 'package:orre_manager/widget/text/text_widget.dart';

  // StoreData({
  //   required this.storeCode,
  //   required this.storeName,
  //   required this.waitingAvailable,
  //   this.storeInfoVersion = 0,
  //   this.storeIntroduce = "우리 가게",
  //   required this.storeCategory,
  //   this.storeImageMain = "",
  //   this.openingTime = "09:00:00",
  //   this.closingTime = "23:00:00",
  //   this.lastOrderTime = "21:00:00",
  //   this.startBreakTime = "15:00:00",
  //   this.endBreakTime = "16:00:00",
  //   required this.menuCategories,
  //   this.menuInfo,
  // });


class StoreBasicInfoWidget extends ConsumerWidget {

  StoreBasicInfoWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStoreData = ref.watch(storeDataProvider);
    final minutesToAdd = ref.watch(minutesToAddProvider);
    return SliverToBoxAdapter(
      child: buildStoreStatus(ref, currentStoreData!, minutesToAdd),
    );
  }

  Widget buildStoreStatus(WidgetRef ref, StoreData currentStoreData, int minutesToAdd) {
    List<Widget> children = [
      SizedBox(
        height: 10,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(flex: 1, child: Icon(Icons.schedule)),
          Expanded(
              flex: 2,
              child: TextWidget(
                '영업시간',
                textAlign: TextAlign.start,
              )),
          Expanded(
            flex: 4,
            child: TextWidget(
              ': ${currentStoreData.openingTime} ~ ${currentStoreData.closingTime}',
              textAlign: TextAlign.start,
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                // 영업시간 수정로직 적용하기
                showAlertDialog(ref.context, "영업시간 수정", "준비중입니다. 오픈베타를 기대해주세요!", null);
              }
            )
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(flex: 1, child: Icon(Icons.watch_later)),
          Expanded(
              flex: 2,
              child: TextWidget(
                '휴식시간',
                textAlign: TextAlign.start,
              )),
          Expanded(
            flex: 4,
            child: TextWidget(
              ': ${currentStoreData.startBreakTime} ~ ${currentStoreData.endBreakTime}',
              textAlign: TextAlign.start,
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                // 브레이크타임 수정 기능 추가하기!
                showAlertDialog(ref.context, "브레이크타임 수정", "준비중입니다. 오픈베타를 기대해주세요!", null);
              }
            )
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(flex: 1, child: Icon(Icons.event_busy)),
          Expanded(
              flex: 2,
              child: TextWidget(
                '라스트오더',
                textAlign: TextAlign.start,
              )),
          Expanded(
            flex: 4,
            child: TextWidget(
              ': ${currentStoreData.lastOrderTime} 마감',
              textAlign: TextAlign.start,
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                // 라스트오더 타임 수정 추가하기!
                showAlertDialog(ref.context, "라스트오더 수정", "준비중입니다. 오픈베타를 기대해주세요!", null);
              }
            )
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(flex: 1, child: Icon(Icons.notifications_active)),
          Expanded(
              flex: 2,
              child: TextWidget(
                '호출마감',
                textAlign: TextAlign.start,
              )),
          Expanded(
            flex: 4,
            child: TextWidget(
              ': ${minutesToAdd}분',
              textAlign: TextAlign.start,
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                _selectWaitingTime(ref);
              }
            )
          ),
        ],
      ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  void _selectWaitingTime(WidgetRef ref) {
    int selectedMinutes = 0;  // 초기 선택값
    showModalBottomSheet(
      context: ref.context,
      builder: (BuildContext builder) {
        return Container(
          height: MediaQuery.of(ref.context).copyWith().size.height / 3,
          child: Column(
            children: <Widget>[
              Expanded(
                child: CupertinoPicker(
                  magnification: 1.0,
                  children: List<Widget>.generate(13, (int index) {
                    return Center(child: Text('${index * 5} 분'));
                  }),
                  itemExtent: 30, // 각 항목의 높이
                  onSelectedItemChanged: (int index) {
                    selectedMinutes = index * 5;
                  },
                ),
              ),
              TextButton(
                child: Text('확인하기'),
                onPressed: () async {
                  ref.read(minutesToAddProvider.notifier).updateState(selectedMinutes);
                  await showAlertDialog(ref.context, "호출시간 변경", "기본 호출시간을 $selectedMinutes 분으로 설정하였습니다.", null);
                  Navigator.pop(ref.context);  // Picker 닫기
                },
              )
            ],
          ),
        );
      }
    );
  }
}


