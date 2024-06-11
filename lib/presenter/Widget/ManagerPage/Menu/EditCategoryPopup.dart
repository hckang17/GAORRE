import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaorre/Model/MenuDataModel.dart';
import 'package:gaorre/presenter/Widget/AlertDialog.dart';
import 'package:gaorre/provider/Data/loginDataProvider.dart';
import 'package:gaorre/provider/Data/storeDataProvider.dart';
import 'package:gaorre/widget/button/pop_button_widget.dart';
import 'package:gaorre/widget/button/small_button_widget.dart';
import 'package:gaorre/widget/button/text_button_widget.dart';
import 'package:gaorre/widget/text/text_widget.dart';

void showEditCategoryDialog(
    WidgetRef ref,
    String? menuCategoryKey,
    String? menuCategoryValue,
    Map<String, String?> currentMenuCategory,
    List<Menu>? menus) {
  showDialog(
    context: ref.context,
    builder: (ref) {
      return Dialog(
        child: EditCategoryForm(
          menuCategoryKey: menuCategoryKey,
          menuCategoryValue: menuCategoryValue,
          currentMenuCategory: currentMenuCategory,
          menus: menus,
        ),
      );
    },
  );
}

class EditCategoryForm extends ConsumerWidget {
  late String? menuCategoryKey;
  late String? menuCategoryValue;
  late Map<String, String?>? currentMenuCategory;
  late List<Menu>? menus;

  EditCategoryForm({
    this.menuCategoryKey,
    this.menuCategoryValue,
    this.currentMenuCategory,
    this.menus,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TextWidget('카테고리 수정'),
              Spacer(),
              PopButtonWidget(),
            ],
          ),
          SizedBox(height: 20),
          EditCategoryFields(
              menuCategoryKey: menuCategoryKey,
              menuCategoryValue: menuCategoryValue,
              currentMenuCategory: currentMenuCategory,
              menus: menus),
        ],
      ),
    );
  }
}

class EditCategoryFields extends ConsumerStatefulWidget {
  late String? menuCategoryKey;
  late String? menuCategoryValue;
  late Map<String, String?>? currentMenuCategory;
  late List<Menu>? menus;

  EditCategoryFields({
    this.menuCategoryKey,
    this.menuCategoryValue,
    this.currentMenuCategory,
    this.menus,
  });

  @override
  _EditCategoryFieldsState createState() => _EditCategoryFieldsState();
}

class _EditCategoryFieldsState extends ConsumerState<EditCategoryFields> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController categoryController;
  late String? menuCategoryKey;
  late String? menuCategoryValue;
  late Map<String, String?>? currentMenuCategory;
  late List<Menu>? menus;

  @override
  void initState() {
    super.initState();
    menuCategoryKey = widget.menuCategoryKey;
    menuCategoryValue = widget.menuCategoryValue;
    currentMenuCategory = widget.currentMenuCategory;
    menus = widget.menus;
    categoryController = TextEditingController(text: menuCategoryValue);
  }

  @override
  void dispose() {
    categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: categoryController,
            decoration: InputDecoration(
              labelText: '카테고리 명',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.category), // '전화기' 아이콘 추가
            ),
            keyboardType: TextInputType.text,
            inputFormatters: [
              FilteringTextInputFormatter.singleLineFormatter
            ], // 숫자만 입력 가능
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '공백은 입력할 수 없습니다.';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SmallButtonWidget(
                minSize: Size(70, 30),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    print(
                        '메뉴 카테고리: ${menuCategoryKey}, 카테고리명: ${categoryController.text}');
                    // 등록 또는 수정 작업을 여기서 처리
                    if (true ==
                        await ref.read(storeDataProvider.notifier).editCategory(
                            context,
                            ref.read(loginProvider.notifier).getLoginData(),
                            menus,
                            menuCategoryKey!,
                            categoryController.text)) {
                      Navigator.of(context).pop();
                    } // 모달까지 닫아줌.
                  }
                },
                text: '수정',
                color: Color(0xFF72AAD8),
              ),
              SizedBox(width: 8),
              SmallButtonWidget(
                minSize: Size(70, 30),
                onPressed: () async {
                  print('카테고리 삭제: ${menuCategoryKey}');
                  print(menus.toString());
                  if (menus!.isNotEmpty) {
                    await showAlertDialog(context, "카테고리 삭제",
                        "카테고리의 모든 메뉴를 삭제한 후 다시 시도해 주세요", null);
                    return;
                  }

                  if (false ==
                      await showConfirmDialog(
                          context, "카테고리 삭제", "카테고리를 정말 삭제하시겠습니까?")) {
                    return;
                  }

                  if (true ==
                      await ref.read(storeDataProvider.notifier).editCategory(
                          context,
                          ref.read(loginProvider.notifier).getLoginData(),
                          menus,
                          menuCategoryKey!,
                          null)) {
                    Navigator.of(context).pop();
                  }
                },
                text: '삭제',
                color: Colors.red,
              ),
            ],
          )
        ],
      ),
    );
  }
}
