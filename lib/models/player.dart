import '../services/localization_service.dart';

/// Player 玩家資料
/// 
/// * 屬性
/// 1. ip: 連線ip，required [String]
/// 2. version: 遊戲版本，required [String]
/// 3. username: 玩家名稱，required [String]
/// 4. uuid: 玩家uuid，required [String]
/// 5. money: 遊戲幣，optional [String]
/// 6. coin: 遊戲幣(儲值)，optional [String]
/// 7. server: 當前分流，optional [int]
/// 8. currentPlayers: 當前分流人數，optional [int]
/// 9. targetedBlock: 玩家目標方塊，optional [Block]
/// 10. position: 玩家位置，required [Position]
/// 11. health: 玩家血量，required [int]
/// 12. food: 玩家飢餓值，required [int]
/// 13. level: 玩家等級，required [int]
/// 14. points: 玩家經驗值，required [int]
/// 15. progress: 玩家經驗值進度，required [double]
/// 16. items: 玩家物品欄，required [List<Item>]
/// 
/// * 方法
/// 1. toJsonString: 把物件直接轉換為 json string
/// 2. fromJson: 讀取 json map 並轉換成 Player 的建構子
class Player {
  final String ip;
  final String version;
  final String username;
  final String uuid;
  final String? money;
  final String? coin;
  final int? server;
  final int? currentPlayers;
  final Block? targetedBlock;
  final Position position;
  final int health;
  final int food;
  final int level;
  final int points;
  final double progress;
  final List<Item> items;

  Player({
    required this.ip,
    required this.version,
    required this.username,
    required this.uuid,
    this.money,
    this.coin,
    this.server,
    this.currentPlayers,
    this.targetedBlock,
    required this.position,
    required this.health,
    required this.food,
    required this.level,
    required this.points,
    required this.progress,
    required this.items,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      ip: json['ip'] as String,
      version: json['version'] as String,
      username: json['username'] as String,
      uuid: json['uuid'] as String,
      money: json['money'] as String?,
      coin: json['coin'] as String?,
      server: json['server'] as int?,
      currentPlayers: json['currentPlayers'] as int?,
      targetedBlock: json['targetedBlock'] != null
        ? Block.fromJson(json['targetedBlock'] as Map<String, dynamic>)
        : null,
      position: Position.fromJson(json['position'] as Map<String, dynamic>),
      health: (json['health'] as num).toInt(),
      food: json['food'] as int,
      level: json['level'] as int,
      points: json['points'] as int,
      progress: (json['progress'] as num).toDouble(),
      items: (json['items'] as List<dynamic>).map((item) => Item.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }

  @override
  String toString() {
    return 'Player(\n'
      '  ip: $ip,\n'
      '  version: $version,\n'
      '  username: $username,\n'
      '  uuid: $uuid,\n'
      '  money: $money,\n'
      '  coin: $coin,\n'
      '  server: $server,\n'
      '  currentPlayers: $currentPlayers,\n'
      '  targetedBlock: $targetedBlock,\n'
      '  position: $position,\n'
      '  health: $health,\n'
      '  food: $food,\n'
      '  level: $level,\n'
      '  points: $points,\n'
      '  progress: $progress,\n'
      '  items: $items,\n'
      ')';
  }
}

/// Block 方塊資料
/// 
/// * 屬性
/// 1. type: 方塊類型，required [int]
/// 2. name: 方塊名稱，required [String]
/// 3. position: 方塊位置，required [Position]
/// 
/// * 方法
/// 1. fromJson: 讀取 json map 並轉換成 Block 的建構子
/// 2. toString: 把物件轉換為字串
class Block{
  final int type;
  final String name;
  final Position position;

  Block({
    required this.type,
    required this.name,
    required this.position,
  });

  factory Block.fromJson(Map<String, dynamic> json) {
    return Block(
      type: json['type'] as int,
      name: json['name'] as String,
      position: Position.fromJson(json['position'] as Map<String, dynamic>),
    );
  }

  @override
  String toString() {
    return LocalizationService.getLocalizedString('toStringBlock').replaceFirst('%name%', name).replaceFirst('%position%', position.toString());
  }
}

/// Position 位置資料
/// 
/// * 屬性
/// 1. x: x座標，required [double]
/// 2. y: y座標，required [double]
/// 3. z: z座標，required [double]
/// 
/// * 方法
/// 1. fromJson: 讀取 json map 並轉換成 Position 的建構子
/// 2. toString: 把物件轉換為字串
class Position {
  final double x;
  final double y;
  final double z;

  Position({
    required this.x,
    required this.y,
    required this.z,
  });

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      x: double.parse((json['x'] as num).toStringAsFixed(2)),
      y: double.parse((json['y'] as num).toStringAsFixed(2)),
      z: double.parse((json['z'] as num).toStringAsFixed(2)),
    );
  }
  @override
  String toString() {
    return LocalizationService.getLocalizedString("toStringPosition").replaceFirst('%x%', x.toString()).replaceFirst('%y%', y.toString()).replaceFirst('%z%', z.toString());
  }
}

/// Item 物品資料
/// 
/// * 屬性
/// 1. type: 物品類型，required [int]
/// 2. count: 物品數量，required [int]
/// 3. metadata: 物品metadata，required [int]
/// 4. nbt: 物品nbt，required [dynamic]
/// 5. stackId: 物品stackId，required [int]
/// 6. name: 物品名稱，required [String]
/// 7. displayName: 物品顯示名稱，required [String]
/// 8. stackSize: 物品堆疊大小，required [int]
/// 9. slot: 物品欄位，required [int]
/// 
/// * 方法
/// 1. fromJson: 讀取 json map 並轉換成 Item 的建構子
class Item{
  final int type;
  final int count;
  final int metadata;
  final dynamic nbt;
  final int? stackId;
  final String name;
  final String displayName;
  final int stackSize;
  final int slot;

  Item({
    required this.type,
    required this.count,
    required this.metadata,
    required this.nbt,
    required this.stackId,
    required this.name,
    required this.displayName,
    required this.stackSize,
    required this.slot,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      type: json['type'] as int,
      count: json['count'] as int,
      metadata: json['metadata'] as int,
      nbt: json['nbt'] as dynamic,
      stackId: json['stackId'] as int?,
      name: json['name'] as String,
      displayName: json['displayName'] as String,
      stackSize: json['stackSize'] as int,
      slot: json['slot'] as int,
    );
  }
}