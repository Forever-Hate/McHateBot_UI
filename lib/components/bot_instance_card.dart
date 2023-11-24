import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart' hide NetworkImage;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:web_socket_channel/io.dart';
import 'package:marqueer/marqueer.dart';

import '../components/network_image.dart';
import '../components/login_dialog.dart';
import '../models/bot_instance.dart';
import '../models/player.dart';
import '../models/track.dart';
import '../screens/bot_status_screen.dart';
import '../services/bot_instance_service.dart';
import '../services/minecraft_service.dart';
import '../services/localization_service.dart';
import '../utils/config.dart';
import '../utils/util.dart';
import '../utils/logger.dart';

/// BotInstanceCard
class BotInstanceCard extends StatefulWidget {
  final BotInstance instance;
  final bool isSelected;
  final Function(BotInstance) onSelected;
  final Function(BotInstance) onLaunch;
  final Function(BotInstance) onClose;
  const BotInstanceCard(this.instance,this.isSelected,this.onSelected,this.onLaunch,this.onClose,{super.key});

  @override
  State<BotInstanceCard> createState() => _BotInstanceCardState();
}

class _BotInstanceCardState extends State<BotInstanceCard> {
  IOWebSocketChannel? fullTrackChannel,playerChannel;
  Track? fullTrack;
  Player? player;

  //process的stderr stream
  StreamSubscription? stderrSubscription,stdoutSubscription;
  
  // 是否已經顯示錯誤訊息
  bool isShowdErrorDialog = false;
  // 是否已經連結過websocket
  bool isConnectedWebsocket = false;
  // 跑馬燈controller
  final controller = MarqueerController();

  /// 連線到websocket
  Future<void> connectWebsocket() async {
    try
    {
      if(widget.instance.type == BotType.raid)
      {
        final ws = await WebSocket.connect('ws://${dotenv.env['IP']}:${widget.instance.websocketPort}/fullTrack').timeout(const Duration(seconds: 30));
        fullTrackChannel = IOWebSocketChannel(ws);
        fullTrackChannel!.stream.listen(
          (data){
            try
            {
              fullTrack = Track.fromJson(jsonDecode(data.toString()));
              setState(() {});
            }
            catch(e)
            {
              fullTrack = null;
            }
          },
          onDone: () {
            logger.e("fullTrackChannel已關閉(BotInstanceCard)");
            // player = null;
            // fullTrack = null;
            // if(mounted && ModalRoute.of(context)!.isCurrent && widget.instance.isProcess)
            // {
            //   Util.getMessageDialog(context,"連線已關閉", () {
            //     widget.onClose(widget.instance);
            //   });
            // }
            // playerChannel!.sink.close();
            // fullTrackChannel!.sink.close();
          },
        );
      }
      final ws2 = await WebSocket.connect('ws://${dotenv.env['IP']}:${widget.instance.websocketPort}/player').timeout(const Duration(seconds: 30));
      playerChannel = IOWebSocketChannel(ws2);
      playerChannel!.stream.listen(
        (data){
          try
          {
            player = Player.fromJson(jsonDecode(data.toString()));
            setState(() {});
          }
          catch(e)
          {
            player = null;
          }
        },
        onDone: (){
          logger.e("playerChannel已關閉(BotInstanceCard)");
        }
      );
    }
    catch(e)
    {
      logger.e(e);
      player = null;
      fullTrack = null;
      setState(() {
        Util.getMessageDialog(context,"websocket連線發生錯誤", () {
          BotInstanceService.closeBotInstance(widget.instance);
        });
      });
      
    }
  }
  
  @override
  void didUpdateWidget(covariant BotInstanceCard oldWidget) {
    logger.i("進入didUpdateWidget");
    super.didUpdateWidget(oldWidget);
    if(widget.instance.isProcess)
    {
      //再次進來時重新連線
      if(isConnectedWebsocket)
      {
        connectWebsocket();
      }
      
      stderrSubscription?.cancel();
      stderrSubscription = widget.instance.stderrStream!.transform(utf8.decoder).listen((event) {
        logger.e(event.toString());
        //如果不是ECONNRESET(斷線錯誤)，就顯示錯誤訊息
        if(!event.toString().contains("ECONNRESET"))
        {
          logger.d("不是ECONNRESET錯誤");
          if(!isShowdErrorDialog)
          {
            logger.d("未顯示過錯誤訊息");
            isShowdErrorDialog = true;
            Util.getMessageDialog(context,event.toString(), () {
              isShowdErrorDialog = false;
              widget.onClose(widget.instance);
              //如果不是當前頁面，就pop掉返回到主畫面
              if(!ModalRoute.of(context)!.isCurrent)
              {
                Navigator.pop(context);
              }
            },suffix: LocalizationService.getLocalizedString("bot_error_suffix").replaceFirst('%bot%', widget.instance.username));
          }
          else
          {
            logger.d("已顯示過錯誤訊息");
          }
        }
      });

      stdoutSubscription?.cancel();
      stdoutSubscription = widget.instance.stdoutStream!.transform(utf8.decoder).listen((event) {
        logger.d('${widget.instance.username} stdout: ${event.toString()}');
        if(event.toString().contains("[msa] First time signing in. Please authenticate now:"))
        {
          stdoutSubscription!.cancel();
          showDialog(
            barrierDismissible: false, //點擊空白處不關閉
            context: context, 
            builder: (context){
              return LoginDialog(widget.instance,event.toString(),(){
                stdoutSubscription = widget.instance.stdoutStream!.transform(utf8.decoder).listen((event) {
                  logger.d('${widget.instance.username} stdout: ${event.toString()}');
                });
              });
            }
          );
        }
        //確保伺服器已開啟才進行連線
        if(event.toString().contains("Server is running on port"))
        {
          logger.d("伺服器已開啟");
          isConnectedWebsocket = true;
          connectWebsocket();
        }
      });
    }
    else
    {
      //中止時關閉連線
      fullTrackChannel?.sink.close();
      playerChannel?.sink.close();
      stderrSubscription?.cancel();
      stdoutSubscription?.cancel();
      isConnectedWebsocket = false;
      isShowdErrorDialog = false;
      player = null;
      fullTrack = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    logger.i("進入BotInstanceCard");
    return GestureDetector(
      onTap: () {
        logger.d("點擊1次");
        widget.onSelected(widget.instance);
      },
      onDoubleTap: () {
        logger.d("點擊2次");
        widget.onLaunch(widget.instance);
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color:Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: widget.isSelected ?  Theme.of(context).dividerColor: Theme.of(context).primaryColor,
            width: 3,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color:widget.isSelected ? Theme.of(context).listTileTheme.selectedColor : Colors.transparent,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/icons/${widget.instance.type.value}.png'),
                            fit: BoxFit.fill
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        width: 60,
                        height: 60,
                      ),
                      SizedBox(
                        width: 100,
                        height: 30,
                        child: widget.instance.username.length >= MAX_USERNAME_LENGTH ? 
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
                  ),
                ),
                Visibility(
                  visible: widget.instance.isProcess,
                  child: Container(
                    width: 25, 
                    height: 25, 
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black,
                        width: 2
                      ),
                      color: Colors.blue, 
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.play_arrow,
                        size: 15, 
                        color: Colors.white,
                      ),
                    ),
                  )
                ),
              ],
            ),
            const SizedBox(width: 5),
            Visibility(
              visible: widget.instance.isProcess,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.instance.type == BotType.raid ?
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        ColorFiltered(
                          colorFilter: ColorFilter.mode(Theme.of(context).textTheme.labelSmall!.color!, BlendMode.modulate), 
                          child:SizedBox(
                            width: 32,
                            height: 32,
                            child: Image.asset('assets/icons/emerald.png'),
                          )
                        ),
                        const SizedBox(width: 5),
                        Text(
                          fullTrack?.average['emerald'] ?? LocalizationService.getLocalizedString("empty"),
                          style: Theme.of(context).textTheme.labelSmall,
                        )
                      ],
                    ),
                  ):
                  const SizedBox(height: 30),
                  const SizedBox(height: 5),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ColorFiltered(
                          colorFilter: ColorFilter.mode(Theme.of(context).textTheme.labelSmall!.color!, BlendMode.modulate), 
                          child:SizedBox(
                            width: 32,
                            height: 32,
                            child: Image.asset('assets/icons/timer.png'),
                          )
                        ),
                        const SizedBox(width: 5),
                        Text(
                          LocalizationService.getLocalizedString("operating_time").replaceFirst('%time%', Util.formatDuration(Duration(seconds: widget.instance.duration))),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        ColorFiltered(
                          colorFilter: ColorFilter.mode(Theme.of(context).textTheme.labelSmall!.color!, BlendMode.modulate), 
                          child:SizedBox(
                            width: 32,
                            height: 32,
                            child: Image.asset('assets/icons/money.png'),
                          )
                        ),
                        const SizedBox(width: 5),
                        Text(
                          LocalizationService.getLocalizedString("money").replaceFirst('%money%', player?.money ?? "0"),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      )
    );
  }
}

/// BotInstanceCard 的 ListTile 版本(放在Drawer裡面)
class BotInstanceCardInListTile extends StatefulWidget {
  final BotInstance instance;
  const BotInstanceCardInListTile(this.instance,{super.key});

  @override
  State<BotInstanceCardInListTile> createState() => _BotInstanceCardInListTileState();
}

class _BotInstanceCardInListTileState extends State<BotInstanceCardInListTile> {
  final controller = MarqueerController();
  @override
  Widget build(BuildContext context) {
    logger.i("進入BotInstanceCardInListTile");
    return Container(
      margin: const EdgeInsets.only(left:10,right:10,top:5,bottom:5),
      child: GestureDetector(
        onDoubleTap: () {
          logger.d("點擊2次");
          Navigator.push(context, MaterialPageRoute(builder: (context) => BotStatusScreen(widget.instance)));
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                FutureBuilder(
                  future: MinecraftService.getAvatarsFromUuid(widget.instance.botUuid),
                  builder:(context, snapshot) {
                    if(snapshot.connectionState == ConnectionState.waiting)
                    {
                      return const SizedBox(
                        width: 70,
                        height: 70,
                        child: CircularProgressIndicator(),
                      );
                    }
                    else
                    {
                      logger.d(snapshot.data!);
                      return Column(
                        children: [
                          NetworkImage(
                            src: snapshot.data!,
                            width: 70,
                            height: 70,
                            errorWidget: const Icon(Icons.person,size: 70)
                          ),
                        ],
                      );
                    }

                  }
                ),
                SizedBox(
                  width: 100,
                  height: 30,
                  child: widget.instance.username.length >= MAX_USERNAME_LENGTH ? 
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
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocalizationService.getLocalizedString("bot_type").replaceFirst("%bot_type%", widget.instance.type.value),
                    style: Theme.of(context).textTheme.labelSmall
                  ),
                  StreamBuilder(
                    stream: widget.instance.stderrStream,
                    builder: (context, snapshot) {
                      if(snapshot.hasData)
                      {
                        return Row(
                          children: [
                            Text(LocalizationService.getLocalizedString("operating_status_offline"),style: Theme.of(context).textTheme.labelSmall),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red,
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.close,
                                  color: Theme.of(context).iconTheme.color,
                                  size: 15,
                                ),
                              ),
                            )
                          ],
                        );
                      }
                      else
                      {
                        return Row(
                          children: [
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
                                  color: Theme.of(context).iconTheme.color,
                                  size: 15,
                                ),
                              ),
                            )
                          ],
                        );
                      }
                    },
                  ),
                ],
              )
            )
          ],
        ),
      ),
    );
  }
}