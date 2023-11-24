import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../models/provider.dart';
import '../screens/home_screen.dart';
import '../screens/welcome_screen.dart';
import '../services/local_storage_service.dart';
import '../services/localization_service.dart';
import '../services/inventory_service.dart';
import '../utils/config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  //載入.env檔
  await dotenv.load(fileName: ".env");
  //載入語言檔
  await LocalizationService.loadLanguageData(await LocalStorageService.getLanguage());
  //設定最小視窗大小
  await windowManager.setMinimumSize(const Size(1264.0,681.0));
  //設定視窗標題
  await windowManager.setTitle(LocalizationService.getLocalizedString("appbar_main_title"));

  bool isShowWelcomeScreen = await LocalStorageService.getIsShowWelcomeScreen();
  await InventoryService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider())
      ],
      child: MyApp(isShowWelcomeScreen),
    ),
  );
}

class MyApp extends StatefulWidget  {
  final bool isShowWelcomeScreen;
  const MyApp(this.isShowWelcomeScreen,{Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  
  @override
  void initState() {
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider,LanguageProvider>(
      builder: (context, themeProvider,languageProvider, child) {
        ThemeData themeData;
        switch (themeProvider.themeType) {
          case ThemeType.dark:
            themeData = ThemeData(
              fontFamily: 'MisansTC',
              //主題色
              primaryColor: const Color.fromARGB(255, 34, 34, 34),

              cardColor: const Color.fromARGB(255, 38, 44, 58),
              
              //scaffold背景色
              scaffoldBackgroundColor: const Color.fromARGB(255, 22, 22, 22),

              dividerTheme: const DividerThemeData(
                color: Color.fromARGB(255, 123, 123, 123),
                thickness: 3,
              ),
              //分隔線 and 邊框顏色
              dividerColor: const Color.fromARGB(255, 123, 123, 123),
              //彈出視窗
              dialogBackgroundColor: Colors.black45,

              //文字
              textTheme: const TextTheme(
                //標題文字(小)
                titleSmall: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
                ),
                titleMedium: TextStyle(
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
                ),
                //一般文字
                labelSmall: TextStyle(
                  fontSize: 15,
                  color: Colors.white
                ),
                //物品欄文字
                labelMedium: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: <Shadow>[
                    Shadow(
                      offset: Offset(2, 2), // 阴影的偏移量，正值表示向右下偏移
                      blurRadius: 1.0, // 模糊半径
                      color: Colors.black, // 阴影颜色
                    )
                  ],
                )

              ),
              //按鈕
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 16, 22, 67)
                )
              ),
              //icon按鈕
              iconButtonTheme: IconButtonThemeData(
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 16, 22, 67)), //icon顏色
                  iconSize: MaterialStateProperty.all<double>(25), //icon大小
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // 為方形外框設定圓角
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.white), //白色背景
                )
              ),

              //icon
              iconTheme: const IconThemeData(
                color: Colors.white,
              ),
              
              //switch
              switchTheme: SwitchThemeData(
                thumbColor: MaterialStateProperty.all(Colors.white),
                trackColor: MaterialStateProperty.resolveWith((states) {
                if(states.contains(MaterialState.selected))
                {
                    return Colors.green;
                }
                return Colors.grey;
                }),
                trackOutlineColor: MaterialStateProperty.all(Colors.black),
              ),
              
              listTileTheme: const ListTileThemeData(
                //懸停時的顏色(借用位置修改) 兼 botInstance被選擇時的顏色
                selectedColor: Colors.white12
              ),

              useMaterial3: true,
            );
            break;
          case ThemeType.light:
          default:
            themeData = ThemeData(
              fontFamily: 'MisansTC',
              //主題色
              primaryColor: Colors.white,

              cardColor: Colors.grey[300],
              
              //scaffold背景色
              scaffoldBackgroundColor: const Color.fromARGB(255, 248, 248, 248),

              dividerTheme: const DividerThemeData(
                color: Color.fromARGB(255, 123, 123, 123),
                thickness: 3,
              ),
              //分隔線 and 邊框顏色
              dividerColor: const Color.fromARGB(255, 123, 123, 123),
              //彈出視窗
              dialogBackgroundColor: Colors.white70,

              //文字
              textTheme: const TextTheme(
                //標題文字(小)
                titleSmall: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
                ),
                titleMedium: TextStyle(
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
                ),
                //一般文字
                labelSmall: TextStyle(
                  fontSize: 15,
                  color: Colors.black
                ),
                //物品欄文字
                labelMedium: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: <Shadow>[
                    Shadow(
                      offset: Offset(2, 2), // 阴影的偏移量，正值表示向右下偏移
                      blurRadius: 1.0, // 模糊半径
                      color: Colors.black, // 阴影颜色
                    )
                  ],
                )

              ),
              //按鈕
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 207, 207, 226)
                )
              ),
              //icon按鈕
              iconButtonTheme: IconButtonThemeData(
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 16, 22, 67)), //icon顏色
                  iconSize: MaterialStateProperty.all<double>(25), //icon大小
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // 為方形外框設定圓角
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.black12),
                )
              ),

              //icon
              iconTheme: const IconThemeData(
                color: Colors.black,
              ),
              
              //switch
              switchTheme: SwitchThemeData(
                thumbColor: MaterialStateProperty.all(Colors.white),
                trackColor: MaterialStateProperty.resolveWith((states) {
                if(states.contains(MaterialState.selected))
                {
                    return Colors.green;
                }
                return Colors.grey;
                }),
                trackOutlineColor: MaterialStateProperty.all(Colors.black),
              ),
              
              listTileTheme: const ListTileThemeData(
                //懸停時的顏色(借用位置修改) 兼 botInstance被選擇時的顏色
                selectedColor: Colors.black12
              ),

              useMaterial3: true,
            );
            break;
        }
        return MaterialApp(
          title: 'HateBot',
          debugShowCheckedModeBanner: false,
          theme: themeData,
          home: IS_DEVELOPMENT_STAGE || !widget.isShowWelcomeScreen ? const HomeScreen() : const WelcomeScreen(),
        );
      },
    );
  }
}
