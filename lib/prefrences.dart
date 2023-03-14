import 'package:shared_preferences/shared_preferences.dart';

class Preferences{
  static String profile = 'profile';
  static String username = 'username';
  static String password = 'password';
  static String accessToken = 'accessToken';
  static String metaData = 'metaData';
  static String superLikeTime = 'superLikeTime';
  static String superLikeCount = 'superLikeCount';
  static String likeTime = 'likeTime';
  static String likeCount = 'likeCount';
  static String mediaData = 'mediaData';

}
String subscription = 'subscription';
getPrefStringValue() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(subscription);
}

setPrefStringValue(value) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString(subscription, value);
}

removeStringValue() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove(subscription);
}