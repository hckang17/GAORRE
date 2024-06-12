import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaorre/widget/button/image_edit_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gaorre/Model/LoginDataModel.dart';
import 'package:gaorre/Model/MenuDataModel.dart';
import 'package:gaorre/provider/Data/loginDataProvider.dart';
import 'package:gaorre/provider/Data/imageDataProvider.dart';
import 'package:gaorre/provider/Data/storeDataProvider.dart';
import 'package:gaorre/widget/button/small_button_widget.dart';

void showAddMenuModal(BuildContext context,
    Map<String, dynamic>? currentMenuCategory, List<Menu>? currentMenuList) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return AddMenuModal(
          currentMenuCategory: currentMenuCategory,
          currentMenuList: currentMenuList);
    },
  );
}

class AddMenuModal extends ConsumerStatefulWidget {
  final Map<String, dynamic>? currentMenuCategory;
  final List<Menu>? currentMenuList;

  AddMenuModal({this.currentMenuCategory, this.currentMenuList});

  @override
  _AddMenuModalState createState() => _AddMenuModalState();
}

class _AddMenuModalState extends ConsumerState<AddMenuModal> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;
  String? selectedCategoryKey;
  LoginData? loginData;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    descriptionController = TextEditingController();
    priceController = TextEditingController();
    loginData = ref.read(loginProvider);
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final ImagePicker picker = ImagePicker();

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Form(
        key: _formKey,
        child: Wrap(
          children: <Widget>[
            Stack(
              alignment: Alignment.topLeft,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                  child: IconButton(
                    onPressed: () {
                      ref.read(imageBytesProvider.notifier).resetState();
                      Navigator.pop(context);
                    },
                    icon: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF72AAD8),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(Icons.close, color: Colors.white),
                      padding: EdgeInsets.all(8),
                    ),
                  ),
                ),
                if (ref.watch(imageBytesProvider) != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Center(
                      child: ImageEditButton(),
                    ),
                  ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: SmallButtonWidget(
                    minSize: Size(60, 40),
                    text: '추가',
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        String menuCode = _generateMenuCode(
                            selectedCategoryKey, widget.currentMenuList);
                        print('메뉴 코드: $menuCode');

                        // 이미지 데이터
                        Uint8List? imageBytes =
                            ref.read(imageBytesProvider.notifier).getState();
                        if (imageBytes == null) {
                          print('입력된 이미지가 없어 기본 이미지로 대체합니다.');
                          ByteData bytes = await rootBundle
                              .load('lib/Assets/Image/Duck_with_bell.png');
                          imageBytes = bytes.buffer.asUint8List();
                        }

                        // 메뉴 이름
                        String name = nameController.text;
                        String description = descriptionController.text;
                        int price = int.parse(priceController.text);

                        // addMenu 함수 호출
                        if (true ==
                            await ref.read(storeDataProvider.notifier).addMenu(
                                context,
                                imageBytes,
                                menuCode,
                                name,
                                selectedCategoryKey!,
                                description,
                                price,
                                loginData)) {
                          ref.read(imageBytesProvider.notifier).resetState();
                          Navigator.pop(context);
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCategoryKey,
                    decoration: InputDecoration(
                      labelText: '메뉴 카테고리',
                      border: OutlineInputBorder(),
                    ),
                    items: widget.currentMenuCategory?.entries
                        .where((entry) => entry.value != null)
                        .map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value!),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedCategoryKey = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '카테고리를 선택해주세요.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: '메뉴 이름',
                      hintText: '메뉴 이름을 입력하세요',
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
                      hintText: '메뉴에 대한 설명을 입력하세요',
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
                      hintText: '가격을 입력하세요',
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
    for (var menu in menuList) {
      if (menu.menuCode.startsWith(categoryPrefix) &&
          menu.menuCode.length > categoryPrefix.length) {
        int currentNumber =
            int.tryParse(menu.menuCode.substring(categoryPrefix.length)) ?? 0;
        if (currentNumber > highestNumber) {
          highestNumber = currentNumber;
        }
      }
    }
    return '$categoryPrefix${(highestNumber + 1).toString().padLeft(3, '0')}';
  }
}
