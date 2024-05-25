import 'package:shared_preferences/shared_preferences.dart';

class Utils {
  // Function to save a string to local storage
  static Future<void> saveStringToLocalStorage({
    required String key,
    required String value,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

// Function to retrieve a string from local storage
  static Future<String?> getStringFromLocalStorage({
    required String key,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }
}
