import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:web_socket_channel/io.dart';
import 'package:intl/intl.dart';

import '../services/local_storage_service.dart';
import '../services/localization_service.dart';
import '../models/bot_instance.dart';
import '../utils/logger.dart';

/// 訊息捲動視窗
class MessageScrollView extends StatefulWidget {
  final BotInstance instance;
  const MessageScrollView(this.instance,{super.key});

  @override
  State<MessageScrollView> createState() => _MessageScrollViewState();
}

class _MessageScrollViewState extends State<MessageScrollView> {
 
  //websocket
  IOWebSocketChannel? messageChannel;

  //最大訊息數量
  final int maxLength = 100;

  //訊息佇列
  Queue<String> messages = Queue<String>();
  
  //訊息發送時間佇列
  Queue<String> times = Queue<String>();

  //指令輸入框
  final TextEditingController _controller = TextEditingController();

  //ListView滾動控制器
  final ScrollController _scrollController = ScrollController();

  //訊息過濾器
  List<bool> filter = [false,false,false,false,false,false,false,false,false]; 

  //訊息過濾器正規表達式
  final List<RegExp> regexList = [
    RegExp(r'\[.*?'+ LocalizationService.getLocalizedString("filter_system")+r'.*?\]'),
    RegExp(r'\[.*?'+ LocalizationService.getLocalizedString("filter_residence")+r'.*?\]'),
    RegExp(r'\[.*?'+ LocalizationService.getLocalizedString("filter_facility")+r'.*?\]'),
    RegExp(r'\[.*?'+ LocalizationService.getLocalizedString("filter_public")+r'.*?\]'),
    RegExp(r'\[.*?'+ LocalizationService.getLocalizedString("filter_chat")+r'.*?\]'),
    RegExp(r'\[.*?'+ LocalizationService.getLocalizedString("filter_trade")+r'.*?\]'),
    RegExp(r'\[.*?'+ LocalizationService.getLocalizedString("filter_lottery")+r'.*?\]'),
    RegExp(r'\[' + LocalizationService.getLocalizedString("filter_dm")+'\]'),
    RegExp(r'\[' + LocalizationService.getLocalizedString("filter_dm2")+'\]')
  ];

  bool isAutoScroll = false;

  @override
  void initState() {
    super.initState();
    messageChannel = IOWebSocketChannel.connect('ws://${dotenv.env['IP']}:${widget.instance.websocketPort}/message');
    
    //讀取訊息過濾器緩存
    LocalStorageService.getMessageFilter().then((value) {
      setState(() {
        if(value.isNotEmpty)
        {
          //跟舊版本的訊息過濾器暫存長度不一樣，所以要判斷
          //長度一樣的話就直接覆蓋
          if(filter.length == value.length)
          {
            filter = value;
          }
        }
      });
    });
    
    //讀取訊息自動捲動緩存
    LocalStorageService.getMessageAutoScroll().then((value) {
      setState(() {
        isAutoScroll = value;
      });
    });

  }
  
  @override
  void dispose() {
    super.dispose();
    messageChannel!.sink.close();
    LocalStorageService.saveMessageFilter(filter);
    LocalStorageService.saveMessageAutoScroll(isAutoScroll);
  }
  
  //設定自動捲動
  setAutoScroll(bool value)
  {
    isAutoScroll = value;
  }

  //捲動到底部
  void _scrollToBottom() {
    logger.i("進入_scrollToBottom");

    if (_scrollController.hasClients &&
        _scrollController.position.pixels != _scrollController.position.maxScrollExtent && isAutoScroll) 
        {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
  }
  //取得訊息卡片
  Widget getMessageCard(String time,dom.Document data)
  {
    return Container(
      padding: const EdgeInsets.only(left:5),
      color: const Color.fromARGB(100, 100, 100, 100),
      child: Row(
        children: [
          Text(time,style: Theme.of(context).textTheme.labelSmall),
          Expanded(
            child: Html(data: data.outerHtml),
          ),
        ],
      ),
    );
  }
  
  //解析html
  Future<dom.Document> parseHtml(html) async {
    return parse(html);
  }

  /// 過濾訊息
  Future<void> filterMessage(dynamic currentData) async {
    logger.i("進入filterMessage，過濾訊息");
    for (var i = 1; i < filter.length; i++) {
      if(filter[i])
      {
        bool matchFound = false;
        if(filter[i] == filter.last)
        {
          matchFound = regexList[i-1].hasMatch(currentData) || regexList[i].hasMatch(currentData);
        }
        else
        {
          matchFound = regexList[i-1].hasMatch(currentData);
        }

        if(matchFound)
        {
          messages.add(currentData);
          times.add(DateFormat('[HH:mm:ss]').format(DateTime.now()));
          break;
        }
      }
    }
    //如果訊息數量超過最大值就移除最舊的訊息
    if (messages.length > maxLength) {
      messages.removeFirst();
      times.removeFirst();
    }
  }

  @override
  Widget build(BuildContext context) {
    logger.i("進入MessageScrollView");
    return Container(
      padding: const EdgeInsets.only(left: 20,right: 20),
      child: Column(
        children: [
          Text(LocalizationService.getLocalizedString("message_title"),style: Theme.of(context).textTheme.titleSmall),
          Container(
            height: 500,
            alignment: Alignment.topLeft,
            child: StreamBuilder(
              stream: messageChannel!.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) 
                {
                  //將當前資料暫存
                  String currentData = snapshot.data;
                  //修改父階span元素的字體顏色 透過toRadixString(16)轉成16進位
                  currentData = currentData.replaceRange(5, 5, " style=\"color: #${Theme.of(context).textTheme.labelSmall!.color!.value.toRadixString(16)}\"");
                  logger.d(currentData);
                  filterMessage(currentData);

                  //是否要自動捲動到底部
                  if(isAutoScroll)
                  {
                    _scrollToBottom();
                  }
                  return SelectionArea(
                    child: ListView.builder(
                      shrinkWrap: true,
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        return FutureBuilder(
                          future: parseHtml(messages.elementAt(index)),
                          builder: (BuildContext context, AsyncSnapshot<dom.Document> snapshot) {
                            if (snapshot.hasData) 
                            {
                              return getMessageCard(times.elementAt(index),snapshot.data!);
                            } 
                            else 
                            {
                              return Container();
                            }
                          }
                        );
                      }
                    )
                  );
                }
                else 
                {
                  return const Text('Waiting for messages...');
                }
              }
            ),
          ),
          FilterSwitchList(isAutoScroll,setAutoScroll,filter),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(top: 10),
                  child: TextField(
                    controller: _controller,
                    style: Theme.of(context).textTheme.labelSmall,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: LocalizationService.getLocalizedString("command_input_hintText"),
                      hintStyle: Theme.of(context).textTheme.labelSmall
                    ),
                    onEditingComplete: () {
                      logger.d("按下enter送出指令");
                      widget.instance.process!.stdin.writeln(_controller.text);
                      _controller.clear();
                    },
                  )
                ),
              ),
              const SizedBox(width: 10),
              Container(
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5)
                ),
                child: IconButton(
                  style: Theme.of(context).iconButtonTheme.style,
                  onPressed: (){
                    logger.d("按下送出按鈕");
                    widget.instance.process!.stdin.writeln(_controller.text);
                    _controller.clear();
                  }, 
                  icon: const Icon(Icons.send)
                ),
              )
            ],
          )
        ],
  ),
    );
  }
}

/// switch訊息過濾器
class FilterSwitchList extends StatefulWidget {
  bool isAutoScroll;
  final Function(bool) setAutoScroll;
  final List<bool> filter;
  FilterSwitchList(this.isAutoScroll,this.setAutoScroll,this.filter,{super.key});

  @override
  State<FilterSwitchList> createState() => _FilterSwitchListState();
}

class _FilterSwitchListState extends State<FilterSwitchList> {

  /// 取得switchListTile
  Widget getSwitchListTile(String tooltip,String title,bool initialValue,Function(bool) onChanged)
  {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: Tooltip(
        message: tooltip,
        child: SizedBox(
          width: title.length * 20.toDouble() + 63,
          child: SwitchListTile(
            title: Text(title,style: Theme.of(context).textTheme.labelSmall),
            value: initialValue,
            onChanged: onChanged,
            contentPadding: const EdgeInsets.all(0),
          ),
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            getSwitchListTile("", LocalizationService.getLocalizedString("filter_all"), widget.filter[0], (value){
              setState(() {
                widget.filter.fillRange(0, widget.filter.length, value);
              });
            }),
            getSwitchListTile("", LocalizationService.getLocalizedString("filter_system"), widget.filter[1], (value){
              setState(() {
                widget.filter[1] = value;
                widget.filter[0] = false;
              });
            }),
            getSwitchListTile("", LocalizationService.getLocalizedString("filter_residence"), widget.filter[2], (value){
              setState(() {
                widget.filter[2] = value;
                widget.filter[0] = false;
              });
            }),
            getSwitchListTile("", LocalizationService.getLocalizedString("filter_facility"), widget.filter[3], (value){
              setState(() {
                widget.filter[3] = value;
                widget.filter[0] = false;
              });
            }),
            getSwitchListTile("", LocalizationService.getLocalizedString("filter_public"), widget.filter[4], (value){
              setState(() {
                widget.filter[4] = value;
                widget.filter[0] = false; 
              });
            }),
            getSwitchListTile("", LocalizationService.getLocalizedString("filter_chat"), widget.filter[5], (value){
              setState(() {
                widget.filter[5] = value;
                widget.filter[0] = false;
              });
            }),
            getSwitchListTile("", LocalizationService.getLocalizedString("filter_trade"), widget.filter[6], (value){
              setState(() {
                widget.filter[6] = value;
                widget.filter[0] = false;
              });
            }),
            getSwitchListTile("", LocalizationService.getLocalizedString("filter_lottery"), widget.filter[7], (value){
              setState(() {
                widget.filter[7] = value;
                widget.filter[0] = false;
              });
            }),
            getSwitchListTile("", "私訊", widget.filter[8], (value){
              setState(() {
                widget.filter[8] = value;
                widget.filter[0] = false;
              });
            }),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: getSwitchListTile("", LocalizationService.getLocalizedString("auto_roll_to_bottom"), widget.isAutoScroll, (value){
            setState(() {
              widget.isAutoScroll = value;
              widget.setAutoScroll(value);
            });
          }),
        )
      ],
    );
  }
}