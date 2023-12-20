import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/bot_instance.dart';
import '../models/setting.dart';
import '../utils/logger.dart';

/// SettingDao類別
/// 
/// 用於讀取/儲存Setting資料(Dao)
/// 
/// * 方法:
/// 1. getSetting: 讀取settings.json
/// 2. saveSetting: 儲存settings.json
class SettingDao{
  /// 讀取 Setting.json
  static Future<Setting> getSetting(BotType type,String uuid) async {
    logger.i("進入getSetting，讀取settings.json");
    final baseDir = await getApplicationCacheDirectory();
    final file = File(join(baseDir.path,"instance",uuid,"settings.json"));
    String jsonString = await file.readAsString();
    return Setting.fromJson(type, json.decode(jsonString));
  }
  /// 儲存 config.json
  static Future<void> saveSetting(BotType type,String uuid,Setting settings) async {
    logger.i("進入saveSetting，儲存settings.json");
    final baseDir = await getApplicationCacheDirectory();
    final file = File(join(baseDir.path,"instance",uuid,"settings.json"));
    await file.writeAsString(jsonEncode(settings.toJson(type)));
  }

}
