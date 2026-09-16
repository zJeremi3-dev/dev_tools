import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around [SharedPreferences] for all app persistence.
///
/// Every method here is a pure save/load pair with no business logic —
/// that lives in [ToolsController]. Malformed stored data is caught and
/// treated as "nothing saved" rather than crashing (see the `try/catch`
/// in each `load*` method).
class DatenManager {
  static const String keyFavoriteOrder = 'favorite_order';
  static const String keyNormalOrder = 'normal_order';
  static const String keyHideOrder = 'hide_order';
  static const String keyColorScheme = 'color_scheme';
  static const String keyModuleLayout = 'module_layout';

  static Future<void> saveFavoriteOrder(List<double> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyFavoriteOrder, json.encode(ids));
  }

  static Future<List<double>> loadFavoriteOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(keyFavoriteOrder);
    if (jsonString == null) return [];
    try {
      final jsonList = json.decode(jsonString) as List;
      return jsonList.map((e) => (e as num).toDouble()).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveNormalOrder(List<double> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyNormalOrder, json.encode(ids));
  }

  static Future<List<double>> loadNormalOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(keyNormalOrder);
    if (jsonString == null) return [];
    try {
      final jsonList = json.decode(jsonString) as List;
      return jsonList.map((e) => (e as num).toDouble()).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveHideOrder(List<double> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyHideOrder, json.encode(ids));
  }

  static Future<List<double>> loadHideOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(keyHideOrder);
    if (jsonString == null) return [];
    try {
      final jsonList = json.decode(jsonString) as List;
      return jsonList.map((e) => (e as num).toDouble()).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveColorScheme(int colorScheme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyColorScheme, colorScheme);
  }

  static Future<int> loadColorScheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyColorScheme) ?? 1;
  }

  static Future<void> saveModuleLayout(int type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyModuleLayout, type);
  }

  static Future<int> loadModuleLayout() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyModuleLayout) ?? 1;
  }
}
