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

}