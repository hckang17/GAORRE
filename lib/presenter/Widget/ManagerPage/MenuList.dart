import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/Model/login_data_model.dart';
import 'package:orre_manager/Model/menu_data_model.dart';
import 'package:orre_manager/presenter/Widget/ManagerPage/AddMenuPopup.dart';
import 'package:orre_manager/presenter/Widget/ManagerPage/EditCategoryPopup.dart';
import 'package:orre_manager/provider/DataProvider/store_data_provider.dart';
import 'package:orre_manager/presenter/Widget/ManagerPage/ModifyMenuPopup.dart';

class MenuListWidget extends ConsumerWidget {
  final LoginData loginResponse;

  MenuListWidget({required this.loginResponse});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeData = ref.watch(storeDataProvider); // StoreData의 변화를 감시

    if (storeData?.menuInfo == null || storeData?.menuCategories == null) {
      return Center(child: Text("메뉴 정보를 불러올 수 없습니다."));
    }

    Map<String, List<Menu>> categorizedMenus = {};
    // 먼저 모든 카테고리에 대해 빈 리스트를 생성합니다.
    storeData!.menuCategories!.forEach((key, value) {
      if (value != null) { // value가 null이 아닌 경우에만 빈 리스트를 추가
        categorizedMenus[key] = [];
      }
    });
    
    // 실제 메뉴 데이터를 categorizedMenus에 추가합니다.
    for (var menu in storeData!.menuInfo!) {
      String categoryKey = menu.menuCode[0].toLowerCase();  // 메뉴 코드의 첫 글자를 소문자로 변환
      if (categorizedMenus.containsKey(categoryKey)) {
        categorizedMenus[categoryKey]!.add(menu);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('메뉴 리스트'),
      ),
      body: ListView.builder(
        itemCount: storeData.menuCategories.length,
        itemBuilder: (context, index) {
          String key = storeData.menuCategories.keys.elementAt(index);
          List<Menu>? menus = categorizedMenus[key]; // 여기서는 nullable로 변경합니다.

          // 만약 menus가 null이면 해당 카테고리를 skip합니다.
          if (menus == null) {
            return SizedBox.shrink();
          }

          return ExpansionTile(
            initiallyExpanded: true,
            title: Text(storeData.menuCategories[key] ?? "카테고리 없음"),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                // 카테고리 수정 모달 표시 함수 호출
                showEditCategoryModal(context, key, storeData.menuCategories[key], storeData.menuCategories, menus);
              },
            ),
            children: menus.isNotEmpty ? menus.map((menu) => Card(
              child: ListTile(
                leading: menu.menuImageURL.isNotEmpty ? Image.network(
                  menu.menuImageURL,
                  width: 40.0,
                  height: 40.0,
                  fit: BoxFit.cover,  // 이미지가 지정된 공간에 맞도록 조절
                ) : null,
                title: Text(menu.menuName),
                subtitle: Text(menu.menuInfo),
                trailing: Text('${menu.price}￦', style: TextStyle(fontSize: 14)),
                onTap: () {
                  showModifyMenuModal(context, menu);
                },
              ),
            )).toList() : [ListTile(title: Text("이 카테고리에는 현재 메뉴가 없습니다. 필요시 추가해주세요!"))], // 메뉴가 없는 경우 처리
          );
        },
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          Positioned(
            bottom: 80.0,
            right: 10.0,
            child: FloatingActionButton(
              onPressed: () {
                // 새 기능 추가 예정
                showEditCategoryModal(context, null, null, storeData.menuCategories, []);
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
                showAddMenuModal(context, storeData.menuCategories, storeData.menuInfo);
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