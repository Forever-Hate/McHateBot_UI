import 'package:flutter/material.dart';

import 'package:awesome_icons/awesome_icons.dart';
import 'package:window_manager/window_manager.dart';

import '../components/custom_appbar.dart';
import '../components/new_instance_dialog.dart';
import '../components/bot_instance_card.dart';
import '../models/bot_instance.dart';
import '../models/config.dart';
import '../models/setting.dart';
import '../screens/emerald_setting_edit_screen.dart';
import '../screens/raid_setting_edit_screen.dart';
import '../screens/config_edit_screen.dart';
import '../screens/global_setting_screen.dart';
import '../screens/bot_status_screen.dart';
import '../services/setting_service.dart';
import '../services/bot_instance_service.dart';
import '../services/config_service.dart';
import '../services/github_service.dart';
import '../services/localization_service.dart';
import '../services/zip_service.dart';
import '../utils/logger.dart';
import '../utils/util.dart';

/// 主畫面
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WindowListener {

  //是否正在載入中
  bool isProcessing = false;
  //目前狀態
  String currentStatus = "";
  //BotInstance清單
  List<BotInstance> instances = [];
  //被選取到的BotInstance
  BotInstance? selectedInstance;
  //是否有新版本
  bool isNewVersion = false;
  //新版本號
  String newVersion = "";
  
  //確認新增instance
  onConfirm(BotType? type,String? version) async
  {
    logger.i("進入onConfirm");
    if(type != null && version != null)
    {
      Navigator.pop(context);
      setState(() {
        isProcessing = true;
        currentStatus = LocalizationService.getLocalizedString("downloading");
      });
      //下載zip
      GitHubService.getReleaseZipFromRepoNameAndVersion(type.value, version).then((zipPath) async{
        setState(() {
          currentStatus = LocalizationService.getLocalizedString("unzipping");
        });
        //解壓縮
        String uuid = await ZipService.unzip(zipPath);
        setState((){
          isProcessing = false;
          BotInstance instance = BotInstance(uuid, type, version);
          instances.add(instance);
          selectedInstance = instance;
          BotInstanceService.saveBotInstance(instances);
        });
      }).catchError((error){
        Navigator.pop(context);
        Util.getMessageDialog(context, error.toString(), (){
            setState(() {
              isProcessing = false;
            });
        });
      });
    }
    else
    {
      Util.getMessageDialog(context, LocalizationService.getLocalizedString("new_instance_dialog_error"), null);
    }
  }
  
  ///被選取到
  onSelected(BotInstance instance)
  {
    logger.i("進入Onselected");
    setState(() {
      selectedInstance = instance;
    });
  }

  ///啟動instance
  onLaunch(BotInstance instance) async
  {
    logger.i("進入OnLaunch");
    Util.getYesNoDialog(context,Text(LocalizationService.getLocalizedString("launch_dialog_content"),style: Theme.of(context).textTheme.labelSmall), () async {
      if(instance.hasConfigured && instance.hasFinishSetting)
      {
        logger.d("已經設定完成");
        if(instance.isProcess)
        {
          logger.d("正在執行中");
          Util.getMessageDialog(context, LocalizationService.getLocalizedString("restart_error"), (){

          });
        }
        else
        {
          logger.d("尚未執行");
          await BotInstanceService.openBotInstance(instance);
          setState(() {
            
          });
        }
      }
      else
      {
        logger.d("尚未設定完成");
        Util.getMessageDialog(
          context, 
          LocalizationService.getLocalizedString("incomplete_settings_error")
          .replaceFirst("%config_status%", instance.hasConfigured ? "O" : "X")
          .replaceFirst("%settings_status%", instance.hasFinishSetting ? "O" : "X"), (){
        });
      }
    },null);
  }

  ///關閉instance
  onClose (BotInstance instance)
  {
    logger.i("進入OnClose");
    setState(() {
      BotInstanceService.closeBotInstance(instance);
    });
  }

  @override
  void initState() {
    logger.i("進入HomeScreen initState");
    super.initState();
    windowManager.addListener(this);
    _init();
  }

  // 初始化
  void _init() async {
    await windowManager.setPreventClose(true);
    final latestVersion = await GitHubService.checkNewVersion();
    if(latestVersion != null)
    {
      isNewVersion = true;
      newVersion = latestVersion;
    }
    instances = await BotInstanceService.getBotInstance();
    if(instances.isNotEmpty)
    {
      selectedInstance = instances[0];
    }
    setState(() {});
  }

  //當視窗被關閉時
  @override
  void onWindowClose() {
    windowManager.isPreventClose().then((isPreventClose) {
      if (isPreventClose) {
        Util.getYesNoDialog(
          context, 
          Text(LocalizationService.getLocalizedString("close_window_dialog_content"),style: Theme.of(context).textTheme.labelSmall),
          () async {
            // 關閉所有正在執行中的bot
            instances.map((instance){
              if(instance.isProcess)
              {
                BotInstanceService.closeBotInstance(instance);
              }
            });
            // 關閉視窗
            await windowManager.destroy();
          },null);
      }
    });
  }

  @override
  void dispose() {
    logger.i("進入HomeScreen dispose");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) 
  {
    logger.i("進入HomeScreen");
    return Scaffold(
      appBar: getCustomAppBarByIndex(LocalizationService.getLocalizedString("appbar_main_title"), context),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: Drawer(
        backgroundColor: Theme.of(context).primaryColor,
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                children: [
                  Text(
                    LocalizationService.getLocalizedString("drawer_title"),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    LocalizationService.getLocalizedString("drawer_subtitle"),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const Expanded( 
                    child: SizedBox(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Tooltip(
                        message: LocalizationService.getLocalizedString("discord_button_tooltip"),
                        child: IconButton(
                          onPressed: (){
                            Util.openUri("https://discord.gg/kXwBA4tFKb");
                          }, 
                          icon: Transform.translate(
                            offset: const Offset(-3.0,0.0),
                            child: const Icon(FontAwesomeIcons.discord), 
                          )
                        )
                      )
                    ],
                  )
                ],
              ),
            ),
            ListTile(
              hoverColor: Theme.of(context).listTileTheme.selectedColor,
              title: Text(
                LocalizationService.getLocalizedString("global_setting"),
                style: Theme.of(context).textTheme.labelSmall,
              ),
              onTap: () {
                logger.d("按下${LocalizationService.getLocalizedString("global_setting")}按鈕");
                Navigator.push(context,MaterialPageRoute(builder: (context) => const GlobalSettingScreen()));
              },
            ),
            ListTile(
              hoverColor: Theme.of(context).listTileTheme.selectedColor,
              title: Text(
                LocalizationService.getLocalizedString("about"),
                style: Theme.of(context).textTheme.labelSmall,
              ),
              onTap: () {
                logger.d("按下${LocalizationService.getLocalizedString("about")}按鈕");
              },
            ),
            const Divider(
              indent: 15,
              endIndent: 15,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Text(LocalizationService.getLocalizedString("launching"),style: Theme.of(context).textTheme.titleSmall)),
            ...instances.where((instance) => instance.isProcess)
            .map((instance) => BotInstanceCardInListTile(instance))
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor, 
                  width: 2.0, 
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child:Container(
                          padding: const EdgeInsets.only(left: 10,right: 10),
                          child: SingleChildScrollView(
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.transparent,
                              ),
                              margin: const EdgeInsets.only(top: 10),
                              child: GridView.builder(
                                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 600,
                                  childAspectRatio: 3 / 0.72,
                                  crossAxisSpacing: 10.0,
                                  mainAxisSpacing: 10.0,
                                ),
                                shrinkWrap: true,
                                itemCount: instances.length,
                                itemBuilder: (context, index) {
                                  return BotInstanceCard(instances[index],instances[index] == selectedInstance,onSelected,onLaunch,onClose);
                                },
                              ),
                            ),
                          )
                        ),
                      ), 
                      Visibility(
                        visible: isNewVersion,
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.only(left: 10,right: 10,bottom: 5,top: 5),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  border: Border(
                                    top: BorderSide(
                                      color: Theme.of(context).dividerColor, 
                                      width: 2.0, 
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      LocalizationService.getLocalizedString("checked_new_version").replaceFirst('%version%', newVersion),
                                      textAlign: TextAlign.left,
                                      style: Theme.of(context).textTheme.labelSmall
                                    ),
                                    ElevatedButton(
                                      onPressed: (){
                                        logger.d("按下${LocalizationService.getLocalizedString("download_new_version_button")}按鈕");
                                        Util.openUri(GitHubService.getReleaseUrl(newVersion));
                                      }, 
                                      child: Text(
                                        LocalizationService.getLocalizedString("download_new_version_button"),
                                        style: Theme.of(context).textTheme.labelSmall
                                      )
                                    )
                                  ],
                                )
                              )
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                //右邊的選單
                Container(
                  width: 185,
                  height: MediaQuery.sizeOf(context).height * 0.925,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    border: Border(
                      left: BorderSide(
                        color: Theme.of(context).dividerColor, 
                        width: 2.0, 
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          /* 因為外層的Container有設定color，會無法看到ListTile的水波紋效果
                            解決方法: 將ListTile使用Material()包起來，並設定color為Colors.transparent
                          */
                          children:[
                            //新增
                            Material(
                              color: Colors.transparent,
                              child: ListTile(
                                hoverColor: Theme.of(context).listTileTheme.selectedColor,
                                title: Row(
                                  children: [
                                    Icon(Icons.add,color: Theme.of(context).iconTheme.color),
                                    const SizedBox(width: 5),
                                    Text(LocalizationService.getLocalizedString("add"),style: Theme.of(context).textTheme.labelSmall)
                                  ],
                                ),
                                onTap: () {
                                  logger.d("按下${LocalizationService.getLocalizedString("add")}按鈕");
                                  showDialog(context: context, builder: (context) {
                                    return NewInstanceDialog(onConfirm);
                                  });
                                },
                              ),
                            ),
                            //啟動
                            Material(
                              color: Colors.transparent,
                              child:ListTile(
                                hoverColor: Theme.of(context).listTileTheme.selectedColor,
                                title: Row(
                                  children: [
                                    Icon(Icons.play_circle_fill,color: Theme.of(context).iconTheme.color),
                                    const SizedBox(width: 5),
                                    Text(LocalizationService.getLocalizedString("launch"),style: Theme.of(context).textTheme.labelSmall)
                                  ],
                                ),
                                onTap: selectedInstance != null ? () {
                                  logger.d("按下${LocalizationService.getLocalizedString("launch")}按鈕");
                                  onLaunch(selectedInstance!);
                                }:null,
                              ),
                            ),
                            //關閉
                            Material(
                              color: Colors.transparent,
                              child: ListTile(
                                hoverColor: Theme.of(context).listTileTheme.selectedColor,
                                title: Row(
                                  children: [
                                    Icon(Icons.close,color: Theme.of(context).iconTheme.color),
                                    const SizedBox(width: 5),
                                    Text(LocalizationService.getLocalizedString("close_bot_instance"),style: Theme.of(context).textTheme.labelSmall)
                                  ],
                                ),
                                onTap: selectedInstance != null && selectedInstance!.isProcess ? () {
                                  logger.d("按下${LocalizationService.getLocalizedString("close_bot_instance")}按鈕");
                                  Util.getYesNoDialog(context, 
                                    Text(LocalizationService.getLocalizedString("close_bot_instance_dialog_content"),style: Theme.of(context).textTheme.labelSmall), 
                                    (){
                                        setState(() {
                                          BotInstanceService.closeBotInstance(selectedInstance!);
                                        });
                                      },
                                    null
                                  );
                                }:null,
                              ),
                            ),
                            //移除
                            Material(
                              color: Colors.transparent,
                              child: ListTile(
                                hoverColor: Theme.of(context).listTileTheme.selectedColor,
                                title: Row(
                                  children: [
                                    Icon(Icons.remove,color: Theme.of(context).iconTheme.color),
                                    const SizedBox(width: 5),
                                    Text(LocalizationService.getLocalizedString("remove"),style: Theme.of(context).textTheme.labelSmall)
                                  ],
                                ),
                                onTap: selectedInstance != null ? () {
                                  logger.d("按下${LocalizationService.getLocalizedString("remove")}按鈕");
                                  if(selectedInstance!.isProcess)
                                  {
                                    Util.getMessageDialog(context, LocalizationService.getLocalizedString("remove_error"),null);
                                    return;
                                  }
                                  Util.getYesNoDialog(
                                    context, 
                                    Text(LocalizationService.getLocalizedString("remove_dialog_content"),style: Theme.of(context).textTheme.labelSmall), 
                                    (){
                                      setState(() {
                                        BotInstanceService.deleteBotInstance(selectedInstance!);
                                        instances.removeAt(instances.indexOf(selectedInstance!));
                                        BotInstanceService.saveBotInstance(instances);
                                        if(instances.isNotEmpty)
                                        {
                                          selectedInstance = instances[0];
                                        }
                                        else
                                        {
                                          selectedInstance = null;
                                        }
                                      });
                                    }, null);
                                }:null
                              ),
                            ),
                            //開啟資料夾位置
                            Material(
                              color: Colors.transparent,
                              child: ListTile(
                                hoverColor: Theme.of(context).listTileTheme.selectedColor,
                                title: Row(
                                  children: [
                                    Icon(Icons.folder_open,color: Theme.of(context).iconTheme.color),
                                    const SizedBox(width: 5),
                                    Text(LocalizationService.getLocalizedString("open_directory"),style: Theme.of(context).textTheme.labelSmall)
                                  ],
                                ),
                                onTap: selectedInstance != null ? () async {
                                  logger.d("按下${LocalizationService.getLocalizedString("remove")}按鈕");
                                  BotInstanceService.openBotInstanceFolder(selectedInstance!);
                                }:null,
                              ),
                            ),
                            //查看bot狀態
                            Material(
                              color: Colors.transparent,
                              child: ListTile(
                                hoverColor: Theme.of(context).listTileTheme.selectedColor,
                                title: Row(
                                  children: [
                                    Icon(Icons.arrow_forward,color: Theme.of(context).iconTheme.color),
                                    const SizedBox(width: 5),
                                    Text(LocalizationService.getLocalizedString("instance_info"),style: Theme.of(context).textTheme.labelSmall)
                                  ],
                                ),
                                onTap: selectedInstance != null && selectedInstance!.isProcess ? () async { //&& selectedInstance!.isProcess
                                  logger.d("按下${LocalizationService.getLocalizedString("instance_info")}按鈕");
                                  //使跳轉回來後能夠更新畫面
                                  await Navigator.push(context, MaterialPageRoute(builder: (context) => BotStatusScreen(selectedInstance!)));
                                  setState(() {});
                                }:null,
                              ),
                            ),
                            //編輯config
                            Material(
                              color: Colors.transparent,
                              child: ListTile(
                                hoverColor: Theme.of(context).listTileTheme.selectedColor,
                                title: Row(
                                  children: [
                                    Icon(Icons.play_arrow,color: Theme.of(context).iconTheme.color),
                                    const SizedBox(width: 5),
                                    Text(LocalizationService.getLocalizedString("edit_config"),style: Theme.of(context).textTheme.labelSmall)
                                  ],
                                ),
                                onTap: selectedInstance != null ? () {
                                  logger.d("按下${LocalizationService.getLocalizedString("edit_config")}按鈕");
                                  Config? config;
                                  ConfigService.getConfigFromLocalStorage().then((value) async{
                                    if(value != null)
                                    {
                                      logger.d("取得緩存，value: $value");
                                      Util.getYesNoDialog(
                                        context,
                                        Text(LocalizationService.getLocalizedString("detect_temp_dialog_content"),style: Theme.of(context).textTheme.labelSmall), 
                                        () async {
                                          logger.d("按下確認按鈕，讀取緩存");
                                          config = value;
                                          await Navigator.push(context, MaterialPageRoute(builder: (context) => ConfigEditScreen(config,selectedInstance!)));
                                          setState(() {});
                                        },
                                        () async {
                                          logger.d("按下取消按鈕，不讀取緩存");
                                          config = null;
                                          await Navigator.push(context, MaterialPageRoute(builder: (context) => ConfigEditScreen(config,selectedInstance!)));
                                          setState(() {});
                                        });
                                    }
                                    else
                                    {
                                      logger.d("沒有緩存");
                                      await Navigator.push(context, MaterialPageRoute(builder: (context) => ConfigEditScreen(config,selectedInstance!)));
                                      setState(() {});
                                    }
                                  });
                                }:null,
                              ),
                            ),
                            //編輯settings
                            Material(
                              color: Colors.transparent,
                              child: ListTile(
                                hoverColor: Theme.of(context).listTileTheme.selectedColor,
                                title: Row(
                                  children: [
                                    Icon(Icons.play_arrow,color: Theme.of(context).iconTheme.color),
                                    const SizedBox(width: 5),
                                    Text(LocalizationService.getLocalizedString("edit_setting"),style: Theme.of(context).textTheme.labelSmall)
                                  ],
                                ),
                                onTap: selectedInstance != null ? () {
                                  logger.d("按下${LocalizationService.getLocalizedString("edit_setting")}按鈕");
                                  if(selectedInstance!.type == BotType.raid)
                                  {
                                    SettingService.getRaidSettingFromLocalStorage().then((value) async {
                                      RaidSetting? raidSetting;
                                      if(value != null)
                                      {
                                        logger.d("取得緩存，value: $value");
                                        Util.getYesNoDialog(
                                          context,
                                          Text(LocalizationService.getLocalizedString("detect_temp_dialog_content"),style: Theme.of(context).textTheme.labelSmall), 
                                          () async {
                                            logger.d("按下確認按鈕，讀取緩存value:${value.toJson(BotType.raid)}");
                                            raidSetting = value;
                                            await Navigator.push(context, MaterialPageRoute(builder: (context) => RaidSettingEditScreen(raidSetting,selectedInstance!)));
                                            setState(() {});
                                          },
                                          () async {
                                            logger.d("按下取消按鈕，不讀取緩存");
                                            raidSetting = null;
                                            await Navigator.push(context, MaterialPageRoute(builder: (context) => RaidSettingEditScreen(raidSetting,selectedInstance!)));
                                            setState(() {});
                                          }
                                        );
                                      }
                                      else
                                      {
                                        logger.d("沒有緩存");
                                        await Navigator.push(context, MaterialPageRoute(builder: (context) => RaidSettingEditScreen(raidSetting,selectedInstance!)));
                                        setState(() {});
                                      }
                                    });
                                  }
                                  else if(selectedInstance!.type == BotType.emerald)
                                  {
                                    SettingService.getEmeraldSettingFromLocalStorage().then((value) async {
                                      EmeraldSetting? emeraldSetting;
                                      if(value != null)
                                      {
                                        logger.d("取得緩存，value: $value");
                                        Util.getYesNoDialog(
                                          context,
                                          Text(LocalizationService.getLocalizedString("detect_temp_dialog_content"),style: Theme.of(context).textTheme.labelSmall), 
                                          () async {
                                            logger.d("按下確認按鈕，讀取緩存");
                                            emeraldSetting = value;
                                            await Navigator.push(context, MaterialPageRoute(builder: (context) => EmeraldSettingEditScreen(emeraldSetting,selectedInstance!)));
                                            setState(() {});
                                          },
                                          () async {
                                            logger.d("按下取消按鈕，不讀取緩存");
                                            emeraldSetting = null;
                                            await Navigator.push(context, MaterialPageRoute(builder: (context) => EmeraldSettingEditScreen(emeraldSetting,selectedInstance!)));
                                            setState(() {});
                                          }
                                        );
                                      }
                                      else
                                      {
                                        logger.d("沒有緩存");
                                        await Navigator.push(context, MaterialPageRoute(builder: (context) => EmeraldSettingEditScreen(emeraldSetting,selectedInstance!)));
                                        setState(() {});
                                      }
                                    });
                                  }
                                }:null,
                              ),
                            ),
                          ]
                        )
                      ),
                      FutureBuilder(
                        future: Util.getProjectVersion(),
                        builder: (context, snapshot) {
                          if(snapshot.connectionState == ConnectionState.waiting)
                          {
                            return const SizedBox();
                          }
                          else
                          {
                            return Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 10),
                              child: Text(
                                LocalizationService.getLocalizedString("app_version").replaceFirst('%version%', snapshot.data.toString())
                                ,style: Theme.of(context).textTheme.labelSmall)
                            );
                          }
                        },
                      )
                    ],
                  )
                )
              ],
            ),
          ),
          //正在執行中的遮擋物
          Visibility(
            visible: isProcessing,
            child: Util.getLoadingWidget(context, currentStatus),
          )
        ]
      )
    );
  }
}