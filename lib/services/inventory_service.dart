import 'dart:convert';
import 'dart:typed_data';


import '../daos/inventory_item_dao.dart';
import '../models/inventory_item.dart';
import '../utils/logger.dart';

/// InventoryService類別
/// 
/// 用於讀取/儲存Inventory資料(Service)
/// 
/// * 方法:
/// 1. init: 初始化物品清單
/// 2. getInventory: 從Asset取得物品清單
/// 3. getTextureFromName: 從物品名稱取得物品圖片
class InventoryService {
  
  // 物品清單
  static Map<String,InventoryItem> items = {};

  /// 初始化物品清單
  static Future<void> init() async {
    logger.i("進入init，初始化物品清單");
    if(items.isEmpty)
    {
      items = await getInventory();
    }
  }

  /// 從Asset取得物品清單
  static Future<Map<String,InventoryItem>> getInventory() async {
    return await InventoryItemDao.getAllInventoryItems();
  }

  /// 從物品名稱取得物品圖片
  static Uint8List? getTextureFromName(String name) {
    if(items.containsKey(name))
    {
      if(items[name]!.texture != null)
      {
        String base64String = items[name]!.texture!.substring(items[name]!.texture!.indexOf(',') + 1);
        return Uint8List.fromList(base64Decode(base64String));
      }
      else
      {
        return null;
      }
    }
    else
    {
      return null;
    }
  }
}