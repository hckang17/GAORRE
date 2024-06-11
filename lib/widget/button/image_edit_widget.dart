import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaorre/provider/Data/imageDataProvider.dart';
import 'package:gaorre/provider/Data/storeDataProvider.dart';

import '../../Model/MenuDataModel.dart';

// ignore: must_be_immutable
class ImageEditButton extends ConsumerWidget {
  Menu? menu;
  ImageEditButton({this.menu});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tempImg = ref.watch(imageBytesProvider);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () {
          print("test");
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
                      if (menu != null) {
                        return Image.network(
                          menu!.menuImageURL,
                          width: 180,
                          height: 180,
                          fit: BoxFit.cover,
                        );
                      }
                      if (tempImg != null && menu == null) {
                        return Image.memory(
                          tempImg,
                          width: 180,
                          height: 180,
                          fit: BoxFit.cover,
                        );
                      }
                      return Container();
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
