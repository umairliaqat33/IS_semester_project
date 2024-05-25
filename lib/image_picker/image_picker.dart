import 'dart:io';

import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';

class ImagePickerBigWidget extends StatelessWidget {
  final String heading;
  final String description;
  final Function onPressed;
  final PlatformFile? platformFile;
  final String? imgUrl;

  const ImagePickerBigWidget({
    super.key,
    required this.heading,
    required this.description,
    required this.onPressed,
    required this.platformFile,
    required this.imgUrl,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: (imgUrl != null && imgUrl!.isNotEmpty) && platformFile == null
          ? MaterialButton(
              onPressed: () async => onPressed(),
              child: SizedBox(
                width: double.infinity,
                height: 160,
                child: Stack(children: [
                  Image.network(
                    width: double.infinity,
                    imgUrl!,
                    fit: BoxFit.contain,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),
                  Visibility(
                    visible: imgUrl != null && platformFile == null,
                    child: Container(
                      height: 160,
                      width: double.infinity,
                      color: Colors.transparent,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.transparent.withOpacity(0.3)),
                        alignment: Alignment.center,
                        child: const Text(
                          "Edit Picture",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            )
          : platformFile != null
              ? SizedBox(
                  width: (328),
                  height: (160),
                  child: Container(
                    color: Colors.black.withOpacity(0.6),
                    child: MaterialButton(
                      onPressed: () async => onPressed(),
                      child: Image.file(
                        File(platformFile!.path!),
                        width: double.infinity,
                      ),
                    ),
                  ),
                )
              : MaterialButton(
                  onPressed: () async => onPressed(),
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      Image.network(
                          "https://www.jqueryscript.net/images/Multiple-Image-Picker-jQuery-Spartan.jpg"),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 75,
                        ),
                        child: Column(
                          children: [
                            Text(
                              textAlign: TextAlign.center,
                              heading,
                              style: TextStyle(
                                color: Colors.grey.withOpacity(0.5),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(
                              width: 183,
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: description,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const TextSpan(
                                      text: '2 MB',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
