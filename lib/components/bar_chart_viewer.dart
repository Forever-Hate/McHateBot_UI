import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';

import '../services/inventory_service.dart';
import '../utils/logger.dart';
import '../utils/util.dart';

/// BarChartViewer類別
/// 
/// 用於顯示Bar圖表(拾取數量)
class BarChartViewer extends StatefulWidget {
  final Map<String,dynamic> items;
  const BarChartViewer(this.items,{super.key});

  @override
  State<BarChartViewer> createState() => _BarChartViewerState();
}

class _BarChartViewerState extends State<BarChartViewer> {
  // 當前顯示的 items
  List<MapEntry<String, dynamic>> currentItemsList = [];
  // 當前頁面
  int currentPage = 1;
  // 總頁數
  late int totalPages;
  // 每個bar的顏色
  List<Color> barColor = [
    const Color(0xFFEF5350),
    const Color(0xFFFFA726),
    const Color(0xFFFFEE58),
    const Color(0xFF66BB6A),
    const Color(0xFF42A5F5),
    const Color(0xFF5C6BC0),
    const Color(0xFFAB47BC),
    const Color(0xFFF3BF0D),
    const Color(0xFFBDBDBD),
    const Color(0xFFECF0F1),
  ];

  @override
  void initState() {
    super.initState();
    totalPages = (widget.items.length / 10).ceil();
  }

  // 更新 currentItems
  void updateCurrentItems() {
    // 計算當前頁面的起始索引和結束索引
    final startIndex = (currentPage - 1) * 10;
    final endIndex = (startIndex + 10).clamp(0, widget.items.length);
    Map<String,dynamic> currentItems = {};
    final keys = widget.items.keys.toList().sublist(startIndex, endIndex);
    for (var key in keys) {
      currentItems[key] = widget.items[key];
    }
    currentItemsList = currentItems.entries.toList();
  }

  @override
  Widget build(BuildContext context) {
    logger.i("進入BarChartViewer");
    updateCurrentItems();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //圖表
        Container(
          height: 450,
          width: currentItemsList.length * 50 + 150,
          color:Colors.transparent,
          padding: const EdgeInsets.only(left: 80, right: 20, top: 20, bottom: 20),
          child: BarChart(
            BarChartData(
              backgroundColor: Theme.of(context).primaryColor,
              maxY: ((double.parse((currentItemsList.map((e) => e.value).reduce((value, element) => value > element ? value : element)).toString()) * 1.2)/ 10).round() * 10,
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(
                    reservedSize: 60,
                    showTitles: false,
                  )
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    reservedSize: 60,
                    showTitles: true,
                    getTitlesWidget: (value,index) {
                      return Text(Util.formatNumber(value.toInt()),style: Theme.of(context).textTheme.labelSmall);
                    },
                  )
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    reservedSize: 35,
                    showTitles: true,
                    getTitlesWidget: (value, index) {
                      return Tooltip(
                        message: currentItemsList[int.parse(value.toStringAsFixed(0))].key,
                        child: Image.memory(InventoryService.getTextureFromName(currentItemsList[int.parse(value.toStringAsFixed(0))].key)!,scale:0.5,width: 50,height: 50),
                      );
                    },
                  )
                )
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Theme.of(context).primaryColor,
                  tooltipHorizontalAlignment: FLHorizontalAlignment.right,
                  tooltipMargin: -10,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${currentItemsList[groupIndex].key}\n',
                      Theme.of(context).textTheme.labelSmall!,
                      children: <TextSpan>[
                        TextSpan(
                          text: (rod.toY).toString(),
                          style: TextStyle(
                            color: rod.color,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              barGroups: [
                ...currentItemsList.map((entry) {
                  final index = currentItemsList.indexOf(entry);
                  final value = entry.value;
                  return BarChartGroupData(
                    x: index, 
                    barRods: [
                      BarChartRodData(
                        color: barColor[index], 
                        toY: double.parse(value.toString()),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
        //切換頁面的按鈕Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                logger.d("按下左鍵");
                if(currentPage > 1)
                {
                  setState(() {
                    currentPage--;
                  });
                }
              },
              icon: const Icon(Icons.keyboard_arrow_left_outlined),
            ),
            const SizedBox(width: 10),
            Text("$currentPage/$totalPages",style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(width: 10),
            IconButton(
              onPressed: () {
                logger.d("按下右鍵");
                if(currentPage < totalPages)
                {
                  setState(() {
                    currentPage++;
                  });
                }
              },
              icon: const Icon(Icons.keyboard_arrow_right_outlined,),
            ),
          ],
        )
      ],
    );
  }
}