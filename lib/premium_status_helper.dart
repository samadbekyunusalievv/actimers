import 'package:shared_preferences/shared_preferences.dart';

class PremiumStatusHelper {
  static const String _premiumStatusKey = 'premiumStatus';

  static Future<bool> getPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_premiumStatusKey) ?? false;
  }

  static Future<void> setPremiumStatus(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumStatusKey, status);
  }
}
