import 'package:flutter/material.dart';

/// 呈現一個半填充的Icon
///
///1. icon: 要呈現的 [IconData]
///2. size: icon的大小 [double]
///3. color: icon的顏色 [Color]
class HalfFilledIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;

  const HalfFilledIcon(this.icon, this.size, this.color,{super.key});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (Rect rect) {
        return LinearGradient(
          stops: const [0, 0.5, 0.5],
          colors: [color, color, color.withOpacity(0)],
        ).createShader(rect);
      },
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(icon, size: size, color: Colors.grey[300]),
      ),
    );
  }
}