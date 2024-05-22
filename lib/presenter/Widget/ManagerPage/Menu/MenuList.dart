import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/Model/LoginDataModel.dart';
import 'package:orre_manager/Model/MenuDataModel.dart';
import 'package:orre_manager/presenter/Widget/ManagerPage/Menu/AddMenuPopup.dart';
import 'package:orre_manager/presenter/Widget/ManagerPage/Menu/EditCategoryPopup.dart';
import 'package:orre_manager/provider/Data/loginDataProvider.dart';
import 'package:orre_manager/provider/Data/storeDataProvider.dart';
import 'package:orre_manager/presenter/Widget/ManagerPage/Menu/ModifyMenuPopup.dart';
import 'package:orre_manager/widget/text/text_widget.dart';

class MenuListWidget extends ConsumerWidget {
  MenuListWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeData = ref.watch(storeDataProvider);

    if (storeData?.menuInfo == null || storeData?.menuCategories == null) {
      return SliverFillRemaining(child: Center(child: Text("메뉴 정보를 불러올 수 없습니다.")));
    }

    Map<String, List<Menu>> categorizedMenus = {};
    storeData!.menuCategories!.forEach((key, value) {
      if (value != null) {
        categorizedMenus[key] = [];
      }
    });

    for (var menu in storeData.menuInfo!) {
      String categoryKey = menu.menuCode[0].toLowerCase();
      if (categorizedMenus.containsKey(categoryKey)) {
        categorizedMenus[categoryKey]!.add(menu);
      }
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          String key = storeData.menuCategories.keys.elementAt(index);
          List<Menu>? menus = categorizedMenus[key];
          if (menus == null) {
            return SizedBox.shrink();
          }

          return ExpansionTile(
            initiallyExpanded: true,
            title: Padding(
              padding: EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, color: Color.fromARGB(255, 39, 194, 255)),
                  SizedBox(width: 5),
                  TextWidget(
                    storeData.menuCategories[key] ?? "카테고리 없음",
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 39, 194, 255),
                  ),
                  SizedBox(width: 5),
                  Icon(Icons.auto_awesome, color: Color.fromARGB(255, 39, 194, 255)),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.edit_note),
                    onPressed: () {
                      showEditCategoryModal(ref, key, storeData.menuCategories[key], storeData.menuCategories, menus);
                    },
                  ),
                ],
              ),
            ),
            children: menus.isNotEmpty ? menus.map((menu) => Card(
              child: StoreMenuTileWidget(menu: menu) 
            )).toList() : [ListTile(title: Text("이 카테고리에는 현재 메뉴가 없습니다. 필요시 추가해주세요!"))],
          );
        },
        childCount: storeData.menuCategories.length,
      ),
    );
  }
}

class StoreMenuTileWidget extends ConsumerWidget {
  final Menu menu;

  StoreMenuTileWidget({
    required this.menu,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Material(
          color: Colors.white, // 배경색을 흰색으로 설정
          child: ListTile(
            title: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        menu.menuName,
                        textAlign: TextAlign.left,
                        fontSize: 28,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      TextWidget(
                        '${menu.menuInfo}',
                        textAlign: TextAlign.left,
                        fontSize: 18,
                        color: Color.fromARGB(255, 117, 117, 117),
                        overflow: TextOverflow.ellipsis,
                      ),
                      TextWidget(
                        '${menu.price}원',
                        textAlign: TextAlign.left,
                        fontSize: 24,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                CachedNetworkImage(
                  imageUrl: menu.menuImageURL,
                  imageBuilder: (context, imageProvider) => Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ],
            ),
            onTap: () {
              showModifyMenuModal(context, menu);
            },
          ),
        ),
        Divider(
          color: Colors.grey,
          height: 1,
        ),
      ],
    );
  }
}
