import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/Model/MenuDataModel.dart';
import 'package:orre_manager/presenter/Widget/AlertDialog.dart';
import 'package:orre_manager/provider/Data/loginDataProvider.dart';
import 'package:orre_manager/provider/Data/storeDataProvider.dart';
import 'package:orre_manager/widget/button/text_button_widget.dart';
import 'package:orre_manager/widget/text/text_widget.dart';

void showAddCategoryDialog(WidgetRef ref,
    String? menuCategoryKey,
    String? menuCategoryValue,
    Map<String, String?> currentMenuCategory,
    List<Menu>? menus) {
  showDialog(
    context: ref.context,
    builder: (ref) {
      return Dialog(
        child: AddCategoryForm(
          menuCategoryKey: menuCategoryKey,
          menuCategoryValue: menuCategoryValue,
          currentMenuCategory: currentMenuCategory,
          menus: menus,
        ),
      );
    },
  );
}

class AddCategoryForm extends ConsumerWidget {
  late String? menuCategoryKey;
  late String? menuCategoryValue;
  late Map<String, String?>? currentMenuCategory;
  late List<Menu>? menus;

  AddCategoryForm({
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
        children: [
          TextWidget('카테고리 추가'),
          SizedBox(height: 20),
          AddCategoryFields(
            menuCategoryKey: menuCategoryKey,
            menuCategoryValue: menuCategoryValue,
            currentMenuCategory: currentMenuCategory,
            menus: menus
          ),
        ],
      ),
    );
  }
}

class AddCategoryFields extends ConsumerStatefulWidget {
  late String? menuCategoryKey;
  late String? menuCategoryValue;
  late Map<String, String?>? currentMenuCategory;
  late List<Menu>? menus;

  AddCategoryFields({
    this.menuCategoryKey,
    this.menuCategoryValue,
    this.currentMenuCategory,
    this.menus,
  });
  
  @override
  _AddCategoryFieldsState createState() => _AddCategoryFieldsState();
}

class _AddCategoryFieldsState extends ConsumerState<AddCategoryFields> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController categoryController;
  late String? menuCategoryKey;
  late String? menuCategoryValue;
  late Map<String, String?>? currentMenuCategory;
  late List<Menu>? menus;

  late String newMenuCategoryKey;  

  @override
  void initState() {
    super.initState();
    menuCategoryKey = widget.menuCategoryKey;
    menuCategoryValue = widget.menuCategoryValue;
    currentMenuCategory = widget.currentMenuCategory;
    menus = widget.menus;
    categoryController = TextEditingController();
  }

  @override
  void dispose() {
    categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (menuCategoryKey == null) {
      for (var key in currentMenuCategory!.keys) {
        if (currentMenuCategory![key] == null) {
          newMenuCategoryKey = key;
          break;
        }
      }
    }

    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: categoryController,
            decoration: InputDecoration(
              labelText: '카테고리 명',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.category, color:Colors.blue),  // '전화기' 아이콘 추가
            ),
            keyboardType: TextInputType.text,
            inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],  // 숫자만 입력 가능
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '공백은 입력할 수 없습니다.';
              } 
              return null;
            },
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButtonWidget(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    print('메뉴 카테고리: $menuCategoryKey, 카테고리명: ${categoryController.text}');
                    // 등록 또는 수정 작업을 여기서 처리
                    bool result = await ref.read(storeDataProvider.notifier).editCategory(
                      context, ref.read(loginProvider.notifier).getLoginData(), menus,
                      menuCategoryKey ?? newMenuCategoryKey, categoryController.text
                    );
                    if(result) { Navigator.of(context).pop(); } // 모달까지 닫아줌.
                  }
                },
                text: '추가',
              ),
            ],
          )
        ],
      ),
    );
  }
}