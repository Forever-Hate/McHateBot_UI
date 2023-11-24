
import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/inventory_item.dart';

class InventoryItemDao {
  ///取得所有物品
  static Future<Map<String,InventoryItem>> getAllInventoryItems() async {
    Map<String,InventoryItem> items = {};
    //如果要讀取assets資料夾的檔案，要用rootBundle(未來會改成從網路(github)取得)
    String data = await rootBundle.loadString('assets/mc-icons/texture_content.json');
    final List<dynamic> jsonData = jsonDecode(data);
    for (var item in jsonData) {
      items[item['name']] = InventoryItem.fromJson(item);
    }
    return items;
  }
}