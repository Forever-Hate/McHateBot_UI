import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../daos/config_dao.dart';
import '../models/config.dart';
import '../utils/logger.dart';

/// ConfigService
/// 
/// 用於讀取/儲存config.json(Service)
/// 
/// * 方法:
/// 1. getConfig: 讀取config.json
/// 2. saveConfig: 儲存config.json
/// 3. getEnv: 取得.env環境變數
/// 4. saveEnv: 儲存.env環境變數
/// 5. modifyEnv: 修改.env環境變數
/// 6. getConfigFromLocalStorage: 從LocalStorage取得config
/// 7. saveConfigToLocalStorage: 儲存config到LocalStorage
class ConfigService{

  /// 取得config
  static Future<Config> getConfig(String uuid) async {
    logger.i("進入getConfig，讀取config.json");
    return await ConfigDao.getConfig(uuid);
  }

  /// 儲存config
  static Future<void> saveConfig(String uuid,Config config) async {
    logger.i("進入saveConfig，儲存config.json");
    await ConfigDao.saveConfig(uuid,config);
  }

  /// 取得.env環境變數
  static Future<List<String>> getEnv(String uuid) async {
    logger.i("進入getEnv，讀取.env");
    final baseDir = await getApplicationCacheDirectory();
    final file = File(join(baseDir.path,'instance',uuid,'.env'));
    final lines = await file.readAsLines();
    return lines;
  }

  /// 儲存.env環境變數
  static Future<void> saveEnv(List<String> data,String uuid) async {
    logger.i("進入saveEnv，儲存.env");
    final baseDir = await getApplicationCacheDirectory();
    final file = File(join(baseDir.path,"instance",uuid,".env"));
    await file.writeAsString(data.join('\n'));
  }

  /// 修改.env環境變數
  static void modifyEnv(List<String> data,String key,dynamic value)
  {
    logger.i("進入modifyEnv，修改.env");
    final index = data.indexWhere((element) => element.startsWith(key));
    if (index != -1) 
    {
      data[index] = '$key = $value';
    } 
    else 
    {
      data.add('$key = $value');
    }
  }

  /// 從localStorage取得config
  static Future<Config?> getConfigFromLocalStorage() async {
    logger.i("進入getConfigFromLocalStorage，取得config");
    return await ConfigDao.getConfigFromLocalStorage();

  }

  /// 儲存config到localStorage
  static Future<void> saveConfigToLocalStorage(Config config) async {
    logger.i("進入saveConfigToLocalStorage，儲存config");
    await ConfigDao.saveConfigToLocalStorage(config);
  }
}