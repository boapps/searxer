import 'package:fluttertoast/generated/i18n.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  Future<SharedPreferences> get prefs async =>
      await SharedPreferences.getInstance();

  void setAutoComplete(bool data) async {
    await (await prefs).setBool("auto_complete", data);
  }

  Future<bool> getAutoComplete() async {
    return (await prefs).getBool("auto_complete") ?? false;
  }

  void setURL(String data) async {
    await (await prefs).setString("url", data);
  }

  Future<String> getURL() async {
    return (await prefs).getString("url") ?? "https://searx.site";
  }

  void setEngine(String engine, String category, bool enabled) async {
    await (await prefs).setBool(category + "_" + engine, enabled);
  }

  Future<bool> getEngine(String engine, String category) async {
    return (await prefs).getBool(category + "_" + engine);
  }
}
