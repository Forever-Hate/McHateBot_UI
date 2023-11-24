import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter Desktop Context Menu'),
        ),
        body: MyWidget(),
      ),
    );
  }
}

class MyWidget extends StatelessWidget {
  final GlobalKey _key = GlobalKey();

  void _showContextMenu(BuildContext context, Offset position) {
    final RenderBox renderBox = _key.currentContext!.findRenderObject() as RenderBox;
    final Offset localPosition = renderBox.globalToLocal(position);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        localPosition.dx,
        localPosition.dy,
        localPosition.dx + 1,
        localPosition.dy + 1,
      ),
      items: <PopupMenuEntry>[
        PopupMenuItem(
          child: Text('刪除'),
          onTap: () {
            // Handle menu item 1 click
          },
        ),
        PopupMenuItem(
          child: Text('複製'),
          onTap: () {
            // Handle menu item 2 click
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _key,
      onSecondaryTapDown: (details) {
        _showContextMenu(context, details.globalPosition);
      },
      child: Container(
        width: 200,
        height: 200,
        color: Colors.blue,
        child: Center(
          child: Text('Right-click me'),
        ),
      ),
    );
  }
}