import 'dart:collection';

import 'package:flutter/material.dart';

import 'package:ansi_up/ansi_up.dart';

import '../models/bot_instance.dart';
import '../services/localization_service.dart';
import '../utils/logger.dart';

/// 顯示log的Dialog
class LogDialog extends StatelessWidget {
  final BotInstance instance;
  final _scrollController = ScrollController();
  LogDialog(this.instance,{super.key});
  
  @override
  Widget build(BuildContext context) {
    logger.i("進入LogDialog，顯示log");
    return AlertDialog(
      title: Text(LocalizationService.getLocalizedString("log_title").replaceFirst('%username%', instance.username),style: Theme.of(context).textTheme.titleSmall),
      content: SizedBox(
        width: 1000,
        height: 500,
        child: ValueListenableBuilder<Queue<String>>(
          valueListenable: instance.messageQueue,
          builder: (context, value, child) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
              );
            });
            AnsiUp ansiUp = AnsiUp();
            return ListView.builder(
              controller: _scrollController,
              itemCount: value.length,
              itemBuilder: (context, index) {
                final decoded = decodeAnsiColorEscapeCodes(value.elementAt(index), ansiUp);
                final combinedText = decoded.map((item) => item.text).join('');
                return SelectionArea(child: Text(combinedText,style: Theme.of(context).textTheme.labelSmall));
              },
            );
          }
        ),
      ),
    );
  }
}