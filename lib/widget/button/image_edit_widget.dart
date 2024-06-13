import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaorre/presenter/Widget/alertDialog.dart';
import 'package:gaorre/provider/Data/imageDataProvider.dart';
import '../../Model/MenuDataModel.dart';
import 'package:image_picker/image_picker.dart';


// ignore: must_be_immutable
class ImageEditButton extends ConsumerStatefulWidget {
  Menu? menu;
  ImageEditButton({this.menu});

  @override
  _ImageEditButtonState createState() => _ImageEditButtonState();
}

class _ImageEditButtonState extends ConsumerState<ImageEditButton> {
  late String? imageURL;
  bool isImageChanged = false;
  
  @override
  void initState() {
    super.initState();
    if(widget.menu != null){
      imageURL = widget.menu!.menuImageURL;
    }else{
      imageURL = null;
    }
    isImageChanged = false;
  }

  @override
  Widget build(BuildContext context) {
    final tempImg = ref.watch(imageBytesProvider);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () async {
          // print("test");
          final ImagePicker picker = ImagePicker();
          var result = await showSelectDialog(context, "이미지 선택", "이미지를 어디서 가져올까요?", "신규촬영", "앨범에서");
          switch (result) {
            case 0:
              return;
            case 1:
              final pickedFile = await picker.pickImage(source: ImageSource.camera);
              if (pickedFile != null) {
                Uint8List fileBytes = await pickedFile.readAsBytes();
                ref.read(imageBytesProvider.notifier).setState(fileBytes);
                isImageChanged = true;
              }
              break;
            case 2:
              final pickedFile = await picker.pickImage(
                  source: ImageSource.gallery);
              if (pickedFile != null) {
                Uint8List fileBytes = await pickedFile.readAsBytes();
                ref.read(imageBytesProvider.notifier).setState(fileBytes);
                isImageChanged = true;
              }
              break;
            default:
              print("알수없는 에러가 발생하였습니다. [ImageEditButton]");
          }
        },
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Color(0xFF72AAD8),
              width: 2,
            ),
            color: Color(0xFFDFDFDF),
          ),
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: 180,
                  height: 180,
                  child: Consumer(
                    builder: (context, watch, child) {
                      if(isImageChanged){
                        return Image.memory(
                          tempImg!,
                          width: 180,
                          height: 180,
                          fit: BoxFit.cover,
                        );
                      }else{
                        if (imageURL != null) {
                          return Image.network(
                            imageURL!,
                            width: 180,
                            height: 180,
                            fit: BoxFit.cover,
                          );
                        }else if (tempImg != null){
                          return Image.memory(
                            tempImg,
                            width: 180,
                            height: 180,
                            fit: BoxFit.cover,
                          );
                        }
                        return Container();
                      }
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Color(0xFF72AAD8),
                      width: 2,
                    ),
                  ),
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.add_a_photo_outlined,
                    color: Color(0xFF72AAD8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}