
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mchatebot_ui/models/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/logger.dart';

/// LocalStorageService
/// 
/// 用於儲存LocalStorage資料(Global) 
/// 
/// * 方法:
/// 
///1. getLanguage: 從LocalStorage取得LanguageType
///2. saveLanguage: 儲存LanguageType到LocalStorage
///3. getMessageFilter: 從LocalStorage取得messageFilters清單
///4. saveMessageFilter: 儲存messageFilters清單到LocalStorage
///5. getMessageAutoScroll: 從LocalStorage取得isAutoScroll
///6. saveMessageAutoScroll: 儲存isAutoScroll到LocalStorage
///13. getThemeType: 從LocalStorage取得ThemeType
///14. saveThemeType: 儲存ThemeType到LocalStorage
class LocalStorageService {

  /// SharedPreferences實例
  static SharedPreferences? _prefs;
  static List<String> keptKeys = ["instances"];
  
  /// 設定SharedPreferences
  static Future<void> _setPrefClient() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  /// 從LocalStorage取得LanguageType
  static Future<LanguageType> getLanguage() async {
    await _setPrefClient();
    return _prefs!.getInt("language") != null ? LanguageType.values[_prefs!.getInt("language")!] : LanguageTypeExtension.fromValue(dotenv.env['LANGUAGE']!);
  }

  /// 儲存LanguageType到LocalStorage
  static Future<void> saveLanguage(LanguageType languageType) async {
    await _setPrefClient();
    _prefs!.setInt("language", languageType.index);
  }

  /// 儲存messageFilters清單到LocalStorage
  static Future<void> saveMessageFilter(List<bool> filters) async {
    logger.i("進入saveMessageFilter，儲存messageFilters清單");
    await _setPrefClient();
    _prefs!.setString("messageFilters", jsonEncode(filters));
  }

  /// 從LocalStorage取得messageFilters清單
  static Future<List<bool>> getMessageFilter() async {
    logger.i("進入getMessageFilter，取得messageFilters清單");
    await _setPrefClient();
    List<bool> filters = [];
    if(_prefs!.containsKey("messageFilters"))
    {
      List<dynamic> jsonList = jsonDecode(_prefs!.getString("messageFilters")!);
      logger.d(jsonList);
      filters = jsonList.map((e) => e as bool).toList();
    }
    return filters;
  }

  /// 儲存isAutoScroll到LocalStorage
  static Future<void> saveMessageAutoScroll(bool isAutoScroll) async {
    logger.i("進入saveMessageAutoScroll，儲存isAutoScroll");
    await _setPrefClient();
    _prefs!.setBool("isAutoScroll", isAutoScroll);
  }

  /// 從LocalStorage取得isAutoScroll
  static Future<bool> getMessageAutoScroll() async {
    logger.i("進入getMessageAutoScroll，取得isAutoScroll");
    await _setPrefClient();
    return _prefs!.getBool("isAutoScroll") ?? false;
  }
  
  /// 從LocalStorage取得ThemeType
  static Future<ThemeType> getThemeType() async {
    logger.i("進入getThemeType，取得ThemeType");
    await _setPrefClient();
    return ThemeType.values[_prefs!.getInt("themeType") ?? 0];
  }

  /// 儲存ThemeType到LocalStorage
  static Future<void> saveThemeType(ThemeType themeType) async {
    logger.i("進入saveThemeType，儲存ThemeType");
    await _setPrefClient();
    _prefs!.setInt("themeType", themeType.index);
  }

  /// 從LocalStorage取得isShowWelcomeScreen
  static Future<bool> getIsShowWelcomeScreen() async {
    logger.i("進入getIsShowWelcomeScreen，取得isShowWelcomeScreen");
    await _setPrefClient();
    return _prefs!.getBool("isShowWelcomeScreen") ?? true;
  }

  /// 儲存isShowWelcomeScreen到LocalStorage
  static Future<void> saveIsShowWelcomeScreen(bool isShowWelcomeScreen) async {
    logger.i("進入saveIsShowWelcomeScreen，儲存isShowWelcomeScreen");
    await _setPrefClient();
    _prefs!.setBool("isShowWelcomeScreen", isShowWelcomeScreen);
  }

  /// 從LocalStorage移除指定key以外的資料
  static Future<void> clearCacheExceptSomeKeyFromLocalStorage() async {
    logger.i("進入clearCacheExceptSomeKeyFromLocalStorage，移除指定key以外的資料");
    await _setPrefClient();
    List<String> keys = _prefs!.getKeys().toList();
    for(String key in keys)
    {
      if(!keptKeys.contains(key))
      {
        _prefs!.remove(key);
      }
    }
  }
}