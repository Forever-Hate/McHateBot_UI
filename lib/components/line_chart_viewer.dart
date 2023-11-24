import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';

import '../components/bar_chart_viewer.dart';
import '../models/track.dart';
import '../services/inventory_service.dart';
import '../services/localization_service.dart';
import '../utils/logger.dart';
import '../utils/util.dart';

/// LineBarViewer類別
/// 
/// 用於顯示LineBar圖表(拾取數量)
class LineBarViewer extends StatelessWidget {
  final List<Track> trackList;
  const LineBarViewer(this.trackList,{super.key});

  /// 載入圖片
  Future<ui.Image> _loadImage() async {
    final ui.Codec codec = await ui.instantiateImageCodec(InventoryService.getTextureFromName("emerald")!);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  @override
  Widget build(BuildContext context) {
    logger.i("進入LineBarViewer");
    return FutureBuilder(
      future: _loadImage(),
      builder: (context, snapshot) {
        if(snapshot.hasData)
        {
          return SizedBox(
            height: 500,
            child: LineChart(
              LineChartData(
                backgroundColor: Colors.transparent,
                minX: 1,
                maxX: 25,
                minY: 0,
                maxY: ((double.parse((trackList.map((e) => e.items["emerald"] ?? 0).reduce((value, element) => value > element ? value : element)).toString()) * 1.2) / 10).round() * 10,
                lineBarsData: [
                  LineChartBarData(
                    //點資料
                    spots: trackList.asMap().entries.map((entry) {
                      final int index = entry.key;
                      final Track track = entry.value;
                      return FlSpot((index+1).toDouble(), (track.items["emerald"] ?? 0).toDouble());
                    }).toList(),
                    
                    // isCurved: true, //曲線
                    gradient: LinearGradient(
                      colors: List.generate(trackList.length < 2 ? 2 : trackList.length, (index) => const Color.fromARGB(255, 0, 170, 44))
                    ),
                    barWidth: 5,
                    isStrokeCapRound: true,

                    //線上的圓點
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotImagePainter(
                          image: snapshot.data!,
                          size: 50,
                        );
                      },
                    ),
                    
                    //線下的空白區域
                    // belowBarData: BarAreaData(
                    //   show: true,
                    //   gradient: LinearGradient(
                    //     colors: List.generate(7, (index) => Colors.white)
                    //   ),
                    // ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Theme.of(context).cardColor,
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((e) {
                        return LineTooltipItem(
                          e.y.toString(),
                          const TextStyle(
                            color: Color.fromARGB(255, 0, 170, 44),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        );
                      }).toList();
                    },
                  ),
                  touchCallback: (FlTouchEvent event,LineTouchResponse? touchResponse) {
                    if(touchResponse != null && touchResponse.lineBarSpots != null && touchResponse.lineBarSpots!.isNotEmpty)
                    {
                      if(event is FlLongPressStart || event is FlTapUpEvent)
                      {
                        showDialog(
                          context: context, 
                          builder: (context) {
                            Track track = trackList[touchResponse.lineBarSpots![0].x.toInt()-1];
                            return AlertDialog(
                              backgroundColor: const Color.fromARGB(255, 38, 44, 58),
                              title: Text('${track.startTime} ~ ${track.endTime}',style: Theme.of(context).textTheme.titleSmall),
                              content: track.items.isEmpty ? 
                              Text(LocalizationService.getLocalizedString("no_record"),style: Theme.of(context).textTheme.labelSmall):
                              SizedBox(
                                height: 500,
                                child: BarChartViewer(
                                  track.items,
                                )
                              ),
                            );
                          }
                        );
                      }
                    }
                    
                  },
                  handleBuiltInTouches: true,
                ),
                titlesData: FlTitlesData(
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      reservedSize: 60,
                      showTitles: true,
                      getTitlesWidget: (value,index) {
                        return Container(
                          padding: const EdgeInsets.only(left:15),
                          child: Text(Util.formatNumber(value.toInt()),style: Theme.of(context).textTheme.labelSmall),
                        );
                      },
                    )
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      reservedSize: 35,
                      showTitles: true,
                      getTitlesWidget: (value,index) {
                        return Container(
                          padding: const EdgeInsets.only(top: 15),
                          child: Text(value.toInt().toString(),style: Theme.of(context).textTheme.labelSmall),
                        );
                      },
                    )
                  ),
                ),
              )
            )
          );
        }
        else
        {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}

/// FlDotImagePainter類別
/// 
/// 繼承FlDotPainter，自訂圓點的繪製方式
class FlDotImagePainter extends FlDotPainter {
  
  //圖片大小
  final double size;
  //圖片
  final ui.Image image;

  FlDotImagePainter({required this.image, this.size = 16});

  @override
  void draw(Canvas canvas, FlSpot spot, Offset offsetInCanvas) {
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(offsetInCanvas.dx - size / 2, offsetInCanvas.dy - size / 2, size, size),
      Paint(),
    );
  }

  @override
  Size getSize(FlSpot spot) {
    return Size(size, size);
  }

  @override
  List<Object> get props => [image, size];
}