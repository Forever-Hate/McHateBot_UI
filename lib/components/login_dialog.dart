import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_linkify/flutter_linkify.dart';

import '../models/bot_instance.dart';
import '../services/localization_service.dart';
import '../utils/util.dart';
import '../utils/logger.dart';

/// 登入視窗
class LoginDialog extends StatefulWidget {
  final BotInstance instance;
  final String message;
  final Function() onPressed;
  const LoginDialog(this.instance,this.message,this.onPressed,{super.key});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  // 訊息
  String message = "";
  // 是否登入
  bool isLogin = false;
  // 訂閱stdout
  StreamSubscription? subscription;

  @override
  void initState() {
    super.initState();
    message = widget.message;
    subscription = widget.instance.stdoutStream!.transform(utf8.decoder).listen((event) {
      logger.d("收到stdout: $event");
      if(event.toString().contains("To sign in, use a web browser"))
      {
        setState(() {
          message = event.toString();
        });
      }

      if(event.toString().contains("[msa] Signed in with Microsoft"))
      {
        setState(() {
          isLogin = true;
          message = event.toString();
          subscription!.cancel();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    logger.i("進入LoginDialog，取的登入視窗");
    return AlertDialog(
      title: Text(LocalizationService.getLocalizedString("system_message"),style: Theme.of(context).textTheme.titleSmall),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SelectableLinkify(
            text: message,
            style: Theme.of(context).textTheme.labelSmall,
            onOpen: (link) async {
              Util.openUri(link.url);
            },
          ),
          const SizedBox(height: 10),
          isLogin ? 
          ElevatedButton(
            style: Theme.of(context).elevatedButtonTheme.style,
            onPressed: () async{ 
              logger.d("按下確認按鈕");
              Navigator.pop(context);
              widget.onPressed();
            },
            child: Text(LocalizationService.getLocalizedString("confirm"),style: Theme.of(context).textTheme.labelSmall),
          ):
          const CircularProgressIndicator()
        ],
      )
    );
  }
}