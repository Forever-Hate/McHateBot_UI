import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/config.dart';
import '../utils/logger.dart';

/// ConfigDao
/// 
/// 用於讀取/儲存config.json(Dao)
/// 
/// * 方法:
/// 1. getConfig: 讀取config.json
/// 2. saveConfig: 儲存config.json
/// 3. getConfigFromLocalStorage: 從LocalStorage取得config
/// 4. saveConfigToLocalStorage: 儲存config到LocalStorage
class ConfigDao {
  /// 讀取 config.json
  static Future<Config> getConfig(String uuid) async {
    logger.i("進入getConfig，讀取config.json");
    final baseDir = await getApplicationCacheDirectory();
    final file = File(join(baseDir.path,"instance",uuid,"config.json"));
    String jsonString = await file.readAsString();
    return Config.fromJson(jsonDecode(jsonString));
  }
  /// 儲存 config.json
  static Future<void> saveConfig(String uuid,Config config) async {
    logger.i("進入saveConfig，儲存config.json");
    final baseDir = await getApplicationCacheDirectory();
    final file = File(join(baseDir.path,"instance",uuid,"config.json"));
    await file.writeAsString(config.toJsonString());
  }
  /// 從LocalStorage取得config
  static Future<Config?> getConfigFromLocalStorage() async {
    logger.i("進入getConfig，取得config");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Config config;
    if(prefs.containsKey("config"))
    {
      try 
      {
        logger.d(prefs.getString("config")!);
        config = Config.fromJson(jsonDecode(prefs.getString("config")!));
        return config;
      } 
      catch (e) 
      {
        logger.e(e);
      }
    }
    return null;
  }
  /// 儲存config到LocalStorage
  static Future<void> saveConfigToLocalStorage(Config config) async {
    logger.i("進入saveConfig，儲存config");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("config", config.toJsonString());
  }
}