import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:web_socket_channel/io.dart';

import '../components/clock_view.dart';
import '../components/line_chart_viewer.dart';
import '../models/bot_instance.dart';
import '../models/track.dart';
import '../services/inventory_service.dart';
import '../services/localization_service.dart';
import '../utils/logger.dart';
import '../utils/util.dart';

///拾取紀錄頁面
class TrackScreen extends StatefulWidget {
  final BotInstance instance;
  const TrackScreen(this.instance,{super.key});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> with AutomaticKeepAliveClientMixin<TrackScreen> {
  IOWebSocketChannel? currentTrackChannel;
  IOWebSocketChannel? fullTrackChannel;
  IOWebSocketChannel? trackLogsChannel;

  Track? currentTrack,fullTrack,lastTrack;

  // 紀錄列表
  Queue<Track> trackList = Queue();

  // 連線到websocket的Future 
  Future? _connectFuture;

  // 最高效率
  int highestEfficiency = 0;

  // 最高效率單位(後綴)
  String? highestEfficiencySuffix;
  /// 連線到websocket
  Future<void> connectWebsocket() async {
    try {
      final ws = await WebSocket.connect('ws://${dotenv.env['IP']}:${widget.instance.websocketPort}/currentTrack').timeout(const Duration(seconds: 5));
      fullTrackChannel = IOWebSocketChannel.connect('ws://${dotenv.env['IP']}:${widget.instance.websocketPort}/fullTrack');
      trackLogsChannel = IOWebSocketChannel.connect('ws://${dotenv.env['IP']}:${widget.instance.websocketPort}/trackLogs');
      currentTrackChannel = IOWebSocketChannel(ws);
      currentTrackChannel!.stream.listen(
        (data){
          logger.d("currentTrackChannel: $data");
          try
          {
            currentTrack = Track.fromJson(jsonDecode(data.toString()));
            setState(() {});
          }
          catch(e)
          {
            currentTrack = null;
          }
        },
        onDone: () {
          logger.e("currentTrackChannel已關閉");
        },
        onError: (error) {
          logger.e("currentTrackChannel發生錯誤");
        },
      );
    
      fullTrackChannel!.stream
      .listen((event) {
        logger.d("fullTrackChannel: $event");
        try
        {
          fullTrack = Track.fromJson(jsonDecode(event.toString()));
          setState(() {});
        }
        catch(e)
        {
          fullTrack = null;
        }
      });
      trackLogsChannel!.stream
      .listen((event) {
        logger.d("trackLogsChannel: $event");
        try
        {
          List<dynamic> trackLogs = jsonDecode(event.toString());
          if(trackLogs.isNotEmpty)
          {
            if(trackList.isNotEmpty)
            {
              trackList.add(Track.fromJson(trackLogs.last));
            }
            else
            {
              for(var track in trackLogs)
              {
                trackList.add(Track.fromJson(track));
              }
            }
            if(trackList.length > 25)
            {
              trackList.removeFirst();
            }
          }
          lastTrack = trackList.last;
          if (lastTrack!.items.isNotEmpty) 
          {
            logger.d("lastTrack items不為空");
            if(lastTrack!.items.containsKey("emerald"))
            {
              //如果最後一筆的綠寶石數量大於highestEfficiency，則更新highestEfficiency
              if(lastTrack!.items['emerald'] > highestEfficiency)
              {
                highestEfficiency = lastTrack!.items['emerald']!;
                logger.d(highestEfficiency);  // 100
              }
              if(highestEfficiencySuffix == null)
              {
                String input = lastTrack!.average['emerald']!;
                int index = input.indexOf("個");

                if (index != -1) {
                  highestEfficiencySuffix = input.substring(index);
                  logger.d(highestEfficiencySuffix);  // "個/小時"
                }
              }
            }
          }
          logger.d("${lastTrack!.startTime} ~ ${lastTrack!.endTime}");
          setState(() {});
        }
        catch(e)
        {
          lastTrack = null;
        }
      });
    } catch (e) {
      logger.e(e);
    }
  }
  
  @override
  void initState() {
    super.initState();
    _connectFuture = connectWebsocket();
  }

  @override
  void dispose() {
    currentTrackChannel!.sink.close();
    fullTrackChannel!.sink.close();
    trackLogsChannel!.sink.close();
    super.dispose();
  }
  
  @override
  bool get wantKeepAlive => true;
  
  /// 取得物品顯示區塊
  Widget getItemViewer(Track track)
  {
    if(track.items.isEmpty)
    {
      return Text(LocalizationService.getLocalizedString("no_record"),style: Theme.of(context).textTheme.labelSmall);
    }
    return Column(
      children: [
        SizedBox(
          width: 500,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(LocalizationService.getLocalizedString("item_title"),style: Theme.of(context).textTheme.titleSmall),
              Text(LocalizationService.getLocalizedString("efficiency_title"),style: Theme.of(context).textTheme.titleSmall)
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(5),
          ),
          height: track.items.length * 60.0,
          width: 500,
          child: Row(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: track.items.length,
                  itemBuilder: (context,index) {
                    String name = track.items.keys.toList()[index];
                    return Tooltip(
                      message: name,
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Image.memory(InventoryService.getTextureFromName(name)!,scale:0.5,width: 50,height: 50),
                          ),
                          const SizedBox(width: 10),
                          Text(LocalizationService.getLocalizedString("item_unit").replaceFirst('%name%', track.items[name]),style: Theme.of(context).textTheme.labelSmall),
                        ],
                      ),
                    );
                  }
                )
              ),
              const VerticalDivider(
                width: 20,
                indent: 5,
                endIndent: 5,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: track.items.length,
                  itemBuilder: (context,index) {
                    String name = track.average.keys.toList()[index];
                    return Tooltip(
                      message: name,
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Image.memory(InventoryService.getTextureFromName(name)!,scale:0.5,width: 50,height: 50),
                          ),
                          const SizedBox(width: 10),
                          Text("${track.average[name]}",style: Theme.of(context).textTheme.labelSmall),
                        ],
                      ),
                    );
                  }
                )
              )
            ],
          )
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    logger.i("進入TrackScreen");
    return FutureBuilder(
      future: _connectFuture,
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting)
        {
          return Util.getLoadingWidget(context,LocalizationService.getLocalizedString("now_loading"));
        }
        else
        {
          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.all(10),
            color: Theme.of(context).scaffoldBackgroundColor,
            child:SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 3), 
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(LocalizationService.getLocalizedString("total_emerald_title"),style: Theme.of(context).textTheme.titleSmall),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.memory(InventoryService.getTextureFromName("emerald")!,scale:0.1,width:50,height: 50),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: FittedBox(
                                      fit: BoxFit.fitWidth,
                                      child: Text(fullTrack != null ? (fullTrack!.items['emerald'] ?? LocalizationService.getLocalizedString("empty")).toString() : LocalizationService.getLocalizedString("empty"),style: Theme.of(context).textTheme.titleMedium)
                                    )
                                  )
                                ],
                              )
                            ],
                          ),
                        )
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 3), 
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(LocalizationService.getLocalizedString("highest_efficiency_title"),style: Theme.of(context).textTheme.titleSmall),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.memory(InventoryService.getTextureFromName("emerald")!,scale:0.1,width:50,height: 50),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: FittedBox(
                                      fit: BoxFit.fitWidth,
                                      child: Text(highestEfficiencySuffix != null && highestEfficiency != 0 ? 
                                        "${Util.formatThousand(highestEfficiency)}$highestEfficiencySuffix":
                                        LocalizationService.getLocalizedString("empty")
                                        ,style: Theme.of(context).textTheme.titleMedium
                                      )
                                    )
                                  )
                                ],
                              )
                            ],
                          ),
                        )
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child:Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 3), 
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(LocalizationService.getLocalizedString("latest_efficiency_title"),style: Theme.of(context).textTheme.titleSmall),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.memory(InventoryService.getTextureFromName("emerald")!,scale:0.1,width:50,height: 50),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: FittedBox(
                                      fit: BoxFit.fitWidth,
                                      child: Text(currentTrack != null ? (currentTrack!.average['emerald']?? LocalizationService.getLocalizedString("empty")).toString() : LocalizationService.getLocalizedString("empty"),style: Theme.of(context).textTheme.titleMedium)
                                    )
                                  )
                                ],
                              )
                            ],
                          ),
                        )
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(LocalizationService.getLocalizedString("current_track_title"),style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 10),
                  currentTrack != null ?
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("${LocalizationService.getLocalizedString("start_time_title")} ${currentTrack!.startTime}",style: Theme.of(context).textTheme.labelSmall),
                      const SizedBox(width: 10),
                      ClockView(currentTrack!.startTime),
                      Text("${LocalizationService.getLocalizedString("end_time_title")} ${currentTrack!.endTime}",style: Theme.of(context).textTheme.labelSmall),
                      const SizedBox(width: 10),
                      ClockView(currentTrack!.endTime),
                      Text("${LocalizationService.getLocalizedString("total_time_title")} ${currentTrack!.totalTime}",style: Theme.of(context).textTheme.labelSmall),
                      getItemViewer(currentTrack!)
                    ],
                  ) : Text(LocalizationService.getLocalizedString("no_record"),style: Theme.of(context).textTheme.labelSmall),
                  const SizedBox(height: 10),
                  const Divider(),
                  Text(LocalizationService.getLocalizedString("total_track_title"),style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 10),
                  fullTrack != null ?
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("${LocalizationService.getLocalizedString("start_time_title")} ${fullTrack!.startTime}",style: Theme.of(context).textTheme.labelSmall),
                      const SizedBox(width: 10),
                      ClockView(fullTrack!.startTime),
                      Text("${LocalizationService.getLocalizedString("end_time_title")} ${fullTrack!.endTime}",style: Theme.of(context).textTheme.labelSmall),
                      const SizedBox(width: 10),
                      ClockView(fullTrack!.endTime),
                      Text("${LocalizationService.getLocalizedString("total_time_title")} ${fullTrack!.totalTime}",style: Theme.of(context).textTheme.labelSmall),
                      getItemViewer(fullTrack!)
                    ],
                  ) : Text(LocalizationService.getLocalizedString("no_record"),style: Theme.of(context).textTheme.labelSmall),
                  const SizedBox(height: 10),
                  const Divider(),
                  Text(LocalizationService.getLocalizedString("history_track_title"),style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 10),
                  trackList.isNotEmpty ?
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      LineBarViewer(trackList.toList()),
                    ],
                  ) : Text(LocalizationService.getLocalizedString("no_record"),style: Theme.of(context).textTheme.labelSmall),
                ],
              )
            )
          );  
        }
      },
    );
  }
}