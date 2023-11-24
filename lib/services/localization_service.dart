
import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/provider.dart';
import '../utils/logger.dart';

/// LocalizationService
/// 
/// 用於讀取語言檔(Service)
/// 
/// * 方法:
/// 1. getLocalizedString: 取得指定key的字串
/// 2. loadLanguageData: 讀取語言檔
class LocalizationService
{
  static Map<String,dynamic> _languageData = {};

  ///取的指定key的字串
  static String getLocalizedString(String key) {
    return _languageData[key] ?? "{$key} is not found";
  }

  ///讀取語言檔
  ///
  ///如果暫存裡面有紀錄的話，就會讀取暫存的
  ///否則就讀取.env檔案的
  static Future<void> loadLanguageData(LanguageType type) async 
  {
    logger.i("進入loadLanguageData，讀取語言檔");
    //如果要讀取assets資料夾的檔案，要用rootBundle
    String jsonContent = await rootBundle.loadString('assets/languages/${type.value}.json');
    _languageData = json.decode(jsonContent);
    logger.d(_languageData);
  }
}