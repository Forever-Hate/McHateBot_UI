import 'package:flutter/material.dart';

import '../models/bot_instance.dart';
import '../services/github_service.dart';
import '../services/localization_service.dart';
import '../utils/logger.dart';
import '../utils/config.dart';

/// 新增實例視窗
class NewInstanceDialog extends StatefulWidget {
  final Function(BotType?,String?) onConfirm;
  const NewInstanceDialog(this.onConfirm,{super.key});

  @override
  State<NewInstanceDialog> createState() => _NewInstanceDialogState();
}

class _NewInstanceDialogState extends State<NewInstanceDialog> {
  // 是否已經選擇要新增的類型
  bool isTypeSelected = false;
  // 選擇的bot類型
  BotType? selectedType;
  // 選擇的bot版本號
  String? selectedVersion;

  // 取得類型DropdownMenuItem
  List<DropdownMenuItem<BotType>> getBotTypeDropdownMenuItem()
  {
    logger.i("進入getBotTypeDropdownMenuItem，取得類型DropdownMenuItem");
    List<DropdownMenuItem<BotType>> types = [
      DropdownMenuItem<BotType>(
          value: null,
          child: Text(LocalizationService.getLocalizedString("new_instance_dialog_bot_type_non_item"),style:Theme.of(context).textTheme.labelSmall),
        )
    ];
    BOT_TYPES.forEach((key, value) {
      types.add(
        DropdownMenuItem<BotType>(
          value: BotTypeExtension.fromValue(key),
          child: Text(value,style:Theme.of(context).textTheme.labelSmall),
        )
      );
    });
    return types;
  }
  // 取得版本號DropdownMenuItem
  List<DropdownMenuItem<String>> getBotVersionDropdownMenuItem(versionList)
  {
    logger.i("進入getBotVersionDropdownMenuItem，取得版本號DropdownMenuItem");
    List<DropdownMenuItem<String>> versions = [
      DropdownMenuItem<String>(
        value: null,
        child: Text(LocalizationService.getLocalizedString("new_instance_dialog_bot_version_non_item"),style:Theme.of(context).textTheme.labelSmall),
      )
    ];
    for(String version in versionList)
    {
      versions.add(
        DropdownMenuItem<String>(
          value: version,
          child: Text(version,style:Theme.of(context).textTheme.labelSmall),
        )
      );
    }
    return versions;
  }

  @override
  Widget build(BuildContext context) {
    logger.i("進入NewInstanceDialog，取得新增實例視窗");
    return AlertDialog(
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      title: Text(
        LocalizationService.getLocalizedString("new_instance_dialog_title"),
        style: Theme.of(context).textTheme.titleSmall
      ),
      content: SizedBox(
        height: 200,
        child: Column(children: [
        Tooltip(
          message: LocalizationService.getLocalizedString("new_instance_dialog_bot_type_tooltip"),
          child: Row(
            children: [
              Text(
                LocalizationService.getLocalizedString("new_instance_dialog_bot_type_title"),
                style: Theme.of(context).textTheme.labelSmall,
              ),
              DropdownButton(
                menuMaxHeight: 150,
                value: selectedType,
                underline: const SizedBox(),
                dropdownColor: Theme.of(context).cardColor,
                items: getBotTypeDropdownMenuItem(), 
                onChanged: (BotType? newValue){
                  logger.d("選擇:$newValue");
                  setState(() {
                    selectedVersion = null;
                    isTypeSelected = false;
                    selectedType = newValue;
                    if(newValue != null)
                    {
                      isTypeSelected = true;
                    }
                  });
                }
              )
            ],
          ),
        ),
        Tooltip(
          message: LocalizationService.getLocalizedString("new_instance_dialog_bot_version_tooltip"),
          child: Row(
            children: [
              Text(
                LocalizationService.getLocalizedString("new_instance_dialog_bot_version_title"),
                style: Theme.of(context).textTheme.labelSmall,
              ),
              selectedType != null ?
              FutureBuilder(
                future: GitHubService.getRepoTagList(selectedType!.value),
                builder: (context,snapshot){
                  if(snapshot.hasError)
                  {
                    return Text(
                      LocalizationService.getLocalizedString("error"),
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold
                      )
                    );
                  }
                  else if(snapshot.connectionState == ConnectionState.waiting)
                  {
                    return Text(LocalizationService.getLocalizedString("now_loading"),style: Theme.of(context).textTheme.labelSmall);
                  }
                  else
                  {
                    logger.d(snapshot.data);
                    return DropdownButton(
                      menuMaxHeight: 150,
                      value: selectedVersion,
                      underline: const SizedBox(),
                      dropdownColor: Theme.of(context).cardColor,
                      items: getBotVersionDropdownMenuItem(snapshot.data), 
                      onChanged: (String? newValue){
                        logger.d("選擇:$newValue");
                        setState(() {
                          selectedVersion = newValue;
                        });
                      }
                    );
                  }
              })
              :
              DropdownButton(
                dropdownColor: Theme.of(context).cardColor,
                menuMaxHeight: 150,
                value: selectedVersion,
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text(LocalizationService.getLocalizedString("new_instance_dialog_bot_version_non_item"),style:Theme.of(context).textTheme.labelSmall),
                  )
                ], 
                onChanged: null,
                underline: const SizedBox()
              )
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ElevatedButton(
              style: Theme.of(context).elevatedButtonTheme.style,
              onPressed: () {
                logger.d("按下${LocalizationService.getLocalizedString("cancel")}按鈕");
                Navigator.pop(context);
              }, 
              child: Text(
                LocalizationService.getLocalizedString("cancel"),
                style:Theme.of(context).textTheme.labelSmall
              )
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              style: Theme.of(context).elevatedButtonTheme.style,
              onPressed: () {
                logger.d("按下${LocalizationService.getLocalizedString("confirm")}按鈕");
                widget.onConfirm(selectedType,selectedVersion);
              }, 
              child: Text(
                LocalizationService.getLocalizedString("confirm"),
                style:Theme.of(context).textTheme.labelSmall
              )
            )
          ],
        )  
      ]),
      ),
    );
  }
}