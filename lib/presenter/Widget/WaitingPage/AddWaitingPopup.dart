import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void showAddWaitingDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: AddWaitingForm(),
      );
    },
  );
}

class AddWaitingForm extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('웨이팅 추가', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          AddWaitingFields(),
        ],
      ),
    );
  }
}

class AddWaitingFields extends ConsumerStatefulWidget {
  @override
  _AddWaitingFieldsState createState() => _AddWaitingFieldsState();
}

class _AddWaitingFieldsState extends ConsumerState<AddWaitingFields> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController phoneNumberController;
  late TextEditingController waitingPersonCountController;

  @override
  void initState() {
    super.initState();
    phoneNumberController = TextEditingController();
    waitingPersonCountController = TextEditingController();
  }

  @override
  void dispose() {
    phoneNumberController.dispose();
    waitingPersonCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: phoneNumberController,
            decoration: InputDecoration(
              labelText: '연락처',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),  // '전화기' 아이콘 추가
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],  // 숫자만 입력 가능
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '연락처를 입력해주세요.';
              } else if (value.length < 10) {  // 최소 길이 설정 (예시)
                return '유효한 연락처를 입력해주세요.';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: waitingPersonCountController,
            decoration: InputDecoration(
              labelText: '대기 인원 수',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),  // '사람' 아이콘 추가
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],  // 숫자만 입력 가능
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '대기 인원 수를 입력해주세요.';
              } else if (int.tryParse(value) == null) {
                return '숫자를 입력해주세요.';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // 폼 데이터를 검증하고 처리
                int waitingCount = int.parse(waitingPersonCountController.text);
                print('연락처: ${phoneNumberController.text}, 대기 인원 수: $waitingCount');
                // 여기에다가 이제~ 웨이팅 수동 등록 코드 작성하기. 
                Navigator.pop(context);
              }
            },
            child: Text('추가하기'),
          ),
        ],
      ),
    );
  }
}