import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaorre/Model/MenuDataModel.dart';
import 'package:gaorre/presenter/Widget/AlertDialog.dart';
import 'package:gaorre/provider/Data/loginDataProvider.dart';
import 'package:gaorre/provider/Data/storeDataProvider.dart';
import 'package:gaorre/widget/button/image_edit_widget.dart';
import 'package:gaorre/widget/text/text_widget.dart';

void showModifyMenuModal(BuildContext context, Menu menu) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return ModifyMenuModal(menu: menu);
    },
  );
}

class ModifyMenuModal extends ConsumerStatefulWidget {
  final Menu menu;

  ModifyMenuModal({required this.menu});

  @override
  _ModifyMenuModalState createState() => _ModifyMenuModalState();
}

class _ModifyMenuModalState extends ConsumerState<ModifyMenuModal> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late bool isRecommended;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.menu.menuName);
    descriptionController = TextEditingController(text: widget.menu.menuInfo);
    priceController = TextEditingController(text: widget.menu.price.toString());
    isRecommended = widget.menu.recommend == 1 ? true : false;
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
    String originalMenuCode = widget.menu.menuCode;

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
                if (widget.menu.menuImageURL.isNotEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      // child: Image.network(
                      //   widget.menu.menuImageURL,
                      //   width: 200,
                      //   height: 200,
                      //   fit: BoxFit.cover,
                      // ),
                      child: ImageEditButton(menu: widget.menu),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextWidget(
                          "추천메뉴 등록",
                          textAlign: TextAlign.end,
                        ),
                      ),
                      Checkbox(
                        value: isRecommended,
                        onChanged: (bool? value) {
                          setState(() {
                            isRecommended = value ?? false;
                          });
                        },
                        activeColor: Color(0xFF72AAD8),
                        checkColor: Colors.white,
                      ),
                    ],
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
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              print(
                                  '메뉴 수정: ${nameController.text}, ${descriptionController.text}, ${priceController.text}, 카테고리: ${originalMenuCode[0]}, 코드: $originalMenuCode');
                              if (true ==
                                      await ref
                                          .read(storeDataProvider.notifier)
                                          .modifyMenu(
                                              context,
                                              ref
                                                  .read(loginProvider.notifier)
                                                  .getLoginData()!,
                                              widget.menu.menuName,
                                              nameController.text,
                                              originalMenuCode,
                                              int.parse(priceController.text),
                                              descriptionController.text,
                                              isRecommended
                                                  ? 1
                                                  : 0) //여기에 recommend추가
                                  ) {
                                Navigator.pop(context);
                              }
                            }
                          },
                          child: TextWidget(
                            '메뉴 수정하기',
                            fontSize: 16,
                            color: Color(0xFF72AAD8),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (await showConfirmDialog(ref.context, "메뉴 삭제",
                                "정말로 \"${nameController.text}\" 메뉴를 삭제하시겠습니까?")) {
                              if (await ref
                                      .read(storeDataProvider.notifier)
                                      .removeMenu(
                                          context,
                                          originalMenuCode,
                                          nameController.text,
                                          ref
                                              .read(loginProvider.notifier)
                                              .getLoginData()) ==
                                  true) {
                                Navigator.pop(context);
                              }
                            }
                          },
                          child: TextWidget(
                            '메뉴 삭제하기',
                            fontSize: 16,
                            color: Colors.red,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFDFDFDF),
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
}
