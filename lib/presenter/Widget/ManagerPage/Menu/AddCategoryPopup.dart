import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/Model/MenuDataModel.dart';
import 'package:orre_manager/provider/Data/loginDataProvider.dart';
import 'package:orre_manager/provider/Data/storeDataProvider.dart';

void showAddCategoryModal(WidgetRef ref, String? menuCategoryKey,
  String? menuCategoryValue, Map<String, String?> currentMenuCategory, List<Menu>? menus) {
  showModalBottomSheet(
    context: ref.context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return AddCategoryModal(
        menuCategoryKey: menuCategoryKey,
        menuCategoryValue: menuCategoryValue,
        currentMenuCategory: currentMenuCategory,
        menuInCategory: menus,
        ref: ref,
      );
    },
  );
}

class AddCategoryModal extends StatelessWidget {
  String? menuCategoryKey;
  final WidgetRef ref;
  String? menuCategoryValue;
  List<Menu>? menuInCategory;
  final FocusNode _focusNode = FocusNode();
  final Map<String, String?> currentMenuCategory;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _controller;

  AddCategoryModal({this.menuCategoryKey, this.menuCategoryValue, required this.currentMenuCategory, this.menuInCategory, required this.ref})
      : _controller = TextEditingController(text: menuCategoryValue);

  @override
  Widget build(BuildContext context) {
    String? currentMenuCategoryKey = menuCategoryKey; // 현재 menuCategoryKey
      print('menuCategory한번 출력해보자');
      print('${currentMenuCategory.toString()}');
      print('menuInCategory한번 출력해보자');
      print('${menuInCategory.toString()}');
    // menuCategoryKey가 null이면, 값이 null인 첫 번째 key를 찾습니다.
    if (menuCategoryKey == null) {
      for (var key in currentMenuCategory.keys) {
        if (currentMenuCategory[key] == null) { // 값이 null인 경우
          menuCategoryKey = key;
          break;
        }
      }
    }

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                autofocus: true,
                focusNode: _focusNode,
                controller: _controller,
                decoration: InputDecoration(
                  hintText: '추가할 카테고리명을 입력해주세요.',
                  labelText: '카테고리 이름'
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '카테고리명은 필수입니다.';
                  }
                  return null;
                },
                onTap: () => _focusNode.requestFocus(),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  print('메뉴 카테고리: ${menuCategoryKey}, 카테고리명: ${_controller.text}');
                  // 등록 또는 수정 작업을 여기서 처리
                  if(true == await ref.read(storeDataProvider.notifier).editCategory(
                    context, ref.read(loginProvider.notifier).getLoginData(), menuInCategory,
                    menuCategoryKey!, _controller.text
                  )){ Navigator.of(context).pop(); } // 모달까지 닫아줌.
                }
              },
              child: Text('등록/수정하기'),
            ),
          ],
        ),
      ),
    );
  }
}

// void showAddCategoryDialog(WidgetRef ref, String? menuCategoryKey, String? menuCategoryValue, Map<String, String?> currentMenuCategory, List<Menu>? menus) {
//   List<Menu>? menuInCategory;
//   TextEditingController _categoryNameController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   String? currentMenuCategoryKey = menuCategoryKey; // 현재 menuCategoryKey
//   print('menuCategory한번 출력해보자');
//   print('${currentMenuCategory.toString()}');
//   print('menuInCategory한번 출력해보자');
//   print('${menuInCategory.toString()}');
//   // menuCategoryKey가 null이면, 값이 null인 첫 번째 key를 찾습니다.
//   if (menuCategoryKey == null) {
//     for (var key in currentMenuCategory.keys) {
//       if (currentMenuCategory[key] == null) { // 값이 null인 경우
//         menuCategoryKey = key;
//         break;
//       }
//     }
//   }

//   showDialog(
//     context: ref.context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text("새로운 카테고리 추가"),
//         content: Form(
//           key: _formKey,
//           child: TextFormField(
//             controller: _categoryNameController,
//             decoration: InputDecoration(
//               hintText: "새로 추가할 카테고리명을 입력하세요",
//               border: OutlineInputBorder(),
//               contentPadding: EdgeInsets.all(8),
//             ),
//             autofocus: true,
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return '카테고리명을 입력해주세요.';
//               }
//               return null;
//             },
//           ),
//         ),
//         actions: <Widget>[
//           TextButton(
//             child: Text("취소"),
//             onPressed: () {
//               Navigator.of(context).pop(); // 단순히 다이얼로그를 닫습니다.
//             },
//           ),
//           ElevatedButton(
//               onPressed: () async {
//                 if (_formKey.currentState!.validate()) {
//                   print('메뉴 카테고리: ${menuCategoryKey}, 카테고리명: ${_categoryNameController.text}');
//                   // 등록 또는 수정 작업을 여기서 처리
//                   if(true == await ref.read(storeDataProvider.notifier).editCategory(
//                     context, ref.read(loginProvider.notifier).getLoginData(), menuInCategory,
//                     menuCategoryKey!, _categoryNameController.text
//                   )){ Navigator.of(context).pop(); } // 모달까지 닫아줌.
//                 }
//               },
//               child: Text('등록/수정하기'),
//             ),
//         ],
//       );
//     },
//   );
// }
