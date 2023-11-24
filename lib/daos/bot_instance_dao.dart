import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/bot_instance.dart';
import '../utils/logger.dart';

/// BotInstanceDaoLocalStorage類別
/// 
/// 用於儲存/讀取BotInstance
/// 
/// 方法:
/// 1. saveBotInstance: 儲存BotInstance清單到LocalStorage
/// 2. getBotInstance: 從LocalStorage取得BotInstance清單
/// 3. saveBotInstanceByUuid: 替換指定的UUID的BotInstance並儲存BotInstance到LocalStorage
class BotInstanceDaoLocalStorage {
  static SharedPreferences? _prefs;
  /// 設定SharedPreferences
  static Future<void> _setPrefClient() async {
    _prefs = await SharedPreferences.getInstance();
  }
  /// 儲存BotInstance清單到LocalStorage
  static Future<void> saveBotInstance(List<BotInstance> instances) async {
    await _setPrefClient();
    _prefs!.setString("instances", jsonEncode(instances.map((e) => e.toJson()).toList()));
  }

  /// 從LocalStorage取得BotInstance清單
  static Future<List<BotInstance>> getBotInstance() async {
    await _setPrefClient();
    List<BotInstance> instances = [];
    if(_prefs!.containsKey("instances"))
    {
      List<dynamic> jsonList = jsonDecode(_prefs!.getString("instances")!);
      logger.d(jsonList);
      instances = jsonList.map((e) => BotInstance.fromJson(e)).toList();
    }
    return instances;
  }
  /// 替換指定的UUID的BotInstance並儲存BotInstance到LocalStorage
  static Future<void> saveBotInstanceByUuid(String uuid,BotInstance instance) async {
    await _setPrefClient();
    List<BotInstance> instances = await getBotInstance();
    int index = instances.indexWhere((element) => element.uuid == uuid);
    if (index != -1) 
    {
      instances[index] = instance;
      await saveBotInstance(instances);
    }
    await saveBotInstance(instances);
  }
}