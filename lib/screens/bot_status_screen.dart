import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:html/parser.dart';
import 'package:html/dom.dart' as dom;
import 'package:web_socket_channel/io.dart';

import '../components/bot_instance_status_card.dart';
import '../components/message_scrollview.dart';
import '../models/player.dart';
import '../models/bot_instance.dart';
import '../screens/track_screen.dart';
import '../screens/store_emerald_screen.dart';
import '../services/localization_service.dart';
import '../utils/logger.dart';
import '../utils/util.dart';

/// bot資訊頁面
class BotStatusScreen extends StatefulWidget {
  final BotInstance instance;
  const BotStatusScreen(this.instance, {super.key});

  @override
  State<BotStatusScreen> createState() => _BotStatusScreenState();
}

class _BotStatusScreenState extends State<BotStatusScreen> {
  IOWebSocketChannel? playerChannel;
  StreamController streamController = StreamController();
  
  // 是否正在連接到websocket 
  bool isConnecting = true;

  Future<void> connectWebsocket() async {
    try {
      final ws = await WebSocket.connect('ws://${dotenv.env['IP']}:${widget.instance.websocketPort}/player').timeout(const Duration(seconds: 5));
      playerChannel = IOWebSocketChannel(ws);
      playerChannel!.stream.listen(
        (data){
          streamController.add(data);
        },
        onDone: () {
          logger.e("playerChannel已關閉");
          //如果mounted為true，表示widget還沒被dispose
          
          // if(mounted)
          // {
          //   Util.getMessageDialog(context,"連線已關閉", () {
          //     BotInstanceService.closeBotInstance(widget.instance);
          //     Navigator.pop(context);
          //   });
          // }
        },
        onError: (error) {
          logger.e("playerChannel發生錯誤");
          // Util.getMessageDialog(context,"連線發生錯誤", () {
          //   Navigator.pop(context);
          // });
        },
      );
      isConnecting = false;
    } catch (e) {
      logger.e(e);
      Util.getMessageDialog(context,"連線發生錯誤", () {
        Navigator.pop(context);
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if(playerChannel != null)
    {
      playerChannel!.sink.close();
    }
    streamController.close();
    super.dispose();
  }

  //解析html
  Future<dom.Document> parseHtml(html) async {
    return parse(html);
  }
  @override
  Widget build(BuildContext context) {
    logger.i("進入BotStatusScreen");
    return DefaultTabController(
      length: 2, 
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: TabBar(
            labelColor: Theme.of(context).textTheme.labelSmall!.color,
            tabs: [
              Tab(text: LocalizationService.getLocalizedString("bot_status_tab")),
              widget.instance.type == BotType.raid ? Tab(text: LocalizationService.getLocalizedString("track_tab")) : Tab(text: LocalizationService.getLocalizedString("save_emerald_tab")),
            ],
          ),
        ),
        body: FutureBuilder(
          future: connectWebsocket(),
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.done && !isConnecting)
            {
              return TabBarView(
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 40,right: 40,top:10,bottom: 10),
                    color: Theme.of(context).primaryColor,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          StreamBuilder(
                            stream: streamController.stream,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) 
                              {
                                Player player;
                                try
                                {
                                  player = Player.fromJson(jsonDecode(snapshot.data));
                                }
                                catch(e)
                                {
                                  return Row(
                                    children: [
                                      Text(LocalizationService.getLocalizedString("operating_status"),style: Theme.of(context).textTheme.labelSmall),
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
                                            color: Theme.of(context).primaryColor,
                                            size: 15,
                                          ),
                                        ),
                                      )
                                    ],
                                  );
                                }
                                return  Column(
                                  children: [
                                    BotInstanceStatusCard(widget.instance,player)
                                  ]
                                );
                              }
                              else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              }
                              else 
                              {
                                return Center(
                                  child: Text(LocalizationService.getLocalizedString("now_loading"),style: Theme.of(context).textTheme.labelSmall),
                                );
                              }
                            }
                          ),
                          MessageScrollView(widget.instance)
                        ]),
                    )
                  ),
                  widget.instance.type == BotType.raid ?
                  TrackScreen(widget.instance):
                  const StoreEmeraldScreen()
                ],
              );
            }
            else
            {
              return Util.getLoadingWidget(context, LocalizationService.getLocalizedString("now_loading")); 
            }
          },
        )
      )
    );
  }
      
      
      
      
      
      
      

  
}
