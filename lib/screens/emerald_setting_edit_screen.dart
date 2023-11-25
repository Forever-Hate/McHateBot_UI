import 'package:flutter/material.dart' hide NetworkImage;
import 'package:flutter/services.dart';

import 'package:awesome_icons/awesome_icons.dart';

import '../components/custom_appbar.dart';
import '../components/network_image.dart';
import '../models/bot_instance.dart';
import '../models/setting.dart';
import '../services/local_storage_service.dart';
import '../services/bot_instance_service.dart';
import '../services/localization_service.dart';
import '../services/setting_service.dart';
import '../utils/logger.dart';
import '../utils/util.dart';

/// 存綠設定頁面
class EmeraldSettingEditScreen extends StatefulWidget {
  final EmeraldSetting? setting;
  final BotInstance instance;
  const EmeraldSettingEditScreen(this.setting,this.instance,{super.key});

  @override
  State<EmeraldSettingEditScreen> createState() => _EmeraldSettingEditScreenState();
}

class _EmeraldSettingEditScreenState extends State<EmeraldSettingEditScreen> {
  
  EmeraldSetting? setting;

  //宣傳內容
  final List<TextEditingController> tradeContentList = [];

  //焦點
  final FocusNode _focusNode = FocusNode();

  //表單驗證Key
  final _formKey = GlobalKey<FormState>();

  //是否儲存到暫存
  bool isSaveToTemp = false;

  /// 取得宣傳內容群組(一個輸入框跟一個新增按鈕)
  Widget getTradeContentGroup(String title,TextEditingController controller,bool islast)
  {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      margin: const EdgeInsets.only(bottom: 10,left: 15),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 25),
            child: Text(
              title,
              style: Theme.of(context).textTheme.labelSmall
            )
          ),
          const SizedBox(width: 5),
          Tooltip(
            message: "用\",\"分隔",
            child: Container(
              padding: const EdgeInsets.only(top: 10),
              width: 500,
              height: 100,
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
          islast ? Padding(
            padding: const EdgeInsets.only(bottom: 25),
            child: IconButton(
              onPressed: (){
                setState(() {
                  tradeContentList.add(TextEditingController(text: ""));
                });
              },
              icon: const Icon(Icons.add)
            )
          ): 
          Padding(
            padding: const EdgeInsets.only(bottom: 25),
            child: IconButton(
              onPressed: (){
                setState(() {
                  tradeContentList.remove(controller);
                });
              },
              icon: const Icon(Icons.remove)
            )
          )
        ],
      )
    );
  }
  /// 取得文字輸入框
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

  /// 取得數字輸入框
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
  
  ///取得SwitchListTile
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
  Widget build(BuildContext context) {
    logger.i("進入EmeraldSettingEditScreen");
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: getCustomAppBarByIndex(LocalizationService.getLocalizedString("appbar_setting_title"), context),
      floatingActionButton: Tooltip(
        message: LocalizationService.getLocalizedString("set_up_guide"),
        child:IconButton(
          icon: const Icon(FontAwesomeIcons.github),
          onPressed: (){
            Util.openUri("https://github.com/Forever-Hate/McHateBot_emerald/wiki/Setup-Guide-%E8%A8%AD%E5%AE%9A%E6%95%99%E5%AD%B8#settingsjson");
          },
        ),
      ),
      body: FutureBuilder(
        future: SettingService.getSetting(widget.instance.type, widget.instance.uuid),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if(snapshot.hasData)
          {
            if(setting == null)
            {
              for (var element in (snapshot.data! as EmeraldSetting).trade_content) {
                tradeContentList.add(TextEditingController(text: element.join(",")));
              }
            }
            setting ??= widget.setting ?? snapshot.data!;
            return Container(
              padding: const EdgeInsets.only(bottom: 10),
              child: SingleChildScrollView(
                child: Form(
                  key:_formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      getTextFieldDigitOnly(LocalizationService.getLocalizedString("store_emerald_interval_tooltip"),LocalizationService.getLocalizedString("store_emerald_interval_title"), setting!.content_skip_count.toString(), (newValue){
                          try
                          {
                            setting!.store_emerald_interval = double.parse(newValue);
                          }
                          catch(e)
                          {
                            setting!.store_emerald_interval = 1.5;
                          }
                      }),
                      getTextFieldDigitOnly(LocalizationService.getLocalizedString("store_emerald_check_times_tooltip"),LocalizationService.getLocalizedString("store_emerald_check_times_title"), setting!.store_emerald_check_times.toString(), (newValue){
                          try
                          {
                            setting!.store_emerald_check_times = int.parse(newValue);
                          }
                          catch(e)
                          {
                            setting!.store_emerald_check_times = 5;
                          }
                      }),
                      getSwitchListTile(LocalizationService.getLocalizedString("enable_store_log_tooltip"),LocalizationService.getLocalizedString("enable_store_log_title"), setting!.enable_store_log, (newValue){
                        setState(() {
                          setting!.enable_store_log = newValue;
                        });
                      }),
                      getSwitchListTile(LocalizationService.getLocalizedString("enable_auto_repair_tooltip"),LocalizationService.getLocalizedString("enable_auto_repair_title"), setting!.enable_auto_repair, (newValue){
                        setState(() {
                          setting!.enable_auto_repair = newValue;
                        });
                      }),
                      getSwitchListTile(LocalizationService.getLocalizedString("enable_auto_send_store_report_tooltip"),LocalizationService.getLocalizedString("enable_auto_send_store_report_title"), setting!.enable_auto_send_store_report, (newValue){
                        setState(() {
                          setting!.enable_auto_send_store_report = newValue;
                        });
                      }),
                      getSwitchListTile(LocalizationService.getLocalizedString("enable_multiple_place_store_tooltip"),LocalizationService.getLocalizedString("enable_multiple_place_store_title"), setting!.enable_multiple_place_store, (newValue){
                        setState(() {
                          setting!.enable_multiple_place_store = newValue;
                        });
                      }),
                      Visibility(
                        visible: setting!.enable_multiple_place_store,
                        child: Container(
                          padding: const EdgeInsets.only(top: 10),
                          margin: const EdgeInsets.only(bottom: 10,left: 15),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 25),
                                child: Text(
                                  LocalizationService.getLocalizedString("store_place_title"),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.labelSmall
                                )
                              ),
                              const SizedBox(width: 5),
                              Tooltip(
                                message: LocalizationService.getLocalizedString("store_place_tooltip"),
                                child: Container(
                                  padding: const EdgeInsets.only(top: 10),
                                  width: 300,
                                  height: 100,
                                  child: TextFormField(
                                    controller: TextEditingController(text: setting!.store_place.join(",")),
                                    onChanged: (newValue){
                                      setting!.store_place = newValue.split(",");
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
                      ),
                      getSwitchListTile(LocalizationService.getLocalizedString("enable_afk_after_store_tooltip"),LocalizationService.getLocalizedString("enable_afk_after_store_title"), setting!.enable_afk_after_store, (newValue){
                        setState(() {
                          setting!.enable_afk_after_store = newValue;
                        });
                      }),
                      Visibility(
                        visible: setting!.enable_afk_after_store,
                        child: Container(
                          padding: const EdgeInsets.only(top: 10),
                          margin: const EdgeInsets.only(bottom: 10,left: 15),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 25),
                                child: Text(
                                  LocalizationService.getLocalizedString("afk_place_title"),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.labelSmall
                                )
                              ),
                              const SizedBox(width: 5),
                              Tooltip(
                                message: LocalizationService.getLocalizedString("afk_place_tooltip"),
                                child: Container(
                                  padding: const EdgeInsets.only(top: 10),
                                  width: 300,
                                  height: 100,
                                  child: TextFormField(
                                    controller: TextEditingController(text: setting!.afk_place.join(",")),
                                    onChanged: (newValue){
                                      setting!.afk_place = newValue.split(",");
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
                      ),
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

                              LocalStorageService.getIsSaveEmeraldSettingToTemp().then((value) {
                                if (value == null)
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
                                          LocalStorageService.saveIsSaveConfigToTemp(true);
                                        }
                                        SettingService.saveEmeraldSettingToLocalStorage(setting!);
                                        Navigator.pop(context);
                                      });
                                    },
                                    (){
                                      Util.getMessageDialog(context, LocalizationService.getLocalizedString("save_success"), (){
                                        if(isSaveToTemp)
                                        {
                                          LocalStorageService.saveIsSaveConfigToTemp(false);
                                        }
                                        Navigator.pop(context);
                                      });
                                    }
                                  );
                                }
                                else
                                {
                                  Util.getMessageDialog(context, LocalizationService.getLocalizedString("save_success"), (){
                                    if(value)
                                    {
                                      SettingService.saveEmeraldSettingToLocalStorage(setting!);
                                    }
                                    //會返回到主畫面
                                    Navigator.pop(context);
                                  });
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