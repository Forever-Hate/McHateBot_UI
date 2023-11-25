import 'package:flutter/material.dart' hide NetworkImage;
import 'package:flutter/services.dart';

import 'package:awesome_icons/awesome_icons.dart';

import '../components/custom_appbar.dart';
import '../components/network_image.dart';
import '../models/bot_instance.dart';
import '../models/config.dart';
import '../services/local_storage_service.dart';
import '../services/localization_service.dart';
import '../services/minecraft_service.dart';
import '../services/bot_instance_service.dart';
import '../services/config_service.dart';
import '../utils/logger.dart';
import '../utils/util.dart';

/// 設定檔編輯頁面
class ConfigEditScreen extends StatefulWidget {
  final Config? config;
  final BotInstance instance;
  const ConfigEditScreen(this.config,this.instance,{super.key});

  @override
  State<ConfigEditScreen> createState() => _ConfigEditScreenState();
}

class _ConfigEditScreenState extends State<ConfigEditScreen> {
  Config? config;
  /// 用於驗證表單key
  final _formKey = GlobalKey<FormState>();
  /// 用於驗證username
  final TextEditingController _textEditingController = TextEditingController();
  /// 用於監聽username是否有失去焦點
  final FocusNode _focusNode = FocusNode();
  /// 是否為有效的username
  bool isValidUsername = false;

  /// 是否要存到暫存(checkBox value)
  bool isSaveToTemp = false;

  /// 是否正在讀取
  bool isLoad = false;
  
  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if(!_focusNode.hasFocus)
      {
        logger.d("失去焦點，text: ${_textEditingController.text}");
        if(_textEditingController.text.isEmpty)
        {
          return;
        }
        MinecraftService.getUuidFromName(_textEditingController.text).then((value){
          setState(() {
            if(value != null)
            {
              isValidUsername = true;
              config!.username = _textEditingController.text;
              MinecraftService.getUuidFromName(_textEditingController.text).then((value) => widget.instance.botUuid = value!);
            }
            else
            {
              isValidUsername = false;
            }
          });
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
  }

  Widget getTextField(String tooltip,String label,String value,Function(String)? onChanged,{bool enabled = true})
  {
    logger.i("進入getTextField");
    return Container(
      padding: const EdgeInsets.only(top: 10),
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall
          ),
          const SizedBox(width: 5),
          Tooltip(
            message: tooltip,
            child: Container(
              padding: const EdgeInsets.only(top: 10),
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
                autovalidateMode: AutovalidateMode.always,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return LocalizationService.getLocalizedString("config_is_empty_error");
                  }
                  if(!isValidUsername && label == "username:")
                  {
                    return LocalizationService.getLocalizedString("config_username_error");
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

  Widget getTextFieldDigitOnly(String tooltip,String label,String value,Function(String) onChanged,{bool enabled = true})
  {
    logger.i("進入getTextFieldDigitOnly，取得數字的TextField");
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall
          ),
          const SizedBox(width: 10),
          Tooltip(
            message: tooltip,
            child: SizedBox(
              width: 200,
              height: 50,
              child: TextField(
                enabled: enabled,
                controller: TextEditingController(text: value),
                onChanged: onChanged,
                style: Theme.of(context).textTheme.labelSmall,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'^-?\d{0,10}'),
                ),
              ],
              )
            ),
          )
        ],
      )
    );
  }
  @override
  Widget build(BuildContext context) 
  {
    logger.i("進入ConfigEditScreen");
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: getCustomAppBarByIndex(LocalizationService.getLocalizedString("appbar_config_title"), context),
      floatingActionButton: Tooltip(
        message: LocalizationService.getLocalizedString("set_up_guide"),
        child:IconButton(
          icon: const Icon(FontAwesomeIcons.github),
          onPressed: (){
            logger.d("按下設定教學按鈕");
            if(widget.instance.type == BotType.raid)
            {
              Util.openUri("https://github.com/Forever-Hate/McHateBot_raid/wiki/Setup-Guide-%E8%A8%AD%E5%AE%9A%E6%95%99%E5%AD%B8#configjson");
            }
            else
            {
              Util.openUri("https://github.com/Forever-Hate/McHateBot_emerald/wiki/Setup-Guide-%E8%A8%AD%E5%AE%9A%E6%95%99%E5%AD%B8#configjson");
            }
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.only(bottom: 10),
        child: Form(
          key: _formKey,
          child: FutureBuilder(
            future: Future.wait([ConfigService.getConfig(widget.instance.uuid),MinecraftService.getServerPingMap(),MinecraftService.getBestHost()]),
            builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
              if(snapshot.connectionState == ConnectionState.done)
              {
                config ??= widget.config ?? snapshot.data![0];
                config!.ip = snapshot.data![2];
                _textEditingController.text = config!.username;
                return SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.only(left: 10),
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        getTextField('${LocalizationService.getLocalizedString("config_ip_tooltip")}:\n${snapshot.data![1].entries.map((entry) => '${entry.key}: ${entry.value}ms').join('\n')}',LocalizationService.getLocalizedString("config_ip"), config!.ip, (newValue) {
                          config!.ip = newValue;
                        }),
                        getTextFieldDigitOnly(LocalizationService.getLocalizedString("config_port_tooltip"),LocalizationService.getLocalizedString("config_port"), config!.port.toString(), (newValue) {
                          config!.port = int.parse(newValue);
                        },enabled: false),
                        FutureBuilder(
                          future: MinecraftService.getAvatarsFromName(_textEditingController.text),
                          builder: (context, AsyncSnapshot<String?> snap) 
                          {
                            if(snap.hasError)
                            {
                              return Text(LocalizationService.getLocalizedString("error"));
                            }
                            else
                            {
                              logger.d("snap.data: ${snap.data}");
                              if(snap.data == null)
                              {
                                isValidUsername = false;
                              }
                              else
                              {
                                isValidUsername = true;
                              }
                              return Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(top: 10),
                                    margin: const EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 25),
                                          child: Text(
                                            LocalizationService.getLocalizedString("config_username"),
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context).textTheme.labelSmall
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Tooltip(
                                          message: LocalizationService.getLocalizedString("config_username_tooltip"),
                                          child: Container(
                                            padding: const EdgeInsets.only(top: 10),
                                            width: 200,
                                            height: 100,
                                            child: TextFormField(
                                              focusNode: _focusNode,
                                              controller: _textEditingController,
                                              onChanged: (newValue){
                                                logger.d("完成修改，newValue: $newValue");
                                                config!.username = newValue;
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
                                                if(!isValidUsername)
                                                {
                                                  return LocalizationService.getLocalizedString("config_username_error");
                                                }
                                                return null;
                                              },
                                              onEditingComplete: () {
                                                setState(() {
                                                });
                                              },
                                            )
                                          ),
                                        )
                                      ],
                                    )
                                  ),
                                  const SizedBox(width:10),
                                  isValidUsername && snap.data != null ? 
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 25),
                                    child: NetworkImage(
                                      src: snap.data!,
                                      width: 75,
                                      height: 75,
                                      errorWidget: const Icon(Icons.person,size: 75)
                                    ),
                                  ):
                                  const Padding(
                                    padding: EdgeInsets.only(bottom: 25),
                                    child: Icon(Icons.person,size: 75)
                                  )
                                ]
                              );
                            }
                          }
                        ),
                        getTextField(LocalizationService.getLocalizedString("config_version_tooltip"),LocalizationService.getLocalizedString("config_version"), config!.version, null,enabled: false),
                        getTextField(LocalizationService.getLocalizedString("config_auth_tooltip"),LocalizationService.getLocalizedString("config_auth"), config!.auth!, null,enabled: false),
                        getTextField(LocalizationService.getLocalizedString("config_language_tooltip"),LocalizationService.getLocalizedString("config_language"), config!.language!,null,enabled: false),
                        getTextField(LocalizationService.getLocalizedString("config_whitelist_tooltip"),LocalizationService.getLocalizedString("config_whitelist"),config!.whitelist.join(','), (newValue) {
                          config!.whitelist = newValue.split(',');
                        }),
                        ElevatedButton(
                          style: Theme.of(context).elevatedButtonTheme.style,
                          onPressed: ()  {
                            logger.d("按下儲存按鈕");
                            if(_formKey.currentState!.validate())
                            {
                              widget.instance.hasConfigured = true;
                              MinecraftService.getUuidFromName(config!.username).then((value) async {
                                widget.instance.botUuid = value!;
                                widget.instance.username = config!.username;
                                await ConfigService.saveConfig(widget.instance.uuid,config!);
                                await BotInstanceService.saveBotInstanceByUuid(widget.instance.uuid,widget.instance);
                                LocalStorageService.getIsSaveConfigToTemp().then((value) {
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
                                            LocalStorageService.saveIsSaveConfigToTemp(true);
                                          }
                                          ConfigService.saveConfigToLocalStorage(config!);
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
                                        ConfigService.saveConfigToLocalStorage(config!);
                                      }
                                      Navigator.pop(context);
                                    });
                                  }
                                });
                              });
                            }
                            else
                            {
                              Util.getMessageDialog(context, LocalizationService.getLocalizedString("save_fail"),null);
                            }
                          }, 
                          child: Text(
                            LocalizationService.getLocalizedString("save"),
                            style:Theme.of(context).textTheme.labelSmall
                          )
                        )
                      ],
                    ),
                  )
                );
              }
              else
              {
                return Util.getLoadingWidget(context, LocalizationService.getLocalizedString("now_loading"));
              }
            },
          )  
        )
      )
    );
  }
}