import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:orre_manager/Model/login_data_model.dart';
import 'package:orre_manager/Model/menu_data_model.dart';
import 'package:orre_manager/provider/DataProvider/admin_login_provider.dart';
import 'package:orre_manager/provider/DataProvider/menu_image_provider.dart';
import 'package:orre_manager/provider/DataProvider/store_data_provider.dart';



void showModifyMenuModal(BuildContext context, Menu menu) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return ModifyMenuModal(menu: menu);
    },
  );
}

class ModifyMenuModal extends ConsumerWidget {
  final Menu menu;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ModifyMenuModal({required this.menu});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextEditingController nameController = TextEditingController(text: menu.menuName);
    TextEditingController descriptionController = TextEditingController(text: menu.menuInfo);
    TextEditingController priceController = TextEditingController(text: menu.price.toString());
    String originalMenuCode = menu.menuCode;

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Form(
        key: _formKey,
        child: Wrap(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Display the menu image if available
                  if (menu.menuImageURL.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Image.network(menu.menuImageURL, width: 100, height: 100, fit: BoxFit.cover),
                    ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: '메뉴 이름',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '메뉴 이름을 입력해주세요.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: '메뉴 설명',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '메뉴 설명을 입력해주세요.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '가격',
                      border: OutlineInputBorder(),
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '가격을 입력해주세요.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 버튼들 사이의 공간을 균등하게 배분
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              print('메뉴 수정: ${nameController.text}, ${descriptionController.text}, ${priceController.text}, 카테고리: ${originalMenuCode[0]}, 코드: $originalMenuCode');
                              if(true == await ref.read(storeDataProvider.notifier).modifyMenu(
                                context, ref.read(loginProvider.notifier).getLoginData(),
                                nameController.text, originalMenuCode,
                                int.parse(priceController.text),
                                descriptionController.text)
                              ){ Navigator.pop(context);}
                            }
                          },
                          child: Text('메뉴 수정하기'),
                        ),
                      ),
                      SizedBox(width: 8), // 버튼 사이의 간격
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                          if(await ref.read(storeDataProvider.notifier).removeMenu(context, menu.menuCode, menu.menuName, ref.read(loginProvider.notifier).getLoginData()) == true){
                            Navigator.pop(context);
                          }
                          },
                          child: Text('메뉴 삭제하기'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red, // 삭제 버튼에 빨간색 적용
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _generateMenuCode(String? categoryKey, List<Menu>? menuList) {
    if (categoryKey == null || menuList == null) return '';
    int highestNumber = 0;
    String categoryPrefix = categoryKey.toUpperCase();
    for (Menu menu in menuList) {
      if (menu.menuCode.startsWith(categoryPrefix)) {
        int currentNumber = int.tryParse(menu.menuCode.substring(1)) ?? 0;
        if (currentNumber > highestNumber) {
          highestNumber = currentNumber;
        }
      }
    }
    return '$categoryPrefix${(highestNumber + 1).toString().padLeft(3, '0')}';  // 예: "B004"
  }
}

