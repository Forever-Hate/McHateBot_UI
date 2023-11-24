/// Track 突襲拾取紀錄
/// 
/// * 屬性：
/// 1. startTime: 開始時間，required [String]
/// 2. endTime: 結束時間，required [String]
/// 3. totalTime: 總時間，required [String]
/// 4. isPartTime: 是否為部分時間，required [bool]
/// 5. items: 拾取物品，required [Map<String, dynamic>]
/// 6. average: 平均拾取物品，required [Map<String, dynamic>]
/// 
/// * 方法
/// 1. fromJson: 從 JSON Map 讀取並轉換為 Track 物件
/// 2. toJson: 將 Track 物件轉換為 JSON Map
class Track {
  String startTime;
  String endTime;
  String totalTime;
  bool isPartTime;
  Map<String, dynamic> items;
  Map<String, dynamic> average;

  Track({
    required this.startTime,
    required this.endTime,
    required this.totalTime,
    required this.isPartTime,
    required this.items,
    required this.average,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      startTime: json['startTime'],
      endTime: json['endTime'],
      totalTime: json['totalTime'],
      isPartTime: json['isPartTime'],
      items: Map<String, dynamic>.from(json['items']),
      average: Map<String, dynamic>.from(json['average']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'totalTime': totalTime,
      'isPartTime': isPartTime,
      'items': items,
      'average': average,
    };
  }
}