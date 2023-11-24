import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../components/custom_appbar.dart';
import '../models/provider.dart';
import '../services/localization_service.dart';
import '../services/local_storage_service.dart';
import '../utils/logger.dart';
import '../utils/util.dart';

/// 全域設定頁面
class GlobalSettingScreen extends StatefulWidget {
  const GlobalSettingScreen({super.key});

  @override
  State<GlobalSettingScreen> createState() => _GlobalSettingScreenState();
}

class _GlobalSettingScreenState extends State<GlobalSettingScreen> {
  
  bool showWelcomeScreen = false;
  
  @override
  void initState() {
    super.initState();
    LocalStorageService.getIsShowWelcomeScreen().then((value){
      setState(() {
        showWelcomeScreen = value;
      });
    });
  }

  @override
  void dispose() {
    LocalStorageService.saveIsShowWelcomeScreen(showWelcomeScreen);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    logger.i("進入GlobalSettingScreen");
    return Scaffold(
      appBar: getCustomAppBarByIndex(LocalizationService.getLocalizedString("appbar_global_setting_title"), context),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //主題
            Row(
              children: [
                Text(LocalizationService.getLocalizedString("theme_title"),style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(width: 10),
                DropdownButton<ThemeType>(
                  dropdownColor: Theme.of(context).cardColor,
                  value: Provider.of<ThemeProvider>(context).themeType,
                  items: [
                    DropdownMenuItem(
                      value: ThemeType.light,
                      child: Text(LocalizationService.getLocalizedString("light_theme"),style: Theme.of(context).textTheme.labelSmall),
                    ),
                    DropdownMenuItem(
                      value: ThemeType.dark,
                      child: Text(LocalizationService.getLocalizedString("dark_theme"),style: Theme.of(context).textTheme.labelSmall),
                    ),
                  ],
                  onChanged: (value) {
                    logger.d("選擇value為$value");
                    Provider.of<ThemeProvider>(context, listen: false).toggleTheme(value!);
                  },
                )
              ],
            ),
            //語言
            Row(
              children: [
                Text(LocalizationService.getLocalizedString("language_title"),style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(width: 10),
                DropdownButton<LanguageType>(
                  dropdownColor: Theme.of(context).cardColor,
                  value: Provider.of<LanguageProvider>(context).languageType,
                  items: [
                    DropdownMenuItem(
                      value: LanguageType.zh_tw,
                      child: Text(LocalizationService.getLocalizedString("zh_tw"),style: Theme.of(context).textTheme.labelSmall),
                    ),
                    DropdownMenuItem(
                      value: LanguageType.en_us,
                      child: Text(LocalizationService.getLocalizedString("en_us"),style: Theme.of(context).textTheme.labelSmall),
                    ),
                  ],
                  onChanged: (value) {
                    logger.d("選擇value為$value");
                    Provider.of<LanguageProvider>(context, listen: false).toggleLanguage(value!);
                  },
                )
              ],
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: Tooltip(
                message: "",
                child: SizedBox(
                  width: "顯示歡迎動畫:".length * 15.toDouble() + 80,
                  child: SwitchListTile(
                    contentPadding: const EdgeInsets.all(0),
                    value: showWelcomeScreen,
                    onChanged: (newValue){
                      logger.d("切換newValue為$newValue");
                      setState(() {
                        showWelcomeScreen = newValue;
                      });
                    },
                    title: Text("顯示歡迎動畫:",style: Theme.of(context).textTheme.labelSmall),
                  ),
                )
              )
            ),
            //清除快取按鈕
            Tooltip(
              message: LocalizationService.getLocalizedString("clear_cache_tooltip"),
              child: ElevatedButton(
                style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.red)
                ),
                onPressed: (){
                  Util.getYesNoDialog(
                    context, 
                    Text(LocalizationService.getLocalizedString("clear_cache_dialog_content"),
                      style: Theme.of(context).textTheme.labelSmall
                    ), 
                    (){
                      logger.d("按下確認按鈕");
                      LocalStorageService.clearCacheExceptSomeKeyFromLocalStorage().then((value){
                        Util.getMessageDialog(context, LocalizationService.getLocalizedString("remove_success"), null);
                      });
                    }, 
                    null
                  );
                }, 
                child: Text(LocalizationService.getLocalizedString("clear_cache"),style: Theme.of(context).textTheme.labelSmall)
              ),
            )
          ],
        ),
      ),
    );
  }
}