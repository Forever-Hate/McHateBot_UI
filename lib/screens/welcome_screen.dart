import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gif_view/gif_view.dart';

import '../screens/home_screen.dart';
import '../services/localization_service.dart';
import '../utils/logger.dart';

/// 歡迎畫面
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  // gif控制器
  late GifController controller;
  // 閃爍計時器
  late Timer timer;
  // 是否顯示點擊任意鍵文字
  bool showFloatString = false;
  // 是否已點擊任意鍵
  bool isClick = false;
  // 是否已結束
  bool isFinish = false;
  // 點擊任意鍵文字透明度
  double opacityLevel = 1.0;
  // gif網址
  String gifUrl = 'https://media.tenor.com/7-CNilpY-l8AAAAd/link-start-sao.gif';
  // gif key
  Key key = UniqueKey();

  @override
  void initState() {
    super.initState();
    controller = GifController(
      loop: false,
      onFinish: () {
        logger.d("GIF Finished");
        if(isClick)
        {
          setState(() {
            isFinish = true;
          });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      },
      onFrame: (value) {
        logger.d("GIF Frame: $value");
        if(value == 134)
        {
          controller.pause();
          setState(() {
            showFloatString = true;
          });
        }
      },
    );
    startBlinking();
  }
 
  @override
  void dispose(){
    controller.dispose();
    timer.cancel();
    super.dispose();
  }

  /// 開始閃爍
  void startBlinking() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        opacityLevel = opacityLevel == 0 ? 1.0 : 0.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    logger.i("進入WelcomeScreen");
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Stack(
          children: [
            Visibility(
              visible: !isFinish,
              child:GifView.network(
                key: key,
                gifUrl,
                controller: controller,
                fit: BoxFit.fill,
                height: double.infinity,
                width: double.infinity,
              )
            ),
            Stack(
              children: [
                SizedBox(
                  height: double.infinity,
                  width: double.infinity,
                  child: Visibility(
                    visible: showFloatString,
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      child: AnimatedOpacity(
                        opacity: opacityLevel,
                        duration: const Duration(milliseconds: 500),
                        child: Text(
                          LocalizationService.getLocalizedString("click_any_button"),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    logger.d("點擊任意鍵");
                    if(showFloatString)
                    {
                      isClick = true;
                      setState(() {
                        showFloatString = false;
                        controller.play(initialFrame: 135);
                      });
                    }
                  },
                  child: Container(
                    color: Colors.transparent,
                    height: double.infinity,
                    width: double.infinity,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}