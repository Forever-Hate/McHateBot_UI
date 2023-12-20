import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';

/// * 存取 BotInstance 的物件
///
/// * 屬性：
/// 1. uuid: 實例唯一ID，required [String]
/// 2. type: 實例類型，required [BotType]
/// 3. version: 實例版本，required [String]
/// 4. botUuid: Bot唯一ID，optional [String]
/// 5. username: Bot使用者名稱，optional [String]
/// 6. isProcess: 是否正在執行，optional [bool]
/// 7. hasConfigured: 是否已設定，optional [bool]
/// 8. hasFinishSetting: 是否已完成設定，optional [bool]
/// 9. autoStart: 是否自動啟動，optional [bool]
/// 10. process: 實例的Process，optional [Process]
/// 11. stderrStream: 實例的stderrStream，optional [Stream]
/// 12. stdoutStream: 實例的stdoutStream，optional [Stream]
/// 13. expressPort: 實例的expressPort，optional [int]
/// 14. websocketPort: 實例的websocketPort，optional [int]
/// 15. timer: 實例的計時器，optional [Timer]
/// 16. duration: 實例的執行時間，optional [int]
/// 17. messageQueue: 實例的std訊息佇列，optional [ValueNotifier<Queue<String>>]
/// 
/// * 方法：
/// 1. toJson: 將 BotInstance 物件轉換為 JSON Map
/// 2. fromJson: 從 JSON Map 讀取並轉換為 BotInstance 物件
/// 3. copyWith: 複製BotInstance
class BotInstance {
  String uuid;
  BotType type;
  String version;
  String botUuid;
  String username;
  bool isProcess;
  bool hasConfigured;
  bool hasFinishSetting;
  bool autoStart;
  Process? process;
  Stream? stderrStream;
  Stream? stdoutStream;
  int? expressPort;
  int? websocketPort;
  Timer? timer;
  int duration = 0;
  ValueNotifier<Queue<String>> messageQueue = ValueNotifier(Queue());

  BotInstance(this.uuid, this.type, this.version,
      {this.botUuid = "",this.username = "" ,this.isProcess = false,this.hasConfigured = false, this.hasFinishSetting = false,this.autoStart = false});

  /// 將 BotInstance 物件轉換為 JSON Map
  Map<String, dynamic> toJson() {
    return {
      "uuid": uuid,
      "type": type.value,
      "version": version,
      "botUuid": botUuid,
      "username": username,
      "hasConfigured": hasConfigured,
      "hasFinishSetting": hasFinishSetting,
      "autoStart": autoStart,
    };
  }

  /// 從 JSON Map 讀取並轉換為 BotInstance 物件
  factory BotInstance.fromJson(Map<String, dynamic> json) {
    return BotInstance(
      json["uuid"],
      BotTypeExtension.fromValue(json["type"]),
      json["version"],
      botUuid: json["botUuid"],
      username: json["username"],
      hasConfigured: json["hasConfigured"],
      hasFinishSetting: json["hasFinishSetting"],
      autoStart: json["autoStart"] ?? false,
    );
  }
  /// 複製BotInstance
  BotInstance copyWith({
    String? uuid,
    BotType? type,
    String? version,
    String? botUuid,
    String? username,
    bool? isProcess,
    bool? hasConfigured,
    bool? hasFinishSetting,
    bool? autoStart,
  }) {
    return BotInstance(
      uuid ?? this.uuid,
      type ?? this.type,
      version ?? this.version,
      botUuid: botUuid ?? this.botUuid,
      username: username ?? this.username,
      isProcess: isProcess ?? this.isProcess,
      hasConfigured: hasConfigured ?? this.hasConfigured,
      hasFinishSetting: hasFinishSetting ?? this.hasFinishSetting,
      autoStart: autoStart ?? this.autoStart,
    );
  }
}

/// 實例類型
enum BotType
{
  raid,
  emerald
}
extension BotTypeExtension on BotType {
  String get value {
    switch (this) {
      case BotType.raid:
        return "McHateBot_raid";
      case BotType.emerald:
        return "McHateBot_emerald";
    }
  }
  static BotType fromValue(String value) {
    switch (value) {
      case "McHateBot_raid":
        return BotType.raid;
      case "McHateBot_emerald":
        return BotType.emerald;
      default:
        throw ArgumentError("Invalid value: $value");
    }
  }
}