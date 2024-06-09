
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static final SharedPreferencesHelper _preferencesHelper =
  SharedPreferencesHelper._internal();

  SharedPreferencesHelper._internal();

  static SharedPreferencesHelper get instance {
    return _preferencesHelper;
  }

  Future<bool> salvar(String nameKey, String value) async {
    try {
      var prefs = await SharedPreferences.getInstance();
      return await prefs.setString(nameKey, value);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return false;
  }

  Future<String> carregar(String nameKey) async {
    var prefs = await SharedPreferences.getInstance();
    var response = prefs.getString(nameKey);
    return response ?? '';
  }

  Future<bool> salvarTema(String tema) async{
    return await salvar('tema', tema);
  }

  Future<String> carregarTema() async{
    return await carregar('tema');
  }
}