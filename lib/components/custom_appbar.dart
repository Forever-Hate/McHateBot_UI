import 'package:flutter/material.dart';

import '../services/localization_service.dart';
import '../utils/logger.dart';


/// 根據傳入的參數, 判定該呈現什麼樣子的 AppBar
PreferredSizeWidget getCustomAppBarByIndex(String index, BuildContext context) {
  logger.i("進入getCustomAppBarByIndex，index為$index");
  if(index == LocalizationService.getLocalizedString("appbar_main_title"))
  {
    return PreferredSize(
      preferredSize: Size.fromHeight(MediaQuery.sizeOf(context).height * 0.075),
      child: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        leading: Builder(
          builder: (context) {
            return Tooltip(
              message: LocalizationService.getLocalizedString("drawer_tooltip"),
              child: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  logger.d("按下menu按鈕，打開Drawer");
                  Scaffold.of(context).openDrawer();
                },
              )
            );
          }
        ),
        title: Text(
          index,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      )
    );
  }
  else if(
    index == LocalizationService.getLocalizedString("appbar_setting_title") ||
    index == LocalizationService.getLocalizedString("appbar_config_title") ||
    index == LocalizationService.getLocalizedString("appbar_global_setting_title"))
  {
    return PreferredSize(
      preferredSize: Size.fromHeight(MediaQuery.sizeOf(context).height * 0.075),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
        ),
        child: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          title: Text(
            index,
            style: Theme.of(context).textTheme.titleSmall
          ),
          leading: Container(
            padding: const EdgeInsets.only(left: 2,top: 2,bottom:2),
            child: Tooltip(
              message: LocalizationService.getLocalizedString("back"),
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            )
          )
        ),
      )
    );
  }
  else
  {
    return PreferredSize(
      preferredSize:
          Size.fromHeight(MediaQuery.sizeOf(context).height * 0.075),
      child: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xff315194),
        elevation: 0,
        title: Text("測試"),
      )
    );
  }
}