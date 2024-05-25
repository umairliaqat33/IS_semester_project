import 'dart:convert';
import 'dart:developer';

class SecondAlgorithm {
  String encrypt(
    String message,
    String key,
  ) {
    List<int> keyToUTF = utf8.encode(key);
    List<int> messageToUTF = utf8.encode(key);

    // multiply all elements of message list with key list and generate another list
    List<int> additionList = [];
    for (int i = 0; i < keyToUTF.length; i++) {
      additionList.add(keyToUTF[i] + messageToUTF[i]);
    }

    List<int> modulusList = [];
    for (int i = 0; i < keyToUTF.length; i++) {
      modulusList.add(additionList[i] % 256);
    }

    String encryptedText = base64.encode(modulusList);
    return encryptedText;
  }

  String decrypt(String encryptedText, String key) {
    List<int> modulusList = base64.decode(encryptedText);

    List<int> keyToUTF = utf8.encode(key);

    // while (keyToUTF.length < modulusList.length) {
    //   keyToUTF += keyToUTF;
    // }
    // keyToUTF = keyToUTF.sublist(0, modulusList.length);

    List<int> decryptedList = [];
    for (int i = 0; i < modulusList.length; i++) {
      decryptedList.add(modulusList[i] ~/ keyToUTF[i]);
    }
    List<int> subtractedList = [];
    for (int i = 0; i < modulusList.length; i++) {
      subtractedList.add(modulusList[i] - keyToUTF[i]);
    }

    String decryptedText = utf8.decode(decryptedList);
    log(decryptedText);
    return decryptedText.toString();
  }
}
