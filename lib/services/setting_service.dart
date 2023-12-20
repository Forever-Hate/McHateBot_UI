
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
class SettingService {
  /// 讀取 settings.json
  static Future<Setting> getSetting(BotType type,String uuid) async {
    return await SettingDao.getSetting(type,uuid);
  }

  /// 儲存 settings.json
  static Future<void> saveSetting(BotType type,String uuid,Setting setting) async {
    await SettingDao.saveSetting(type,uuid,setting);
  }

}