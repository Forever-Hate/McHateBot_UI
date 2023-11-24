import 'dart:io';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:window_manager/window_manager.dart';

import '../services/localization_service.dart';
import '../utils/logger.dart';

class Util {

  /// 取得訊息彈出視窗
  static void getMessageDialog(BuildContext context,String message,Function? onPressed,{String suffix = ""})
  async {
    logger.i("進入getMessageDialog，取的訊息彈出視窗");
    showDialog(
      context: context,
      barrierDismissible: false, //點擊空白處不關閉
      builder: (context){
        return SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.width * 0.6,
          child: AlertDialog(
            backgroundColor: Theme.of(context).dialogBackgroundColor,
            title: Text('${LocalizationService.getLocalizedString("system_message")}$suffix',style: Theme.of(context).textTheme.titleSmall),
            content: SingleChildScrollView(
              child: Text(message,style: Theme.of(context).textTheme.labelSmall),
            ),
            actions: <Widget>[
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  style: Theme.of(context).elevatedButtonTheme.style,
                  onPressed: () async{ 
                    logger.d("按下確認按鈕");
                    Navigator.pop(context);
                    await windowManager.setAlwaysOnTop(false);
                    if(onPressed != null)
                    {
                      onPressed();
                    } 
                  },
                  child: Text(LocalizationService.getLocalizedString("confirm"),style: Theme.of(context).textTheme.labelSmall),
                ),
              ),
            ],
          )
        ); 
      }
    );
    if(await windowManager.isMinimized())
    {
      await windowManager.restore();
    }
    await windowManager.setAlwaysOnTop(true);
  }
  /// 取得確認視窗
  static void getYesNoDialog(BuildContext context,Widget content,Function? onConfirm,Function? onCancel)
  {
    logger.i("進入getYesNoDialog");
    showDialog(
      context: context,
      barrierDismissible: false, //點擊空白處不關閉
      builder: (context){
        return AlertDialog(
          backgroundColor: Theme.of(context).dialogBackgroundColor,
          title: Text(LocalizationService.getLocalizedString("system_message"),style: Theme.of(context).textTheme.titleSmall),
          content: content,
          actions: <Widget>[
            ElevatedButton(
              style: Theme.of(context).elevatedButtonTheme.style,
              onPressed: () { 
                logger.d("按下取消按鈕");
                Navigator.pop(context);
                if(onCancel != null)
                {
                  onCancel();
                } 
              },
              child: Text(LocalizationService.getLocalizedString("cancel"),style: Theme.of(context).textTheme.labelSmall),
            ),
            ElevatedButton(
              style: Theme.of(context).elevatedButtonTheme.style,
              onPressed: () { 
                logger.d("按下確認按鈕");
                Navigator.pop(context);
                if(onConfirm != null)
                {
                  onConfirm();
                } 
              },
              child: Text(LocalizationService.getLocalizedString("confirm"),style: Theme.of(context).textTheme.labelSmall),
            )
          ],
        );
      }
    );
  }
  /// 取得載入中的widget
  static Widget getLoadingWidget(BuildContext context, String message)
  {
    logger.i("進入getLoadingWidget，取得載入中的widget");
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.transparent,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 10),
            Text(message,style: Theme.of(context).textTheme.labelSmall)
          ],
        ),
      ),
    );
  }

  ///確認是否為有效的圖片網址
  static Future<bool> isImageUrlValid(String imageUrl) async {
    logger.i("進入isImageUrlValid，檢查是否為有效圖片網址");
    try {
      final response = await http.head(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'];
        if (contentType != null && contentType.startsWith('image/')) {
          return true;
        }
      }
    } catch (e) {
      logger.e(e);
      return false; 
    }
    return false;
  }

  /// 取得圖片大小
  static Future<List<int>> getImageSizeFromUrl(String url) async {
    logger.i("進入getImageSizeFromUrl，取得圖片大小");
    final response = await http.get(Uri.parse(url));
    final bytes = response.bodyBytes;
    final image = await decodeImageFromList(bytes);
    logger.d("圖片大小: ${image.width}x${image.height}");
    return [image.width, image.height];
  }
  /// 取得可用的port
  static Future<int> getAvailablePort(int startingPort) async {
    int port = startingPort;
    while (true) {
      try {
        final serverSocket = await ServerSocket.bind("::", port);
        await serverSocket.close();
        return port;
      } catch (e) {
        port++;
      }
    }
  }

  /// 開啟資料夾(目前只有windows)
  static void openFileManager(FileSystemEntity fse) async {
    if (fse is Directory) {
      if (!fse.existsSync()) {
        fse.createSync(recursive: true);
      }
    }
    openUri(Uri.decodeFull(fse.uri.toString()));
  }

  /// 開啟網址
  static Future<void> openUri(String url) async {
    await launchUrlString(url).catchError((e) {
      logger.e(e);
      return true;
    });
  }

  ///格式化數字(K、M、B)
  static String formatNumber(int num) {
    if(num >= 1000000000) //十億
    {
      double result = num / 1000000000;
      return result % 1 == 0 ? '${result.toInt()}B' : '${result.toStringAsFixed(2)}B';
    }
    else if (num >= 1000000) //百萬
    {
      double result = num / 1000000;
      return result % 1 == 0 ? '${result.toInt()}M' : '${result.toStringAsFixed(2)}M';
    } 
    else if (num >= 1000) //千
    {
      double result = num / 1000;
      return result % 1 == 0 ? '${result.toInt()}K' : '${result.toStringAsFixed(2)}K';
    } 
    else //小於千 
    {
      return num.toString();
    }
  }

  ///格式化數字(千分位)
  static String formatThousand(int num) {
    return num.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  ///格式化時間
  static String formatDuration(
    Duration duration, {
    bool forceShowSeconds = false,
    bool forceShowMinutes = false,
    bool forceShowHours = false,
    bool forceShowDays = false,
    bool forceShowYears = false,
    bool abbreviate = false,
  }) {
    String str = '';
    final int years = duration.inDays ~/ 365;
    final int days = duration.inDays % 365;
    final int hours = duration.inHours.remainder(Duration.hoursPerDay);
    final int minutes = duration.inMinutes.remainder(Duration.minutesPerHour);
    final int seconds = duration.inSeconds.remainder(Duration.secondsPerMinute);

    if (years > 0 || forceShowYears) {
      if (abbreviate) {
        str += '${years}y ';
      } else {
        str += '$years 年 ';
      }
    }

    if (days > 0 || forceShowDays) {
      if (abbreviate) {
        str += '${days}d ';
      } else {
        str += '$days 天 ';
      }
    }

    if (hours > 0 || forceShowHours) {
      if (abbreviate) {
        str += '${hours}h ';
      } else {
        str += '$hours 小時 ';
      }
    }
    if (minutes > 0 || forceShowMinutes) {
      if (abbreviate) {
        str += '${minutes}m ';
      } else {
        str += '$minutes 分鐘 ';
      }
    }
    if (seconds > 0 || forceShowSeconds) {
      if (abbreviate) {
        str += '${seconds}s';
      } else {
        str += '$seconds 秒 ';
      }
    }

    return str.trimRight();
  }

  ///取得專案版本
  static Future<String> getProjectVersion() async {
    logger.i("進入getProjectVersion，取得專案版本");
    final PackageInfo info = await PackageInfo.fromPlatform();
    return info.version;
  }
}