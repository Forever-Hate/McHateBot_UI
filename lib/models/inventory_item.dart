/// 背包物品
/// 
/// * 屬性
/// 1. name: required [String]
/// 2. path: optional [String]
/// 3. texture: optional [String]
/// 
/// * 方法
/// 1. fromJson: 從 JSON Map 讀取並轉換為 Item 物件
class InventoryItem{
  String name;
  String? path;
  String? texture;

  InventoryItem({
    required this.name,
    this.path,
    this.texture,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      name: json['name'] as String,
      path: json['path'] as String?,
      texture: json['texture'] as String?,
    );
  }
}