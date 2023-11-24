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
/// 3. getEmeraldSettingFromLocalStorage: 從LocalStorage取得emeraldSetting
/// 4. saveEmeraldSettingToLocalStorage: 儲存emeraldSetting到LocalStorage
/// 5. getRaidSettingFromLocalStorage: 從LocalStorage取得RaidSetting
/// 6. saveRaidSettingToLocalStorage: 儲存RaidSetting到LocalStorage
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
  /// 從LocalStorage取得emeraldSetting
  static Future<EmeraldSetting?> getEmeraldSettingFromLocalStorage() async {
    logger.i("進入getEmeraldSetting，取得emeraldSetting(From LocalStorage)");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    EmeraldSetting emeraldSetting;
    if(prefs.containsKey("emeraldSetting"))
    {
      try 
      {
        emeraldSetting = EmeraldSetting.fromJson(jsonDecode(prefs.getString("emeraldSetting")!));
        return emeraldSetting;
      } 
      catch (e) 
      {
        logger.e(e);
      }
    }
    return null;
  }
  /// 儲存emeraldSetting到LocalStorage
  static Future<void> saveEmeraldSettingToLocalStorage(EmeraldSetting emeraldSetting) async {
    logger.i("進入saveEmeraldSetting，儲存emeraldSetting到LocalStorage");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("emeraldSetting", jsonEncode(emeraldSetting.toJson(BotType.emerald)));
  }
  /// 從LocalStorage取得RaidSetting
  static Future<RaidSetting?> getRaidSettingFromLocalStorage() async {
    logger.i("進入getRaidSetting，取得RaidSetting");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    RaidSetting raidSetting;
    if(prefs.containsKey("raidSetting"))
    {
      try 
      {
        raidSetting = RaidSetting.fromJson(jsonDecode(prefs.getString("raidSetting")!));
        return raidSetting;
      } 
      catch (e) 
      {
        logger.e(e);
      }
    }
    return null;
  }
  /// 儲存RaidSetting到LocalStorage
  static Future<void> saveRaidSettingToLocalStorage(RaidSetting raidSetting) async {
    logger.i("進入saveRaidSetting，儲存RaidSetting");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("raidSetting", jsonEncode(raidSetting.toJson(BotType.raid)));
  }
}
