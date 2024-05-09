import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/Model/login_data_model.dart';
import 'package:orre_manager/Model/menu_data_model.dart';
import 'package:orre_manager/Model/store_data_model.dart';
import 'package:orre_manager/presenter/Widget/AddMenuPopup.dart';
import 'package:orre_manager/presenter/table_status_screen.dart';
import 'package:orre_manager/provider/DataProvider/stomp_client_future_provider.dart';
import 'package:orre_manager/provider/DataProvider/store_data_provider.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class MenuListWidget extends ConsumerWidget {
  final LoginData loginResponse;
  final List<Menu>? menuList;
  final Map<String, dynamic>? menuCategory;

  MenuListWidget({required this.loginResponse, this.menuList, this.menuCategory});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (menuList == null || menuCategory == null) {
      return Center(child: Text("메뉴 정보를 불러올 수 없습니다."));
    }

    Map<String, List<Menu>> categorizedMenus = {};
    for (var menu in menuList!) {
      String categoryKey = menu.menuCode[0].toLowerCase();  // 메뉴 코드의 첫 글자를 소문자로 변환
      if (menuCategory!.containsKey(categoryKey)) {
        categorizedMenus.putIfAbsent(categoryKey, () => []).add(menu);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('메뉴 리스트'),
      ),
      body: ListView.builder(
        itemCount: categorizedMenus.keys.length,
        itemBuilder: (context, index) {
          String key = categorizedMenus.keys.elementAt(index);
          List<Menu> menus = categorizedMenus[key]!;
          return ExpansionTile(
            title: Text(menuCategory![key] ?? "카테고리 없음"),
            children: menus.map((menu) => Card(
              child: ListTile(
                leading: menu.menuImageURL.isNotEmpty ? Image.network(menu.menuImageURL) : null,
                title: Text(menu.menuName),
                subtitle: Text(menu.menuInfo),
                trailing: Text('\₩${menu.price}'),
                onTap: () {
                  // 메뉴 선택시 처리 로직을 여기에 추가하세요.
                },
              ),
            )).toList(),
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text('메뉴 추가하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
          ),
          FloatingActionButton(
            onPressed: () {
              // 메뉴 추가 로직을 여기에 추가하세요.
              // 예: Navigator.of(context).push(MaterialPageRoute(builder: (context) => MenuCreationScreen()));
              showAddMenuModal(context, menuCategory, menuList);
            },
            child: Icon(Icons.add),
            tooltip: '메뉴 추가하기',
          ),
        ],
      ),
    );
  }
}