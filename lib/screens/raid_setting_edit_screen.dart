import 'package:flutter/material.dart' hide NetworkImage;
import 'package:flutter/services.dart';

import 'package:awesome_icons/awesome_icons.dart';

import '../components/custom_appbar.dart';
import '../components/network_image.dart';
import '../models/bot_instance.dart';
import '../models/setting.dart';
import '../services/setting_service.dart';
import '../services/bot_instance_service.dart';
import '../services/local_storage_service.dart';
import '../services/localization_service.dart';
import '../utils/logger.dart';
import '../utils/util.dart';

class RaidSettingEditScreen extends StatefulWidget {
  final RaidSetting? setting;
  final BotInstance instance;
  const RaidSettingEditScreen(this.setting,this.instance,{super.key});

  @override
  State<RaidSettingEditScreen> createState() => _RaidSettingEditScreenState();
}

class _RaidSettingEditScreenState extends State<RaidSettingEditScreen> {
  RaidSetting? setting;
  /// 交易內容輸入框List
  final List<TextEditingController> tradeContentList = [];
  /// 輸入框焦點
  final FocusNode _focusNode = FocusNode();
  /// 表單Key
  final _formKey = GlobalKey<FormState>();
  /// 是否儲存到暫存
  bool isSaveToTemp = false;
  /// 滾動控制器
  ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if(!_focusNode.hasFocus)
      {
        logger.d("失去焦點");
        setState(() {
          
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
  /// 取得交易內容群組(一個輸入框跟一個新增按鈕)
  Widget getTradeContentGroup(String title,TextEditingController controller,bool islast)
  {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      margin: const EdgeInsets.only(bottom: 10,left: 15),
      child: Row(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall
          ),
          const SizedBox(width: 5),
          Tooltip(
            message: "用\",\"分隔",
            child: Container(
              padding: const EdgeInsets.only(top: 10),
              width: 200,
              height: 75,
              child: TextFormField(
                controller: controller,
                onChanged: null,
                style: Theme.of(context).textTheme.labelSmall,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                autovalidateMode: AutovalidateMode.always,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return LocalizationService.getLocalizedString("config_is_empty_error");
                  }
                  return null;
                },
              )
            ),
          ),
          const SizedBox(width: 10),
          islast ? IconButton(
            onPressed: (){
              setState(() {
                tradeContentList.add(TextEditingController(text: ""));
              });
            },
            icon: const Icon(Icons.add)
          ): IconButton(
            onPressed: (){
              setState(() {
                tradeContentList.remove(controller);
              });
            },
            icon: const Icon(Icons.remove)
          )
        ],
      )
    );
  }
  /// 取得TextField
  Widget getTextField(String tooltip,String label,String value,Function(String)? onChanged,{bool enabled = true})
  {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      margin: const EdgeInsets.only(bottom: 10,left: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 25),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall
            )
          ),
          const SizedBox(width: 5),
          Tooltip(
            message: tooltip,
            child: Container(
              padding: const EdgeInsets.only(top: 10),
              width: 200,
              height: 100,
              child: TextFormField(
                enabled: enabled,
                controller: TextEditingController(text: value),
                onChanged: onChanged,
                style: Theme.of(context).textTheme.labelSmall,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                autovalidateMode: AutovalidateMode.always,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return LocalizationService.getLocalizedString("config_is_empty_error");
                  }
                  return null;
                },
              )
            ),
          )
        ],
      )
    );
  }
  /// 取得TextField，只能輸入數字
  Widget getTextFieldDigitOnly(String tooltip,String label,String value,Function(String) onChanged,{bool enabled = true})
  {
    return Container(
      padding: const EdgeInsets.only(top:10),
      margin: const EdgeInsets.only(bottom: 10,left: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 25),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall
            )
          ),
          const SizedBox(width: 10),
          Tooltip(
            message: tooltip,
            child: SizedBox(
              width: 200,
              height: 75,
              child: TextFormField(
                enabled: enabled,
                controller: TextEditingController(text: value),
                onChanged: onChanged,
                style: Theme.of(context).textTheme.labelSmall,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^-?\d*\.?\d*'),
                  ),
                ],
                autovalidateMode: AutovalidateMode.always,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return LocalizationService.getLocalizedString("config_is_empty_error");
                  }
                  return null;
                },
              )
            ),
          )
        ],
      )
    );
  }
  /// 取得SwitchListTile
  Widget getSwitchListTile(String tooltip,String title,bool initialValue,Function(bool) onChanged)
  {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Tooltip(
        message: tooltip,
        child: SizedBox(
          width: title.length * 15.toDouble() + 120,
          child: SwitchListTile(
            value: initialValue,
            onChanged: onChanged,
            title: Text(title,style: Theme.of(context).textTheme.labelSmall),
          ),
        )
      )
    );
  }
  
  @override
  Widget build(BuildContext context) 
  {
    logger.i("進入RaidSettingEditScreen");
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: getCustomAppBarByIndex(LocalizationService.getLocalizedString("appbar_setting_title"), context),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Tooltip(
            message: LocalizationService.getLocalizedString("set_up_guide"),
            child:IconButton(
              icon: const Icon(FontAwesomeIcons.github),
              onPressed: (){
                Util.openUri("https://github.com/Forever-Hate/McHateBot_raid/wiki/Setup-Guide-%E8%A8%AD%E5%AE%9A%E6%95%99%E5%AD%B8#settingsjson");
              },
            ),
          ),
          const SizedBox(height: 20),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down),
            onPressed: (){
              logger.d("滾動到底部");
              if(_scrollController.positions.isNotEmpty)
              {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                );
              }
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: SettingService.getSetting(widget.instance.type, widget.instance.uuid),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if(snapshot.hasData)
          {
            if(setting == null)
            {
              for (var element in (snapshot.data! as RaidSetting).trade_content) {
                tradeContentList.add(TextEditingController(text: element.join(",")));
              }
            }
            setting ??= widget.setting ?? snapshot.data!;
            return Container(
              padding: const EdgeInsets.only(bottom: 10),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Form(
                  key:_formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      getSwitchListTile(LocalizationService.getLocalizedString("enable_detect_broadcast_tooltip"), LocalizationService.getLocalizedString("enable_detect_broadcast_title"), setting!.enable_detect_broadcast, (newValue) {
                        setState(() {
                          setting!.enable_detect_broadcast = newValue;
                        });
                      }),
                      getSwitchListTile(LocalizationService.getLocalizedString("enable_display_health_tooltip"), LocalizationService.getLocalizedString("enable_display_health_title"), setting!.enable_display_health, (newValue){
                        setState(() {
                          setting!.enable_display_health = newValue;
                        });
                      }),
                      getSwitchListTile(LocalizationService.getLocalizedString("enable_attack_tooltip"), LocalizationService.getLocalizedString("enable_attack_title"), setting!.enable_attack, (newValue){
                        setState(() {
                          setting!.enable_attack = newValue;
                        });
                      }),
                      Visibility(
                        visible: setting!.enable_attack,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            getTextFieldDigitOnly(LocalizationService.getLocalizedString("interval_ticks_tooltip"),LocalizationService.getLocalizedString("interval_ticks_title"), setting!.interval_ticks.toString(), (newValue){
                                try
                                {
                                  setting!.interval_ticks = int.parse(newValue);
                                }
                                catch(e)
                                {
                                  setting!.interval_ticks = 7;
                                }
                            }),
                            getTextFieldDigitOnly(LocalizationService.getLocalizedString("attack_radius_tooltip"),LocalizationService.getLocalizedString("attack_radius_title"), setting!.attack_radius.toString(), (newValue){
                                try
                                {
                                  setting!.attack_radius = int.parse(newValue);
                                }
                                catch(e)
                                {
                                  setting!.attack_radius = 6;
                                }
                            }),
                            // 目標怪物清單
                            Container(
                              padding: const EdgeInsets.only(top: 10),
                              margin: const EdgeInsets.only(bottom: 10,left: 15),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 25),
                                    child: Text(
                                      LocalizationService.getLocalizedString("mob_list_title"),
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context).textTheme.labelSmall
                                    )
                                  ),
                                  const SizedBox(width: 5),
                                  Tooltip(
                                    message: LocalizationService.getLocalizedString("mob_list_tooltip"),
                                    child: Container(
                                      padding: const EdgeInsets.only(top: 10),
                                      width: 300,
                                      height: 100,
                                      child: TextFormField(
                                        controller: TextEditingController(text: setting!.mob_list.join(",")),
                                        onChanged: (newValue){
                                          setting!.mob_list = newValue.split(",");
                                        },
                                        style: Theme.of(context).textTheme.labelSmall,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                        ),
                                        autovalidateMode: AutovalidateMode.always,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return LocalizationService.getLocalizedString("config_is_empty_error");
                                          }
                                          return null;
                                        },
                                      )
                                    ),
                                  )
                                ],
                              )
                            )
                          ],
                        ),
                      ),

                      getSwitchListTile(LocalizationService.getLocalizedString("enable_detect_interrupt_tooltip"),LocalizationService.getLocalizedString("enable_detect_interrupt_title"), setting!.enable_detect_interrupt, (newValue){
                        setState(() {
                          setting!.enable_detect_interrupt = newValue;
                        });
                      }),
                      Visibility(
                        visible: setting!.enable_detect_interrupt,
                        child: getTextFieldDigitOnly(LocalizationService.getLocalizedString("check_raid_interval_tooltip"),LocalizationService.getLocalizedString("check_raid_interval_title"), setting!.check_raid_interval.toString(), (newValue){
                            try
                            {
                              setting!.check_raid_interval = int.parse(newValue);
                            }
                            catch(e)
                            {
                              setting!.check_raid_interval = 60;
                            }
                        }),
                      ),

                      getSwitchListTile(LocalizationService.getLocalizedString("enable_track_tooltip"),LocalizationService.getLocalizedString("enable_track_title"), setting!.enable_track, (newValue){
                        setState(() {
                          setting!.enable_track = newValue;
                        });
                      }),
                      Visibility(
                        visible: setting!.enable_track,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            getSwitchListTile(LocalizationService.getLocalizedString("enable_track_log_tooltip"),LocalizationService.getLocalizedString("enable_track_log_title"), setting!.enable_track_log, (newValue){
                              setState(() {
                                setting!.enable_track_log = newValue;
                              });
                            }),
                            getTextFieldDigitOnly(LocalizationService.getLocalizedString("track_record_tooltip"),LocalizationService.getLocalizedString("track_record_title"), setting!.track_record.toString(), (newValue){
                                try
                                {
                                  setting!.track_record = int.parse(newValue);
                                }
                                catch(e)
                                {
                                  setting!.track_record = 60;
                                }
                            }),
                            getTextField(LocalizationService.getLocalizedString("track_list_tooltip"),LocalizationService.getLocalizedString("track_list_title"),setting!.track_list.join(","), (newValue){
                              setting!.track_list = newValue.split(",");
                            })
                          ],
                        ),
                      ),

                      getSwitchListTile(LocalizationService.getLocalizedString("enable_discard_tooltip"),LocalizationService.getLocalizedString("enable_discard_title"), setting!.enable_discard, (newValue){
                        setState(() {
                          setting!.enable_discard = newValue;
                        });
                      }),
                      Visibility(
                        visible: setting!.enable_discard,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            getSwitchListTile(LocalizationService.getLocalizedString("enable_discard_msg_tooltip"),LocalizationService.getLocalizedString("enable_discard_msg_title"), setting!.enable_discard_msg, (newValue){
                              setState(() {
                                setting!.enable_discard_msg = newValue;
                              });
                            }),
                            getSwitchListTile(LocalizationService.getLocalizedString("enable_stay_totem_tooltip"),LocalizationService.getLocalizedString("enable_stay_totem_title"), setting!.enable_stay_totem, (newValue){
                              setState(() {
                                setting!.enable_stay_totem = newValue;
                              });
                            }),
                            getSwitchListTile(LocalizationService.getLocalizedString("enable_auto_stack_totem_tooltip"),LocalizationService.getLocalizedString("enable_auto_stack_totem_title"), setting!.enable_auto_stack_totem, (newValue){
                              setState(() {
                                setting!.enable_auto_stack_totem = newValue;
                              });
                            }),
                            getSwitchListTile(LocalizationService.getLocalizedString("enable_totem_notifier_tooltip"),LocalizationService.getLocalizedString("enable_totem_notifier_title"), setting!.enable_totem_notifier, (newValue){
                              setState(() {
                                setting!.enable_totem_notifier = newValue;
                              });
                            }),
                            getTextFieldDigitOnly(LocalizationService.getLocalizedString("discard_interval_tooltip"),LocalizationService.getLocalizedString("discard_interval_title"), setting!.discard_interval.toString(), (newValue){
                                try
                                {
                                  setting!.discard_interval = int.parse(newValue);
                                }
                                catch(e)
                                {
                                  setting!.discard_interval = 60;
                                }
                            }),
                            //保留物品列表
                            Container(
                              padding: const EdgeInsets.only(top: 10),
                              margin: const EdgeInsets.only(bottom: 10,left: 15),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 25),
                                    child: Text(
                                      LocalizationService.getLocalizedString("stayItem_list_title"),
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context).textTheme.labelSmall
                                    )
                                  ),
                                  const SizedBox(width: 5),
                                  Tooltip(
                                    message: LocalizationService.getLocalizedString("stayItem_list_tooltip"),
                                    child: Container(
                                      padding: const EdgeInsets.only(top: 10),
                                      width: 350,
                                      height: 100,
                                      child: TextFormField(
                                        controller: TextEditingController(text: setting!.stayItem_list.join(",")),
                                        onChanged:  (newValue){
                                          setting!.stayItem_list = newValue.split(",");
                                        },
                                        style: Theme.of(context).textTheme.labelSmall,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                        ),
                                        autovalidateMode: AutovalidateMode.always,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return LocalizationService.getLocalizedString("config_is_empty_error");
                                          }
                                          return null;
                                        },
                                      )
                                    ),
                                  )
                                ],
                              )
                            )
                          ],
                        ),
                      ),
                      getSwitchListTile(LocalizationService.getLocalizedString("enable_exchange_logs_tooltip"),LocalizationService.getLocalizedString("enable_exchange_logs_title"), setting!.enable_exchange_logs, (newValue){
                        setState(() {
                          setting!.enable_exchange_logs = newValue;
                        });
                      }),
                      getTextFieldDigitOnly(LocalizationService.getLocalizedString("no_item_exchange_interval_tooltip"),LocalizationService.getLocalizedString("no_item_exchange_interval_title"), setting!.no_item_exchange_interval.toString(), (newValue){
                          try
                          {
                            setting!.no_item_exchange_interval = double.parse(newValue);
                          }
                          catch(e)
                          {
                            setting!.no_item_exchange_interval = 0.5;
                          }
                      }),
                      getTextFieldDigitOnly(LocalizationService.getLocalizedString("item_exchange_interval_tooltip"),LocalizationService.getLocalizedString("item_exchange_interval_title"), setting!.item_exchange_interval.toString(), (newValue){
                          try
                          {
                            setting!.item_exchange_interval = double.parse(newValue);
                          }
                          catch(e)
                          {
                            setting!.item_exchange_interval = 0.8;
                          }
                      }),

                      getSwitchListTile(LocalizationService.getLocalizedString("enable_trade_announce_tooltip"),LocalizationService.getLocalizedString("enable_trade_announce_title"), setting!.enable_trade_announce, (newValue){
                        setState(() {
                          setting!.enable_trade_announce = newValue;
                        });
                      }),
                      Visibility(
                        visible: setting!.enable_trade_announce,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            getSwitchListTile(LocalizationService.getLocalizedString("enable_trade_content_cycle_tooltip"),LocalizationService.getLocalizedString("enable_trade_content_cycle_title"), setting!.enable_trade_content_cycle, (newValue){
                              setState(() {
                                setting!.enable_trade_content_cycle = newValue;
                              });
                            }),
                            getTextFieldDigitOnly(LocalizationService.getLocalizedString("content_skip_count_tooltip"),LocalizationService.getLocalizedString("content_skip_count_title"), setting!.content_skip_count.toString(), (newValue){
                                try
                                {
                                  setting!.content_skip_count = int.parse(newValue);
                                }
                                catch(e)
                                {
                                  setting!.content_skip_count = 1;
                                }
                            }),
                            getTextFieldDigitOnly(LocalizationService.getLocalizedString("trade_announce_interval_tooltip"),LocalizationService.getLocalizedString("trade_announce_interval_title"), setting!.trade_announce_interval.toString(), (newValue){
                                try
                                {
                                  setting!.trade_announce_interval = int.parse(newValue);
                                }
                                catch(e)
                                {
                                  setting!.trade_announce_interval = 605;
                                }
                            }),
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: tradeContentList.length,
                              itemBuilder: (context,index){
                                return getTradeContentGroup("第${index+1}組宣傳:", tradeContentList[index],index == tradeContentList.length - 1);
                              }
                            )
                          ],
                        ),
                      ),
                      
                      getSwitchListTile(LocalizationService.getLocalizedString("enable_pay_log_tooltip"),LocalizationService.getLocalizedString("enable_pay_log_title"), setting!.enable_pay_log, (newValue){
                        setState(() {
                          setting!.enable_pay_log = newValue;
                        });
                      }),
                      Visibility(
                        visible: setting!.enable_pay_log,
                        child: getTextFieldDigitOnly(LocalizationService.getLocalizedString("transfer_interval_tooltip"),LocalizationService.getLocalizedString("transfer_interval_title"), setting!.transfer_interval.toString(), (newValue){
                            try
                            {
                              setting!.transfer_interval = int.parse(newValue);
                            }
                            catch(e)
                            {
                              setting!.transfer_interval = 60;
                            }
                          }
                        ),
                      ),
                      getSwitchListTile(LocalizationService.getLocalizedString("enable_reply_msg_tooltip"),LocalizationService.getLocalizedString("enable_reply_msg_title"), setting!.enable_reply_msg, (newValue){
                        setState(() {
                          setting!.enable_reply_msg = newValue;
                        });
                      }),
                      Visibility(
                        visible: setting!.enable_reply_msg,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            getTextField(LocalizationService.getLocalizedString("forward_ID_tooltip"),LocalizationService.getLocalizedString("forward_ID_title"),setting!.forward_ID, (newValue){
                              setting!.forward_ID = newValue;
                            }),
                            getTextFieldDigitOnly(LocalizationService.getLocalizedString("clear_reply_id_interval_tooltip"),LocalizationService.getLocalizedString("clear_reply_id_interval_title"), setting!.clear_reply_id_interval.toString(), (newValue){
                                try
                                {
                                  setting!.clear_reply_id_interval = int.parse(newValue);
                                }
                                catch(e)
                                {
                                  setting!.clear_reply_id_interval = 600;
                                }
                            }),
                            getSwitchListTile(LocalizationService.getLocalizedString("enable_auto_reply_tooltip"),LocalizationService.getLocalizedString("enable_auto_reply_title"), setting!.enable_auto_reply, (newValue){
                              setState(() {
                                setting!.enable_auto_reply = newValue;
                              });
                            }),
                            Visibility(
                              visible: setting!.enable_auto_reply,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  getTextField(LocalizationService.getLocalizedString("auto_reply_week_tooltip"),LocalizationService.getLocalizedString("auto_reply_week_title"),setting!.auto_reply_week, (newValue){
                                    setting!.auto_reply_week = newValue;
                                  }),
                                  getTextField(LocalizationService.getLocalizedString("auto_reply_time_title"),LocalizationService.getLocalizedString("auto_reply_time_title"),setting!.auto_reply_time, (newValue){
                                    setting!.auto_reply_time = newValue;
                                  }),
                                  getTextField(LocalizationService.getLocalizedString("auto_reply_content_tooltip"),LocalizationService.getLocalizedString("auto_reply_content_title"),setting!.auto_reply_content, (newValue){
                                    setting!.auto_reply_content = newValue;
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      getSwitchListTile(LocalizationService.getLocalizedString("enable_discord_bot_tooltip"),LocalizationService.getLocalizedString("enable_discord_bot_title"), setting!.enable_discord_bot, (newValue){
                        setState(() {
                          setting!.enable_discord_bot = newValue;
                        });
                      }),
                      Visibility(
                        visible: setting!.enable_discord_bot,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            getTextField(LocalizationService.getLocalizedString("forward_DC_ID_tooltip"),LocalizationService.getLocalizedString("forward_DC_ID_title"),setting!.forward_DC_ID.join(","), (newValue){
                              setting!.forward_DC_ID = newValue.split(",");
                            }),
                            getTextField(LocalizationService.getLocalizedString("bot_token_tooltip"),LocalizationService.getLocalizedString("bot_token_title"),setting!.bot_token, (newValue){
                              setting!.bot_token = newValue;
                            }),
                            getSwitchListTile(LocalizationService.getLocalizedString("directly_send_msg_to_dc_tooltip"),LocalizationService.getLocalizedString("directly_send_msg_to_dc_title"), setting!.directly_send_msg_to_dc, (newValue){
                              setState(() {
                                setting!.directly_send_msg_to_dc = newValue;
                              });
                            }),

                            getSwitchListTile(LocalizationService.getLocalizedString("enable_send_msg_to_channel_tooltip"),LocalizationService.getLocalizedString("enable_send_msg_to_channel_title"), setting!.enable_send_msg_to_channel, (newValue){
                              setState(() {
                                setting!.enable_send_msg_to_channel = newValue;
                              });
                            }),
                            Visibility(
                              visible: setting!.enable_send_msg_to_channel,
                              child: getTextField(LocalizationService.getLocalizedString("channel_ID_tooltip"),LocalizationService.getLocalizedString("channel_ID_title"),setting!.channel_ID, (newValue){
                                setting!.channel_ID = newValue;
                              }),
                            ),

                            getSwitchListTile(LocalizationService.getLocalizedString("enable_slash_command_tooltip"),LocalizationService.getLocalizedString("enable_slash_command_title"), setting!.enable_slash_command, (newValue){
                              setState(() {
                                setting!.enable_slash_command = newValue;
                              });
                            }),
                            Visibility(
                              visible: setting!.enable_slash_command,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.only(top: 10),
                                        margin: const EdgeInsets.only(bottom: 10,left: 15),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              LocalizationService.getLocalizedString("embed_thumbnail_url_title"),
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context).textTheme.labelSmall
                                            ),
                                            const SizedBox(width: 5),
                                            Tooltip(
                                              message: LocalizationService.getLocalizedString("embed_thumbnail_url_tooltip"),
                                              child: Container(
                                                padding: const EdgeInsets.only(top: 10),
                                                width: 200,
                                                height: 75,
                                                child: TextFormField(
                                                  focusNode: _focusNode,
                                                  enabled: true,
                                                  controller: TextEditingController(text: setting!.embed_thumbnail_url),
                                                  onChanged: (newValue){
                                                    setting!.embed_thumbnail_url = newValue;
                                                  },
                                                  style: Theme.of(context).textTheme.labelSmall,
                                                  decoration: const InputDecoration(
                                                    border: OutlineInputBorder(),
                                                  ),
                                                  autovalidateMode: AutovalidateMode.always,
                                                  validator: (value) {
                                                    if (value == null || value.isEmpty) {
                                                      return LocalizationService.getLocalizedString("config_is_empty_error");
                                                    }
                                                    return null;
                                                  },
                                                )
                                              ),
                                            )
                                          ],
                                        )
                                      ),
                                      const SizedBox(width: 10),
                                      FutureBuilder(
                                        future: Util.isImageUrlValid(setting!.embed_thumbnail_url),
                                        builder: (context, snap) {
                                          if(snap.connectionState == ConnectionState.waiting)
                                          {
                                            return Text(LocalizationService.getLocalizedString("now_loading"),style: Theme.of(context).textTheme.labelSmall);
                                          }
                                          else
                                          {
                                            return snap.data! == true ? 
                                              FutureBuilder(
                                                future: Util.getImageSizeFromUrl(setting!.embed_thumbnail_url),
                                                builder: (context, snapshot){
                                                  if(snapshot.connectionState == ConnectionState.waiting)
                                                  {
                                                    return Text(LocalizationService.getLocalizedString("now_loading"),style: Theme.of(context).textTheme.labelSmall);
                                                  }
                                                  else
                                                  {
                                                    return NetworkImage(
                                                      src: setting!.embed_thumbnail_url,
                                                      fit:BoxFit.fill,
                                                      width: snapshot.data![0] / 2,
                                                      height: snapshot.data![1] / 2,
                                                      errorWidget: Text(LocalizationService.getLocalizedString("image_load_fail_error"),style: Theme.of(context).textTheme.labelSmall)

                                                    );
                                                  }
                                                },
                                              )
                                            : Text(LocalizationService.getLocalizedString("invalid_image_URL_error"),style: Theme.of(context).textTheme.labelSmall);
                                          }
                                        },
                                      )
                                      
                                    ],
                                  ),
                                  getTextField(LocalizationService.getLocalizedString("bot_application_ID_tooltip"),LocalizationService.getLocalizedString("bot_application_ID_title"),setting!.bot_application_ID, (newValue){
                                    setting!.bot_application_ID = newValue;
                                  }),
                                ],
                              ), 
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 15),
                        child: ElevatedButton(
                          onPressed: () async {
                            logger.d("儲存設定");
                            if(_formKey.currentState!.validate())
                            {
                              logger.d("通過驗證");
                              //將tradeContent取出轉成List<List<String>>
                              List<List<String>> tradeContent = [];
                              for (TextEditingController controller in tradeContentList) {
                                String text = controller.text;
                                List<String> splitText = text.split(',');
                                tradeContent.add(splitText);
                              }
                              //將tradeContent存入setting
                              setting!.trade_content = tradeContent;
                              await SettingService.saveSetting(widget.instance.type, widget.instance.uuid, setting!);
                              
                              //將hasFinishSetting設為true，完成設定
                              widget.instance.hasFinishSetting = true;
                              await BotInstanceService.saveBotInstanceByUuid(widget.instance.uuid,widget.instance);
                              //儲存到緩存
                              LocalStorageService.getIsSaveRaidSettingToTemp().then((value) async {
                                if(value == null)
                                {
                                  Util.getYesNoDialog(
                                    context,
                                    StatefulBuilder(
                                      builder: (BuildContext context, StateSetter setState) {
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(LocalizationService.getLocalizedString("save_to_temp"),style: Theme.of(context).textTheme.labelSmall),
                                            const SizedBox(height: 10),
                                            CheckboxListTile(
                                              controlAffinity: ListTileControlAffinity.leading, //讓複選框在文字前面
                                              contentPadding: EdgeInsets.zero, //讓複選框不要有padding
                                              title: Text(LocalizationService.getLocalizedString("save_my_option"),style: Theme.of(context).textTheme.labelSmall),
                                              value: isSaveToTemp,
                                              onChanged: (newValue){
                                                logger.i("按下儲存到暫存");
                                                setState(() {
                                                  isSaveToTemp = newValue!;
                                                });
                                              }
                                            )
                                          ],
                                        );
                                      },
                                    ),
                                    (){
                                      Util.getMessageDialog(context, LocalizationService.getLocalizedString("save_success"), (){
                                        if(isSaveToTemp)
                                        {
                                          LocalStorageService.saveIsSaveRaidSettingToTemp(true);
                                        }
                                        SettingService.saveRaidSettingToLocalStorage(setting!);
                                        Navigator.pop(context);
                                      });
                                    },
                                    (){
                                      Util.getMessageDialog(context, LocalizationService.getLocalizedString("save_success"), (){
                                        if(isSaveToTemp)
                                        {
                                          LocalStorageService.saveIsSaveRaidSettingToTemp(false);
                                        }
                                        Navigator.pop(context);
                                      });
                                    }
                                  );
                                }
                                else
                                {
                                  if(value)
                                  {
                                    Util.getMessageDialog(context, LocalizationService.getLocalizedString("save_success"), (){  
                                      if(value)
                                      {
                                        SettingService.saveRaidSettingToLocalStorage(setting!);
                                      }
                                      Navigator.pop(context);
                                    });
                                  }
                                }
                              });
                            }
                            else
                            {
                              logger.d("未通過驗證");
                              Util.getMessageDialog(context, LocalizationService.getLocalizedString("save_fail"),null);
                            }
                          },
                          child: Text(LocalizationService.getLocalizedString("save"),style: Theme.of(context).textTheme.labelSmall),
                        ),
                      )
                      
                    ],
                  ),
                )
              ),
            );
          }
          else
          {
            return Util.getLoadingWidget(context, LocalizationService.getLocalizedString("now_loading"));
          }
        },
      )  
    );
  }
}