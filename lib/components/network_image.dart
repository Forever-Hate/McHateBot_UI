import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// 網路圖片
class NetworkImage extends StatelessWidget {
  final String src;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final Widget errorWidget;

  const NetworkImage({
    Key? key,
    required this.src,
    this.fit,
    this.width,
    this.height,
    this.errorWidget = const SizedBox.shrink(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Builder(builder: (context) {
        try {
          return FutureBuilder<Uint8List?>(
            future: loadImage(src),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data == null) 
                {
                  return errorWidget;
                } 
                else 
                {
                  return Image.memory(
                    snapshot.data!,
                    fit: fit,
                    width: width,
                    height: height,
                    errorBuilder: (context, error, stackTrace) => errorWidget,
                  );
                }
              } 
              else 
              {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          );
        } catch (e) {
          return errorWidget;
        }
      }),
    );
  }

  Future<Uint8List?> loadImage(String src) async {
    final response = await http.get(Uri.parse(src));

    if (response.statusCode == 200) {
      return response.bodyBytes.buffer.asUint8List();
    } else {
      return null;
    }
  }
}