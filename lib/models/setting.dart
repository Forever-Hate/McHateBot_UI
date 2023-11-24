import 'package:json_annotation/json_annotation.dart';

import '../models/bot_instance.dart';
part 'setting.g.dart';

abstract class Setting {
  factory Setting.fromJson(BotType type, Map<String, dynamic> json) {
    if(type == BotType.raid)
    {
      return RaidSetting.fromJson(json);
    }
    else
    {
      return EmeraldSetting.fromJson(json);
    }
  }

  Map<String, dynamic> toJson(BotType type) {
    if(type == BotType.raid)
    {
      return (this as RaidSetting).toJson(type);
    }
    else
    {
      return (this as EmeraldSetting).toJson(type);
    }
  }
}

@JsonSerializable()
class RaidSetting implements Setting {
  bool enable_detect_broadcast;
  bool enable_attack,enable_display_health;
  int interval_ticks,attack_radius;
  List<String> mob_list;
  bool enable_detect_interrupt;
  int check_raid_interval;
  bool enable_track,enable_track_log;
  int track_record;
  List<String> track_list;
  
  bool enable_discard,enable_discard_msg,enable_stay_totem,enable_auto_stack_totem,enable_totem_notifier;
  int discard_interval;
  List<String> stayItem_list;

  bool enable_exchange_logs;
  double no_item_exchange_interval,item_exchange_interval;

  bool enable_trade_announce,enable_trade_content_cycle;
  int trade_announce_interval,content_skip_count;
  List<List<String>> trade_content;

  bool enable_pay_log;
  int transfer_interval;

  bool enable_reply_msg,enable_auto_reply;
  String forward_ID;
  int clear_reply_id_interval;
  String auto_reply_week,auto_reply_time,auto_reply_content;

  bool enable_discord_bot,enable_send_msg_to_channel,directly_send_msg_to_dc,enable_slash_command;
  List<String> forward_DC_ID;
  String channel_ID;
  String embed_thumbnail_url,bot_application_ID,bot_token;
 
  RaidSetting({
    required this.enable_detect_broadcast,
    required this.enable_attack,
    required this.enable_display_health,
    required this.interval_ticks,
    required this.attack_radius,
    required this.mob_list,
    required this.enable_detect_interrupt,
    required this.check_raid_interval,
    required this.enable_track,
    required this.enable_track_log,
    required this.track_record,
    required this.track_list,
    required this.enable_discard,
    required this.enable_discard_msg,
    required this.enable_stay_totem,
    required this.enable_auto_stack_totem,
    required this.enable_totem_notifier,
    required this.discard_interval,
    required this.stayItem_list,
    required this.enable_exchange_logs,
    required this.no_item_exchange_interval,
    required this.item_exchange_interval,
    required this.enable_trade_announce,
    required this.enable_trade_content_cycle,
    required this.trade_announce_interval,
    required this.content_skip_count,
    required this.trade_content,
    required this.enable_pay_log,
    required this.transfer_interval,
    required this.enable_reply_msg,
    required this.enable_auto_reply,
    required this.forward_ID,
    required this.clear_reply_id_interval,
    required this.auto_reply_week,
    required this.auto_reply_time,
    required this.auto_reply_content,
    required this.enable_discord_bot,
    required this.enable_send_msg_to_channel,
    required this.directly_send_msg_to_dc,
    required this.enable_slash_command,
    required this.forward_DC_ID,
    required this.channel_ID,
    required this.embed_thumbnail_url,
    required this.bot_application_ID,
    required this.bot_token,
  });

  @override
  factory RaidSetting.fromJson(Map<String, dynamic> json) => _$RaidSettingFromJson(json);

  @override
  Map<String, dynamic> toJson(BotType type) => _$RaidSettingToJson(this);
}

@JsonSerializable()
class EmeraldSetting implements Setting {
  double store_emerald_interval;
  int store_emerald_check_times;
  bool enable_store_log,enable_auto_repair,enable_auto_send_store_report,enable_multiple_place_store,enable_afk_after_store;
  List<String> store_place,afk_place;

  bool enable_pay_log;
  int transfer_interval;

  bool enable_trade_announce,enable_trade_content_cycle;
  int trade_announce_interval,content_skip_count;
  List<List<String>> trade_content;


  bool enable_reply_msg,enable_auto_reply;
  String forward_ID;
  int clear_reply_id_interval;
  String auto_reply_week,auto_reply_time,auto_reply_content;

  bool enable_discord_bot,enable_send_msg_to_channel,directly_send_msg_to_dc,enable_slash_command;
  List<String> forward_DC_ID;
  String channel_ID;
  String embed_thumbnail_url,bot_application_ID,bot_token;
  
  EmeraldSetting({
    required this.store_emerald_interval,
    required this.store_emerald_check_times,
    required this.enable_store_log,
    required this.enable_auto_repair,
    required this.enable_auto_send_store_report,
    required this.enable_multiple_place_store,
    required this.enable_afk_after_store,
    required this.store_place,
    required this.afk_place,
    required this.enable_pay_log,
    required this.transfer_interval,
    required this.enable_trade_announce,
    required this.enable_trade_content_cycle,
    required this.trade_announce_interval,
    required this.content_skip_count,
    required this.trade_content,
    required this.enable_reply_msg,
    required this.enable_auto_reply,
    required this.forward_ID,
    required this.clear_reply_id_interval,
    required this.auto_reply_week,
    required this.auto_reply_time,
    required this.auto_reply_content,
    required this.enable_discord_bot,
    required this.enable_send_msg_to_channel,
    required this.directly_send_msg_to_dc,
    required this.enable_slash_command,
    required this.forward_DC_ID,
    required this.channel_ID,
    required this.embed_thumbnail_url,
    required this.bot_application_ID,
    required this.bot_token,
  });
  
  @override
  factory EmeraldSetting.fromJson(Map<String, dynamic> json) => _$EmeraldSettingFromJson(json);

  @override
  Map<String, dynamic> toJson(BotType type) => _$EmeraldSettingToJson(this);

}