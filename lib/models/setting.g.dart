// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RaidSetting _$RaidSettingFromJson(Map<String, dynamic> json) => RaidSetting(
      enable_detect_broadcast: json['enable_detect_broadcast'] as bool,
      enable_attack: json['enable_attack'] as bool,
      enable_display_health: json['enable_display_health'] as bool,
      interval_ticks: json['interval_ticks'] as int,
      attack_radius: json['attack_radius'] as int,
      mob_list:
          (json['mob_list'] as List<dynamic>).map((e) => e as String).toList(),
      enable_detect_interrupt: json['enable_detect_interrupt'] as bool,
      check_raid_interval: json['check_raid_interval'] as int,
      enable_track: json['enable_track'] as bool,
      enable_track_log: json['enable_track_log'] as bool,
      track_record: json['track_record'] as int,
      track_list: (json['track_list'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      enable_discard: json['enable_discard'] as bool,
      enable_discard_msg: json['enable_discard_msg'] as bool,
      enable_stay_totem: json['enable_stay_totem'] as bool,
      enable_auto_stack_totem: json['enable_auto_stack_totem'] as bool,
      enable_totem_notifier: json['enable_totem_notifier'] as bool,
      discard_interval: json['discard_interval'] as int,
      stayItem_list: (json['stayItem_list'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      enable_exchange_logs: json['enable_exchange_logs'] as bool,
      no_item_exchange_interval:
          (json['no_item_exchange_interval'] as num).toDouble(),
      item_exchange_interval:
          (json['item_exchange_interval'] as num).toDouble(),
      enable_trade_announce: json['enable_trade_announce'] as bool,
      enable_trade_content_cycle: json['enable_trade_content_cycle'] as bool,
      trade_announce_interval: json['trade_announce_interval'] as int,
      content_skip_count: json['content_skip_count'] as int,
      trade_content: (json['trade_content'] as List<dynamic>)
          .map((e) => (e as List<dynamic>).map((e) => e as String).toList())
          .toList(),
      enable_pay_log: json['enable_pay_log'] as bool,
      transfer_interval: json['transfer_interval'] as int,
      enable_reply_msg: json['enable_reply_msg'] as bool,
      enable_auto_reply: json['enable_auto_reply'] as bool,
      forward_ID: json['forward_ID'] as String,
      clear_reply_id_interval: json['clear_reply_id_interval'] as int,
      auto_reply_week: json['auto_reply_week'] as String,
      auto_reply_time: json['auto_reply_time'] as String,
      auto_reply_content: json['auto_reply_content'] as String,
      enable_discord_bot: json['enable_discord_bot'] as bool,
      enable_send_msg_to_channel: json['enable_send_msg_to_channel'] as bool,
      directly_send_msg_to_dc: json['directly_send_msg_to_dc'] as bool,
      enable_slash_command: json['enable_slash_command'] as bool,
      forward_DC_ID: (json['forward_DC_ID'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      channel_ID: json['channel_ID'] as String,
      embed_thumbnail_url: json['embed_thumbnail_url'] as String,
      bot_application_ID: json['bot_application_ID'] as String,
      bot_token: json['bot_token'] as String,
    );

Map<String, dynamic> _$RaidSettingToJson(RaidSetting instance) =>
    <String, dynamic>{
      'enable_detect_broadcast': instance.enable_detect_broadcast,
      'enable_attack': instance.enable_attack,
      'enable_display_health': instance.enable_display_health,
      'interval_ticks': instance.interval_ticks,
      'attack_radius': instance.attack_radius,
      'mob_list': instance.mob_list,
      'enable_detect_interrupt': instance.enable_detect_interrupt,
      'check_raid_interval': instance.check_raid_interval,
      'enable_track': instance.enable_track,
      'enable_track_log': instance.enable_track_log,
      'track_record': instance.track_record,
      'track_list': instance.track_list,
      'enable_discard': instance.enable_discard,
      'enable_discard_msg': instance.enable_discard_msg,
      'enable_stay_totem': instance.enable_stay_totem,
      'enable_auto_stack_totem': instance.enable_auto_stack_totem,
      'enable_totem_notifier': instance.enable_totem_notifier,
      'discard_interval': instance.discard_interval,
      'stayItem_list': instance.stayItem_list,
      'enable_exchange_logs': instance.enable_exchange_logs,
      'no_item_exchange_interval': instance.no_item_exchange_interval,
      'item_exchange_interval': instance.item_exchange_interval,
      'enable_trade_announce': instance.enable_trade_announce,
      'enable_trade_content_cycle': instance.enable_trade_content_cycle,
      'trade_announce_interval': instance.trade_announce_interval,
      'content_skip_count': instance.content_skip_count,
      'trade_content': instance.trade_content,
      'enable_pay_log': instance.enable_pay_log,
      'transfer_interval': instance.transfer_interval,
      'enable_reply_msg': instance.enable_reply_msg,
      'enable_auto_reply': instance.enable_auto_reply,
      'forward_ID': instance.forward_ID,
      'clear_reply_id_interval': instance.clear_reply_id_interval,
      'auto_reply_week': instance.auto_reply_week,
      'auto_reply_time': instance.auto_reply_time,
      'auto_reply_content': instance.auto_reply_content,
      'enable_discord_bot': instance.enable_discord_bot,
      'enable_send_msg_to_channel': instance.enable_send_msg_to_channel,
      'directly_send_msg_to_dc': instance.directly_send_msg_to_dc,
      'enable_slash_command': instance.enable_slash_command,
      'forward_DC_ID': instance.forward_DC_ID,
      'channel_ID': instance.channel_ID,
      'embed_thumbnail_url': instance.embed_thumbnail_url,
      'bot_application_ID': instance.bot_application_ID,
      'bot_token': instance.bot_token,
    };

EmeraldSetting _$EmeraldSettingFromJson(Map<String, dynamic> json) =>
    EmeraldSetting(
      store_emerald_interval:
          (json['store_emerald_interval'] as num).toDouble(),
      store_emerald_check_times: json['store_emerald_check_times'] as int,
      enable_store_log: json['enable_store_log'] as bool,
      enable_auto_repair: json['enable_auto_repair'] as bool,
      enable_auto_send_store_report:
          json['enable_auto_send_store_report'] as bool,
      enable_multiple_place_store: json['enable_multiple_place_store'] as bool,
      enable_afk_after_store: json['enable_afk_after_store'] as bool,
      store_place: (json['store_place'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      afk_place:
          (json['afk_place'] as List<dynamic>).map((e) => e as String).toList(),
      enable_pay_log: json['enable_pay_log'] as bool,
      transfer_interval: json['transfer_interval'] as int,
      enable_trade_announce: json['enable_trade_announce'] as bool,
      enable_trade_content_cycle: json['enable_trade_content_cycle'] as bool,
      trade_announce_interval: json['trade_announce_interval'] as int,
      content_skip_count: json['content_skip_count'] as int,
      trade_content: (json['trade_content'] as List<dynamic>)
          .map((e) => (e as List<dynamic>).map((e) => e as String).toList())
          .toList(),
      enable_reply_msg: json['enable_reply_msg'] as bool,
      enable_auto_reply: json['enable_auto_reply'] as bool,
      forward_ID: json['forward_ID'] as String,
      clear_reply_id_interval: json['clear_reply_id_interval'] as int,
      auto_reply_week: json['auto_reply_week'] as String,
      auto_reply_time: json['auto_reply_time'] as String,
      auto_reply_content: json['auto_reply_content'] as String,
      enable_discord_bot: json['enable_discord_bot'] as bool,
      enable_send_msg_to_channel: json['enable_send_msg_to_channel'] as bool,
      directly_send_msg_to_dc: json['directly_send_msg_to_dc'] as bool,
      enable_slash_command: json['enable_slash_command'] as bool,
      forward_DC_ID: (json['forward_DC_ID'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      channel_ID: json['channel_ID'] as String,
      embed_thumbnail_url: json['embed_thumbnail_url'] as String,
      bot_application_ID: json['bot_application_ID'] as String,
      bot_token: json['bot_token'] as String,
    );

Map<String, dynamic> _$EmeraldSettingToJson(EmeraldSetting instance) =>
    <String, dynamic>{
      'store_emerald_interval': instance.store_emerald_interval,
      'store_emerald_check_times': instance.store_emerald_check_times,
      'enable_store_log': instance.enable_store_log,
      'enable_auto_repair': instance.enable_auto_repair,
      'enable_auto_send_store_report': instance.enable_auto_send_store_report,
      'enable_multiple_place_store': instance.enable_multiple_place_store,
      'enable_afk_after_store': instance.enable_afk_after_store,
      'store_place': instance.store_place,
      'afk_place': instance.afk_place,
      'enable_pay_log': instance.enable_pay_log,
      'transfer_interval': instance.transfer_interval,
      'enable_trade_announce': instance.enable_trade_announce,
      'enable_trade_content_cycle': instance.enable_trade_content_cycle,
      'trade_announce_interval': instance.trade_announce_interval,
      'content_skip_count': instance.content_skip_count,
      'trade_content': instance.trade_content,
      'enable_reply_msg': instance.enable_reply_msg,
      'enable_auto_reply': instance.enable_auto_reply,
      'forward_ID': instance.forward_ID,
      'clear_reply_id_interval': instance.clear_reply_id_interval,
      'auto_reply_week': instance.auto_reply_week,
      'auto_reply_time': instance.auto_reply_time,
      'auto_reply_content': instance.auto_reply_content,
      'enable_discord_bot': instance.enable_discord_bot,
      'enable_send_msg_to_channel': instance.enable_send_msg_to_channel,
      'directly_send_msg_to_dc': instance.directly_send_msg_to_dc,
      'enable_slash_command': instance.enable_slash_command,
      'forward_DC_ID': instance.forward_DC_ID,
      'channel_ID': instance.channel_ID,
      'embed_thumbnail_url': instance.embed_thumbnail_url,
      'bot_application_ID': instance.bot_application_ID,
      'bot_token': instance.bot_token,
    };
