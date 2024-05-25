import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:is_semester_project/keys.dart';
import 'package:is_semester_project/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:path/path.dart' as paths;

class MediaService {
  // ignore: body_might_complete_normally_nullable
  static Future<PlatformFile?> selectFile() async {
    PermissionStatus permissionStatus = Platform.isIOS
        ? await Permission.photos.request()
        : await Permission.storage.request();

    try {
      if (permissionStatus == PermissionStatus.granted) {
        PlatformFile platformFile;
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['jpg', 'jpeg', 'png'],
          allowMultiple: false,
        );
        if (result == null) return null;
        platformFile = result.files.first;

        log(platformFile.path.toString());
        log(platformFile.toString());
        return platformFile;
      }
    } catch (e) {
      if (permissionStatus == PermissionStatus.denied) {
        log("Storage Permission Denied");
      } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
        log("Storage Permission Permanently Denied");
      } else {
        log("Something went wrong");
      }
    }
  }

// **Crucial Security Consideration:**
// - Use a secure key derivation function like PBKDF2 to generate a strong key
//   from a user-provided password. This is **highly recommended** for real-world
//   applications to prevent brute-force attacks.
// - Store the derived key securely, using a keystore or similar mechanism.

  Future<String> createFolderInRoot() async {
    // Request storage permission on Android
    String folderPath = '';
    if (await Permission.storage.request().isGranted) {
      // Get the root directory (external storage directory)
      Directory? rootDir = await getExternalStorageDirectory();

      if (rootDir != null) {
        // Define the folder name and path
        String newFolderPath = '${rootDir.path}/Image Encryptor';
        final newFolder = Directory(newFolderPath);
        folderPath = newFolder.path;

        // Check if the folder already exists
        if (await newFolder.exists()) {
          log("Folder already exists");
        } else {
          // Create the folder
          await newFolder.create(recursive: true);
          log("Folder created at: $newFolderPath");
        }
      } else {
        log("Root directory not found");
      }
    } else {
      log("Storage permission denied");
    }
    return folderPath;
  }

  static Future<String> encryptImageWithText({
    required String imagePath,
    required String textToAppend,
  }) async {
    // Read image file
    final file = File(imagePath);
    final imageBytes = await file.readAsBytes();

    // Combine image bytes and text bytes
    final textBytes = Uint8List.fromList(utf8.encode(textToAppend));
    final combinedBytes = Uint8List(imageBytes.length + textBytes.length);
    combinedBytes.setAll(0, imageBytes);
    combinedBytes.setAll(imageBytes.length, textBytes);

    // Save image with combined bytes
    MediaService mediaService = MediaService();
    final directory = await mediaService.createFolderInRoot();
    final extension = paths.extension(imagePath);
    final filePath = paths.join(directory,
        '${DateTime.now().millisecondsSinceEpoch}_encrypted_image_with_text$extension');
    final encryptedFile = File(filePath);
    await encryptedFile.writeAsBytes(combinedBytes);

    return filePath;
  }

  static Future<String> decryptImageWithText({
    required String encryptedFilePath,
    required int textLength,
  }) async {
    String decryptedText = '';
    try {
      // Read combined file
      final file = File(encryptedFilePath);
      final combinedBytes = await file.readAsBytes();

      // Extract image bytes and text bytes
      // Assume text is appended at the end and its length is known or fixed // Example fixed length of text
      final imageBytes =
          combinedBytes.sublist(0, combinedBytes.length - textLength);
      final textBytes =
          combinedBytes.sublist(combinedBytes.length - textLength);

      // Decode the image and text
      final textToAppend = utf8.decode(textBytes);

      // Log the extracted text
      decryptedText = textToAppend;

      // Save the image as it is (optional)
      final directory = await getApplicationDocumentsDirectory();
      final extension = paths.extension(encryptedFilePath);
      final decryptedImagePath = paths.join(directory.path,
          '${DateTime.now().millisecondsSinceEpoch}_decrypted_image$extension');
      final decryptedImageFile = File(decryptedImagePath);
      await decryptedImageFile.writeAsBytes(imageBytes);

      print('Decrypted image path: ${decryptedImageFile.path}');
    } catch (e) {
      log("While decrypting$e");
    }
    return decryptedText;
  }
}

class EncryptionService {
  static Future<String> encryptImageWithText({
    required String imagePath,
    required String textToAppend,
  }) async {
    // Read image file bytes.
    final file = File(imagePath);
    final imageBytes = await file.readAsBytes();

    // Convert the text to bytes.
    final textBytes = Uint8List.fromList(utf8.encode(textToAppend));

    // Combine image bytes and text bytes.
    final combinedBytes = Uint8List(imageBytes.length + textBytes.length);
    combinedBytes.setAll(0, imageBytes);
    combinedBytes.setAll(imageBytes.length, textBytes);

    // Retrieve the encryption key and IV from local storage.
    final String? k = await Utils.getStringFromLocalStorage(key: Keys.key);
    final String? v = await Utils.getStringFromLocalStorage(key: Keys.vectore);

    // Check if the key and IV are not null.
    if (k == null || v == null) {
      throw Exception('Encryption key or IV not found in local storage.');
    }

    // Convert the key and IV from Base64.
    final encrypt.Key key = encrypt.Key.fromBase64(k);
    final encrypt.IV vector = encrypt.IV.fromBase64(v);

    // Create an encrypter with the AES algorithm in CBC mode.
    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

    // Encrypt the combined bytes.
    final encrypted = encrypter.encryptBytes(combinedBytes, iv: vector);

    // Create a new file in the specified directory to store the encrypted data.
    MediaService mediaService = MediaService();
    final directory = await mediaService.createFolderInRoot();
    final filePath = paths.join(directory,
        '${DateTime.now().millisecondsSinceEpoch}_encrypted_image_with_text.png');
    final encryptedFile = File(filePath);

    // Write the encrypted bytes to the new file.
    final nfile = await encryptedFile.writeAsBytes(encrypted.bytes);

    // Log the file path and check if the file exists.
    log('Encrypted file path: ${nfile.path}');
    log('Is Path Absolute: ${nfile.isAbsolute}');
    final fileExist = await nfile.exists();
    log('File Exists: $fileExist');

    // Return the Base64 encoded encrypted data.
    return encrypted.base64;
  }
}
