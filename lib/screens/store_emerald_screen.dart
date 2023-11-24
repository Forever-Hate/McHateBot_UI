import 'package:flutter/material.dart';

import '../utils/logger.dart';

class StoreEmeraldScreen extends StatefulWidget {
  const StoreEmeraldScreen({super.key});

  @override
  State<StoreEmeraldScreen> createState() => _StoreEmeraldScreenState();
}

class _StoreEmeraldScreenState extends State<StoreEmeraldScreen> {
  @override
  Widget build(BuildContext context) {
    logger.i("進入StoreEmeraldScreen");
    return Center(
      child: Text("暫不開放",style:Theme.of(context).textTheme.titleSmall),
    );
  }
}