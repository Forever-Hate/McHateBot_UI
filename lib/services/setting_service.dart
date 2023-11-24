
import '../daos/setting_dao.dart';
import '../models/bot_instance.dart';
import '../models/setting.dart';

/// SettingService
/// 
/// 用於儲存/讀取Setting資料(Service)
/// 
/// * 方法:
/// 1. getSetting: 讀取settings.json
/// 2. saveSetting: 儲存settings.json
/// 3. getEmeraldSettingFromLocalStorage: 從LocalStorage取得emeraldSetting
/// 4. saveEmeraldSettingToLocalStorage: 儲存emeraldSetting到LocalStorage
/// 5. getRaidSettingFromLocalStorage: 從LocalStorage取得RaidSetting
/// 6. saveRaidSettingToLocalStorage: 儲存RaidSetting到LocalStorage
class SettingService {
  /// 讀取 settings.json
  static Future<Setting> getSetting(BotType type,String uuid) async {
    return await SettingDao.getSetting(type,uuid);
  }

  /// 儲存 settings.json
  static Future<void> saveSetting(BotType type,String uuid,Setting setting) async {
    await SettingDao.saveSetting(type,uuid,setting);
  }

  /// 從LocalStorage取得emeraldSetting
  static Future<EmeraldSetting?> getEmeraldSettingFromLocalStorage() async {
    return await SettingDao.getEmeraldSettingFromLocalStorage();
  }

  /// 儲存emeraldSetting到LocalStorage
  static Future<void> saveEmeraldSettingToLocalStorage(EmeraldSetting emeraldSetting) async {
    await SettingDao.saveEmeraldSettingToLocalStorage(emeraldSetting);
  }

  /// 從LocalStorage取得RaidSetting
  static Future<RaidSetting?> getRaidSettingFromLocalStorage() async {
    return await SettingDao.getRaidSettingFromLocalStorage();
  }

  /// 儲存RaidSetting到LocalStorage
  static Future<void> saveRaidSettingToLocalStorage(RaidSetting raidSetting) async {
    await SettingDao.saveRaidSettingToLocalStorage(raidSetting);
  }
}