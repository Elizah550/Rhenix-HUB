import 'package:shared_preferences/shared_preferences.dart';

class LoginPreferences {
  static Future<void> saveCredentials(String phone) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('phone', phone);
    // await prefs.setString('code', code);
  }

  static Future<Map<String, String?>> getCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'phone': prefs.getString('phone'),
      // 'code': prefs.getString('code'),
    };
  }
}
