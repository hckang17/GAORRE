import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/Model/MenuDataModel.dart';
import 'package:orre_manager/provider/Data/loginDataProvider.dart';
import 'package:orre_manager/provider/Data/storeDataProvider.dart';
import 'package:orre_manager/widget/text/text_widget.dart';

void showEditCategoryModal(
    WidgetRef ref,
    String? menuCategoryKey,
    String? menuCategoryValue,
    Map<String, String?> currentMenuCategory,
    List<Menu>? menus) {
  showModalBottomSheet(
    context: ref.context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return EditCategoryModal(
        menuCategoryKey: menuCategoryKey,
        menuCategoryValue: menuCategoryValue,
        currentMenuCategory: currentMenuCategory,
        menuInCategory: menus,
        ref: ref,
      );
    },
  );
}

class EditCategoryModal extends StatelessWidget {
  String? menuCategoryKey;
  final WidgetRef ref;
  String? menuCategoryValue;
  List<Menu>? menuInCategory;
  final FocusNode _focusNode = FocusNode();
  final Map<String, String?> currentMenuCategory;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _controller;

  EditCategoryModal(
      {this.menuCategoryKey,
      this.menuCategoryValue,
      required this.currentMenuCategory,
      this.menuInCategory,
      required this.ref})
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
        if (currentMenuCategory[key] == null) {
          // 값이 null인 경우
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
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                autofocus: true,
                focusNode: _focusNode,
                controller: _controller,
                decoration: InputDecoration(
                  hintText: '카테고리명을 입력해주세요.',
                  hintStyle: TextStyle(fontFamily: 'Dovemayo_gothic'),
                  labelText: '카테고리 이름',
                  labelStyle: TextStyle(
                      fontFamily: 'Dovemayo_gothic', color: Color(0xFF72AAD8)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF72AAD8)),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF72AAD8)),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 20.0),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      print(
                          '메뉴 카테고리: ${menuCategoryKey}, 카테고리명: ${_controller.text}');
                      // 등록 또는 수정 작업을 여기서 처리
                      if (true ==
                          await ref
                              .read(storeDataProvider.notifier)
                              .editCategory(
                                  context,
                                  ref
                                      .read(loginProvider.notifier)
                                      .getLoginData(),
                                  menuInCategory,
                                  menuCategoryKey!,
                                  _controller.text)) {
                        Navigator.of(context).pop();
                      } // 모달까지 닫아줌.
                    }
                  },
                  child: TextWidget(
                    '등록/수정하기',
                    fontSize: 16,
                    color: Color(0xFF72AAD8),
                  ),
                ),
                SizedBox(width: 15),
                ElevatedButton(
                  onPressed: (currentMenuCategoryKey != null)
                      ? () async {
                          // 카테고리 삭제 로직 -> 현재 카테고리 키가 null이 아니고 해당 카테고리에 배정된 메뉴가 없을때
                          print('카테고리 삭제: ${currentMenuCategoryKey}');
                          if (true ==
                              await ref
                                  .read(storeDataProvider.notifier)
                                  .editCategory(
                                      context,
                                      ref
                                          .read(loginProvider.notifier)
                                          .getLoginData(),
                                      menuInCategory,
                                      currentMenuCategoryKey,
                                      null)) {
                            Navigator.of(context).pop();
                          }
                        }
                      : null, // menuCategoryKey가 null이면 버튼 비활성화
                  child: TextWidget(
                    '카테고리 삭제하기',
                    fontSize: 16,
                    color: menuCategoryKey == null
                        ? Colors.black
                        : Color(0xFF999999),
                  ),
                  style: ElevatedButton.styleFrom(
                    disabledForegroundColor: Colors.grey.withOpacity(0.38),
                    disabledBackgroundColor:
                        Colors.grey.withOpacity(0.12), // 비활성화 상태에서의 색상
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// void showEditCategoryModal(BuildContext context, String? menuCategoryKey,
//     String? menuCategoryValue, Map<String, String?> currentMenuCategory, List<Menu>? menus) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     builder: (BuildContext context) {
//       return EditCategoryModal(
//         menuCategoryKey: menuCategoryKey,
//         menuCategoryValue: menuCategoryValue,
//         currentMenuCategory: currentMenuCategory,
//         menuInCategory: menus,
//       );
//     },
//   );
// }

// class EditCategoryModal extends ConsumerStatefulWidget {
//   final String? menuCategoryKey;
//   final String? menuCategoryValue;
//   final List<Menu>? menuInCategory;
//   final Map<String, String?> currentMenuCategory;

//   EditCategoryModal({
//     this.menuCategoryKey,
//     this.menuCategoryValue,
//     required this.currentMenuCategory,
//     this.menuInCategory,
//   });

//   @override
//   _EditCategoryModalState createState() => _EditCategoryModalState();
// }

// class _EditCategoryModalState extends ConsumerState<EditCategoryModal> {
//   late TextEditingController _controller;
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   @override
//   void initState() {
//     super.initState();
//     _controller = TextEditingController(text: widget.menuCategoryValue);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     String? currentMenuCategoryKey = widget.menuCategoryKey;
//     print('menuCategory한번 출력해보자');
//     print('${widget.currentMenuCategory.toString()}');
//     print('menuInCategory한번 출력해보자');
//     print('${widget.menuInCategory.toString()}');

//     // menuCategoryKey가 null이면, 값이 null인 첫 번째 key를 찾습니다.
//     if (currentMenuCategoryKey == null) {
//       for (var key in widget.currentMenuCategory.keys) {
//         if (widget.currentMenuCategory[key] == null) { // 값이 null인 경우
//           currentMenuCategoryKey = key;
//           break;
//         }
//       }
//     }

//     return Padding(
//       padding: MediaQuery.of(context).viewInsets,
//       child: Form(
//         key: _formKey,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: TextFormField(
//                 controller: _controller,
//                 decoration: InputDecoration(
//                   hintText: '카테고리명을 입력해주세요.',
//                   labelText: '카테고리 이름',
//                 ),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return '카테고리명은 필수입니다.';
//                   }
//                   return null;
//                 },
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 if (_formKey.currentState!.validate()) {
//                   print('메뉴 카테고리: $currentMenuCategoryKey, 카테고리명: ${_controller.text}');
//                   // 등록 또는 수정 작업을 여기서 처리
//                   if (true == await ref.read(storeDataProvider.notifier).editCategory(
//                     context,
//                     ref.read(loginProvider.notifier).getLoginData(),
//                     widget.menuInCategory,
//                     currentMenuCategoryKey!,
//                     _controller.text,
//                   )) {
//                     Navigator.of(context).pop(); // 모달까지 닫아줌.
//                   }
//                 }
//               },
//               child: Text('등록/수정하기'),
//             ),
//             ElevatedButton(
//               onPressed: (currentMenuCategoryKey != null) ? () async {
//                 // 카테고리 삭제 로직 -> 현재 카테고리 키가 null이 아니고 해당 카테고리에 배정된 메뉴가 없을때
//                 print('카테고리 삭제: $currentMenuCategoryKey');
//                 if (true == await ref.read(storeDataProvider.notifier).editCategory(
//                   context,
//                   ref.read(loginProvider.notifier).getLoginData(),
//                   widget.menuInCategory,
//                   currentMenuCategoryKey!,
//                   null,
//                 )) {
//                   Navigator.of(context).pop();
//                 }
//               } : null, // menuCategoryKey가 null이면 버튼 비활성화
//               child: Text('카테고리 삭제하기'),
//               style: ElevatedButton.styleFrom(
//                 disabledForegroundColor: Colors.grey.withOpacity(0.38),
//                 disabledBackgroundColor: Colors.grey.withOpacity(0.12), // 비활성화 상태에서의 색상
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
