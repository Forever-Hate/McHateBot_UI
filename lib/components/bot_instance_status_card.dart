import 'package:flutter/material.dart' hide NetworkImage;

import 'package:marqueer/marqueer.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../components/half_filled_icon.dart';
import '../components/network_image.dart';
import '../models/bot_instance.dart';
import '../models/player.dart';
import '../services/inventory_service.dart';
import '../services/minecraft_service.dart';
import '../services/localization_service.dart';
import '../utils/config.dart';
import '../utils/util.dart';
import '../utils/logger.dart';

/// Bot實例狀態的卡片
class BotInstanceStatusCard extends StatefulWidget {
  final Player player;
  final BotInstance instance;

  const BotInstanceStatusCard(this.instance, this.player, {Key? key}) : super(key: key);

  @override
  State<BotInstanceStatusCard> createState() => _BotInstanceStatusCardState();
}

class _BotInstanceStatusCardState extends State<BotInstanceStatusCard> {
  // 跑馬燈controller
  final controller = MarqueerController();
  
  // 取得玩家頭像的Future
  late Future avatarFuture;

  /// 經驗條
  Widget getExperienceIndicator(BuildContext context)
  {
    logger.i("取得經驗值顯示");
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(top:10),
          child: Text(LocalizationService.getLocalizedString("experience"),style: Theme.of(context).textTheme.labelSmall)
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(LocalizationService.getLocalizedString("level").replaceFirst('%level%', widget.player.level.toString()),style: Theme.of(context).textTheme.labelSmall),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 2,
                ),
              ),
              width: 280,
              child: Tooltip(
                message: LocalizationService.getLocalizedString("experience_bar_tooltip").replaceFirst('%points%', widget.player.points.toString()),
                child: LinearPercentIndicator(
                  padding: const EdgeInsets.all(0),
                  lineHeight: 20.0,
                  percent: widget.player.progress,
                  center: Text(
                    "${(widget.player.progress * 100).toStringAsFixed(2)}%",
                    style: const TextStyle
                    (
                      color: Colors.black,
                      fontSize: 12
                    )
                  ),
                  barRadius: const Radius.circular(10),
                  progressColor: Colors.greenAccent[400],
                ),
              ),
            )
          ],
        )
      ],
    );
  }
  
  /// 生命值
  Widget getHealthIndicator(BuildContext context)
  {
    logger.i("取得生命值顯示");
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(LocalizationService.getLocalizedString("health"),style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(width: 10),
        ...List.generate(widget.player.health ~/ 2, (index) => const Icon(Icons.favorite,color: Colors.redAccent,size: 20)),
        ...List.generate(widget.player.health % 2, (index) => const HalfFilledIcon(Icons.favorite,20,Colors.redAccent)),
        ...List.generate((20- widget.player.health) ~/ 2, (index) => Icon(Icons.favorite,color: Colors.grey[300],size: 20)),
      ],
    );
  }
  
  /// 飢餓值
  Widget getFoodIndicator(BuildContext context)
  {
    logger.i("取得飢餓值顯示");
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(LocalizationService.getLocalizedString("food"),style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(width: 10),
        ...List.generate(widget.player.food ~/ 2, (index) => const Icon(Icons.favorite,color: Colors.redAccent,size: 20)),
        ...List.generate(widget.player.food % 2, (index) => const HalfFilledIcon(Icons.favorite,20,Colors.redAccent)),
        ...List.generate((20- widget.player.food) ~/ 2, (index) => Icon(Icons.favorite,color: Colors.grey[300],size: 20)),
      ],
    );
  }
  
  /// 物品欄
  Widget getInventoryIndicator(BuildContext context)
  {
    ///取得物品欄物品
    Widget getItem(Item item)
    {
      return Tooltip(
        message: '${item.name} x ${item.count}',
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover, 
                  image: MemoryImage(InventoryService.getTextureFromName(item.name)!)
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                item.count.toString(),
                style: Theme.of(context).textTheme.labelMedium
              )
            )
          ],
        )
      );
    }
    logger.i("取得背包顯示");
    List<Item> hotBarItems = [];
    hotBarItems.addAll(widget.player.items.where((item) => item.slot >= 36 && item.slot <= 44));
    widget.player.items.removeWhere((item) => item.slot >= 36 && item.slot <= 44);
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).cardColor,
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(LocalizationService.getLocalizedString("inventory_title"),style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 10),
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage('assets/icons/inventory.png'),
                          fit: BoxFit.fill
                        ),
                        borderRadius: BorderRadius.circular(10)
                      ),
                      width: 400,
                      height: 200,
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 16, top: 15, right: 15),
                      width: 400,
                      height: 180,
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 9,  //每行9個
                          mainAxisSpacing: 2, //主軸間距
                        ),
                        itemCount: widget.player.items.length,
                        itemBuilder: (context, index) {
                          final texture = InventoryService.getTextureFromName(widget.player.items[index].name);
                          if (texture == null)
                          {
                            return Container(
                              decoration: BoxDecoration(
                                image: const DecorationImage(
                                  //待更改
                                  image: AssetImage('assets/icons/McHateBot_raid.png'),
                                  fit: BoxFit.fill
                                ),
                                borderRadius: BorderRadius.circular(10)
                              ),
                            );
                          }
                          else
                          {
                            return getItem(widget.player.items[index]);
                          }
                        }
                      ),
                    ),
                    Container(
                      width: 400,
                      height: 50,
                      padding: const EdgeInsets.only(left:15,right: 14),
                      margin: const EdgeInsets.only(top: 147),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 9,  //每行9個
                          mainAxisSpacing: 2, //主軸間距
                        ),
                        itemCount: hotBarItems.length,
                        itemBuilder: (context, index) {
                          final texture = InventoryService.getTextureFromName(hotBarItems[index].name);
                          if (texture == null)
                          {
                            return Container(
                              decoration: BoxDecoration(
                                image: const DecorationImage(
                                  image: AssetImage('assets/icons/McHateBot_raid.png'),
                                  fit: BoxFit.fill
                                ),
                                borderRadius: BorderRadius.circular(10)
                              ),
                            );
                          }
                          else
                          {
                            return getItem(hotBarItems[index]);
                          }
                        }
                      ),
                    )
                  ],
                )
              ],
            )
          )
        )
      ]
    );
  }

  /// 伺服器詳細資訊
  Widget getServerDetailIndicator(BuildContext context)
  {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 2,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(LocalizationService.getLocalizedString("current_server").replaceFirst('%server%', widget.player.server.toString()),style: Theme.of(context).textTheme.labelSmall),
                    const SizedBox(height: 10),
                    Text(LocalizationService.getLocalizedString("current_position").replaceFirst('%position%', widget.player.position.toString()),style: Theme.of(context).textTheme.labelSmall),
                    const SizedBox(height: 10),
                    getExperienceIndicator(context),
                    const SizedBox(height: 10),
                    Text(LocalizationService.getLocalizedString("money").replaceFirst("%money%", widget.player.money.toString()),style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
                Container(
                  height: 150,
                  alignment: Alignment.center,
                  child: const VerticalDivider(
                    width: 20,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(LocalizationService.getLocalizedString("current_players").replaceFirst('%current_players%', widget.player.currentPlayers.toString()),style: Theme.of(context).textTheme.labelSmall),
                    const SizedBox(height: 10),
                    Text(LocalizationService.getLocalizedString("targeted_block").replaceFirst('%block%', widget.player.targetedBlock.toString()),style: Theme.of(context).textTheme.labelSmall),
                    const SizedBox(height: 10),
                    Text(LocalizationService.getLocalizedString("coin").replaceFirst('%coin%', widget.player.coin.toString()),style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
              ],
            )
          ),
        ),
        
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    avatarFuture = MinecraftService.getAvatarsFromUuid(widget.player.uuid);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder(
                future: avatarFuture,
                builder:(context, snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting)
                  {
                    return const SizedBox(
                      width: 75,
                      height: 75,
                      child: CircularProgressIndicator(),
                    );
                  }
                  else
                  {
                    logger.d(snapshot.data!);
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        NetworkImage(
                          src: snapshot.data!,
                          width: 75,
                          height: 75,
                          errorWidget: const Icon(Icons.person,size: 75),
                        ),
                        const SizedBox(height: 5),
                        SizedBox(
                          width: 100,
                          height: 30,
                          child: widget.player.username.length >= MAX_USERNAME_LENGTH ? 
                          MouseRegion(
                            onHover: (event) {
                              controller.start();
                            },
                            onExit: (event) {
                              controller.stop();
                            },
                            child: Marqueer(
                              autoStart: false,
                              controller: controller,
                              pps: 60, //速度
                              separatorBuilder: (context, index) => const SizedBox(width: 20), // 跑馬燈文字間距
                              direction: MarqueerDirection.rtl,  // 跑馬燈方向
                              restartAfterInteractionDuration: const Duration(seconds: 1), // 跑馬燈停止後重新啟動的時間
                              padding: const EdgeInsets.only(left:20), // 跑馬燈左右間距(初始)
                              child: Text(
                                widget.instance.username,
                                style: Theme.of(context).textTheme.labelSmall
                              ),
                            ),
                          ):
                          Text(
                            widget.instance.username != "" ? widget.instance.username : LocalizationService.getLocalizedString("not_user_configured"),
                            style: Theme.of(context).textTheme.labelSmall,
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    );
                  }
                }
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Tooltip(
                        message: widget.player.health.toString(),
                        child: getHealthIndicator(context),
                      ),
                      const SizedBox(height: 10),
                      Tooltip(
                        message: widget.player.food.toString(),
                        child: getFoodIndicator(context)
                      ),
                      const SizedBox(height: 10),
                      Text(LocalizationService.getLocalizedString("tps").replaceFirst('%tps%', widget.player.tps.toString()),style: Theme.of(context).textTheme.labelSmall),
                      const SizedBox(height: 10),
                      Text(LocalizationService.getLocalizedString("operating_time").replaceFirst("%time%", Util.formatDuration(Duration(seconds: widget.instance.duration))),style: Theme.of(context).textTheme.labelSmall),
                    ],
                  )
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child:Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(LocalizationService.getLocalizedString("connected_ip").replaceFirst('%ip%', widget.player.ip),style: Theme.of(context).textTheme.labelSmall),
                      const SizedBox(height: 10),
                      Text(LocalizationService.getLocalizedString("uuid").replaceFirst('%uuid%', widget.player.uuid),style: Theme.of(context).textTheme.labelSmall),
                      const SizedBox(height: 10),
                      Text(LocalizationService.getLocalizedString("game_version").replaceFirst('%version%', widget.player.version),style: Theme.of(context).textTheme.labelSmall),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(LocalizationService.getLocalizedString("operating_status"),style: Theme.of(context).textTheme.labelSmall),
                          Text(LocalizationService.getLocalizedString("operating_status_online"),style: Theme.of(context).textTheme.labelSmall),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.check,
                                color: Theme.of(context).primaryColor,
                                size: 15,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  )
                )
              )
            ],
          ),
          const SizedBox(height: 10),
          getServerDetailIndicator(context),
          const SizedBox(height: 10),
          getInventoryIndicator(context),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}