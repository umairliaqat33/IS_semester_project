import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:is_semester_project/algorithm.dart';
import 'package:is_semester_project/image_picker/image_picker.dart';
import 'package:is_semester_project/media_service.dart';
// import 'package:is_semester_project/second_algorithm.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _messageController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final Algorithm _algorithm = Algorithm();
  PlatformFile? _profilePlatformFile;
  String decryptedText = '';
  String encryptedText = '';

  @override
  void initState() {
    super.initState();
    _algorithm.generateAndStoreKey();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.amberAccent,
            title: const Text("Information Security"),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _messageController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "field is required";
                        } else {
                          return null;
                        }
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: 300,
                      child: ImagePickerBigWidget(
                        heading: "heading",
                        description: "description",
                        onPressed: () => _selectProfileImage(),
                        platformFile: _profilePlatformFile,
                        imgUrl: null,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: () => encrypt(),
                      child: const Text("Encrypt"),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: () => decrypt(),
                      child: const Text("Decrypt"),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Visibility(
                      visible: decryptedText.isNotEmpty,
                      child: Text(
                        decryptedText,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectProfileImage() async {
    try {
      if (_formKey.currentState!.validate()) {
        _profilePlatformFile = await MediaService.selectFile();
        Fluttertoast.showToast(msg: "Image selected");
        setState(() {});
      }
    } catch (e) {
      log("Exception in _SelectiPRofileImage in EditProfileclass: ${e.toString()}");
    }
  }

  Future<void> encrypt() async {
    if (_profilePlatformFile != null) {
      encryptedText = await MediaService.encryptImageWithText(
        imagePath: _profilePlatformFile!.path!,
        textToAppend: _messageController.text,
      );
      Fluttertoast.showToast(msg: "Image encrypted");
      setState(() {});
    }
  }

  Future<void> decrypt() async {
    decryptedText = await MediaService.decryptImageWithText(
      encryptedFilePath: encryptedText,
      textLength: _messageController.text.length,
    );
    Fluttertoast.showToast(msg: "Image decrypted");
    setState(() {});
  }
}
