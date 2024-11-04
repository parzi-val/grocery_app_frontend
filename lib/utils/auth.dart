import 'package:shared_preferences/shared_preferences.dart';

class Auth {
  static Future<String?> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userToken = prefs.getString('jwt');
    return userToken;
  }
}
