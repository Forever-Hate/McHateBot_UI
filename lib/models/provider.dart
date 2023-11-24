import 'package:flutter/material.dart';

import '../services/localization_service.dart';
import '../services/local_storage_service.dart';
import '../utils/logger.dart';

/// 語言類型
/// 
/// 1. zh_tw: 繁體中文
/// 2. en_us: 英文
enum LanguageType { 
  zh_tw,
  en_us
}
extension LanguageTypeExtension on LanguageType {
  String get value {
    switch (this) {
      case LanguageType.zh_tw:
        return "zh_tw";
      case LanguageType.en_us:
        return "en_us";
      default:
        return "zh_tw";
    }
  }
  static LanguageType fromValue(String value) {
    switch (value) {
      case "zh_tw":
        return LanguageType.zh_tw;
      case "en_us":
        return LanguageType.en_us;
      default:
        return LanguageType.zh_tw;
    }
  }
}

/// 語言切換(Provider)
class LanguageProvider extends ChangeNotifier {
  LanguageType _languageType = LanguageType.zh_tw;

  LanguageType get languageType => _languageType;

  /// 切換語言
  void toggleLanguage(LanguageType languageType) async {
    logger.i("進入toggleLanguage，切換語言");
    _languageType = languageType;
    LocalStorageService.saveLanguage(languageType);
    await LocalizationService.loadLanguageData(_languageType);
    notifyListeners();
  }
}

/// 主題類型
/// 
/// 1. dark: 黑夜模式
/// 2. light: 白天模式
/// 
enum ThemeType { 
  dark,
  light
}

/// 主題切換(Provider)
class ThemeProvider extends ChangeNotifier {
  ThemeType _themeType = ThemeType.dark;
  ThemeProvider() {
    loadThemeType();
  }

  ThemeType get themeType => _themeType;

  /// 切換主題
  void toggleTheme(ThemeType themeType) {
    _themeType = themeType;
    LocalStorageService.saveThemeType(themeType);
    notifyListeners();
  }

  /// 載入主題類型
  Future<void> loadThemeType() async {
    _themeType = await LocalStorageService.getThemeType();
    notifyListeners();
  }
}