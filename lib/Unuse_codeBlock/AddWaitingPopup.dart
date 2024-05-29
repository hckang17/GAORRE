// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:orre_manager/widget/button/text_button_widget.dart';
// import 'package:orre_manager/widget/text/text_widget.dart';

// void showEditCategoryDialog(BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return Dialog(
//         child: EditCategoryForm(),
//       );
//     },
//   );
// }

// class EditCategoryForm extends ConsumerWidget {
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Padding(
//       padding: const EdgeInsets.all(20.0),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           TextWidget('카테고리 수정'),
//           SizedBox(height: 20),
//           EditCategoryFields(),
//         ],
//       ),
//     );
//   }
// }

// class EditCategoryFields extends ConsumerStatefulWidget {
//   @override
//   _EditCategoryFieldsState createState() => _EditCategoryFieldsState();
// }

// class _EditCategoryFieldsState extends ConsumerState<EditCategoryFields> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   late TextEditingController categoryController;

//   @override
//   void initState() {
//     super.initState();
//     categoryController = TextEditingController();
//   }

//   @override
//   void dispose() {
//     categoryController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: _formKey,
//       child: Column(
//         children: [
//           TextFormField(
//             controller: categoryController,
//             decoration: InputDecoration(
//               labelText: '카테고리 명',
//               border: OutlineInputBorder(),
//               prefixIcon: Icon(Icons.category),  // '전화기' 아이콘 추가
//             ),
//             keyboardType: TextInputType.number,
//             inputFormatters: [FilteringTextInputFormatter.digitsOnly],  // 숫자만 입력 가능
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return '공백은 입력할 수 없습니다.';
//               } 
//               return null;
//             },
//           ),
//           SizedBox(height: 20),
//           Row(
//             children: [
//               TextButtonWidget(
//                 onPressed: () async {
//                   if (_formKey.currentState!.validate()) {
//                     // 폼 데이터를 검증하고 처리

//                     // 여기에다가 이제~ 웨이팅 수동 등록 코드 작성하기. 
//                     Navigator.pop(context);
//                   }
//                 },
//                 text: '수정',
//               ),
//               TextButtonWidget(
//                 onPressed: () async {

//                 },
//                 text: '삭제',
//               ),
//             ],
//           )
          
//         ],
//       ),
//     );
//   }
// }