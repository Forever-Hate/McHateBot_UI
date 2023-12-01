import 'dart:math';

import 'package:flutter/material.dart';

/// 時鐘
/// 
/// 參考資料:https://www.youtube.com/watch?v=HyAeZKWWuxA&t=1s&ab_channel=CodeX
/// 
/// 原始碼:https://gist.github.com/afzalali15/6d5c485eb6a5f64116f35a0360eea94f
class ClockView extends StatefulWidget {
  final String dateTimeString;
  const ClockView(this.dateTimeString,{super.key});
  
  @override
  State<ClockView> createState() => _ClockViewState();
}

class _ClockViewState extends State<ClockView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Transform.rotate(
        angle: -pi / 2,
        child: CustomPaint(
          painter: ClockPainter(context,DateTime.parse(widget.dateTimeString.replaceAll("/", "-"))),
        ),
      ),
    );
  }
}

class ClockPainter extends CustomPainter {
  final BuildContext context;
  final DateTime dateTime;
  ClockPainter(this.context,this.dateTime);
  //60 sec - 360, 1 sec - 6degree
  //12 hours  - 360, 1 hour - 30degrees, 1 min - 0.5degrees
  
  @override
  void paint(Canvas canvas, Size size) {
    var centerX = size.width / 2;
    var centerY = size.height / 2;
    var center = Offset(centerX, centerY);
    var radius = min(centerX, centerY);

    var fillBrush = Paint()..color = const Color(0xFF444974);

    var outlineBrush = Paint()
      ..color = const Color(0xFFEAECFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    var centerFillBrush = Paint()..color = const Color(0xFFEAECFF);

    var secHandBrush = Paint()
      ..color = Colors.orange[300]!
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5;

    var minHandBrush = Paint()
      ..shader = const RadialGradient(colors: [Color(0xFF748EF6), Color(0xFF77DDFF)])
          .createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8;

    var hourHandBrush = Paint()
      ..shader = const RadialGradient(colors: [Color(0xFFEA74AB), Color(0xFFC279FB)])
          .createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12;

    //刻度筆刷
    // var dashBrush = Paint()
    //   ..color = const Color(0xFFEAECFF)
    //   ..style = PaintingStyle.stroke
    //   ..strokeCap = StrokeCap.round
    //   ..strokeWidth = 1;

    //底色的圓
    canvas.drawCircle(center, radius - 40, fillBrush);
    //白色外框
    canvas.drawCircle(center, radius - 40, outlineBrush);
    
    //時針
    var hourHandX = centerX +
        35 * cos((dateTime.hour * 30 + dateTime.minute * 0.5) * pi / 180);
    var hourHandY = centerX +
        35 * sin((dateTime.hour * 30 + dateTime.minute * 0.5) * pi / 180);
    
    canvas.drawLine(center, Offset(hourHandX, hourHandY), hourHandBrush);
    
    //分針
    var minHandX = centerX + 45 * cos(dateTime.minute * 6 * pi / 180);
    var minHandY = centerX + 45 * sin(dateTime.minute * 6 * pi / 180);
    canvas.drawLine(center, Offset(minHandX, minHandY), minHandBrush);
    
    //秒針
    var secHandX = centerX + 45 * cos(dateTime.second * 6 * pi / 180);
    var secHandY = centerX + 45 * sin(dateTime.second * 6 * pi / 180);
    canvas.drawLine(center, Offset(secHandX, secHandY), secHandBrush);

    // 中心點的圓
    canvas.drawCircle(center, 16, centerFillBrush);
    
    //刻度
    // var outerCircleRadius = radius;
    // var innerCircleRadius = radius - 20;
    // for (double i = 0; i < 360; i += 12) {
    //   var x1 = centerX + outerCircleRadius * cos(i * pi / 180);
    //   var y1 = centerX + outerCircleRadius * sin(i * pi / 180);

    //   var x2 = centerX + innerCircleRadius * cos(i * pi / 180);
    //   var y2 = centerX + innerCircleRadius * sin(i * pi / 180);
      
    //   canvas.drawLine(Offset(x1, y1), Offset(x2, y2), dashBrush);
    // }
    
    //數字
    var textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int i = 1; i <= 12; i++) 
    {
      double x,y;
      if(i == 10 || i == 11 || i == 12)
      {
        x = centerX + 0.83 * radius * cos((i * 30) * pi / 180);
        y = centerY + 0.83 * radius * sin((i * 30) * pi / 180);
      }
      else
      {
        x = centerX + 0.8 * radius * cos((i * 30) * pi / 180);
        y = centerY + 0.8 * radius * sin((i * 30) * pi / 180);
      }

      textPainter.text = TextSpan(
        text: '$i',
        style: TextStyle(
          color: Theme.of(context).textTheme.labelSmall!.color,
          fontSize: 24,
        ),
      );

      textPainter.layout(); // 進行佈局

      canvas.save(); // 保存當前畫布

      canvas.translate(x, y); // 移動到中心點

      canvas.rotate(90 * pi / 180); // 旋轉90度

      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2)); // 繪製文字

      canvas.restore(); // 恢復畫布
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
