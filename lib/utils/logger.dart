import 'package:logger/logger.dart';

import './config.dart';

/// 記錄器，在需要記錄 log 的 .dart 檔案匯入 logger.dart
///
/// ```dart
/// import '../utils/logger.dart';
/// // or
/// // import 'logger.dart'
///
/// logger.v("Verbose log");
/// logger.d("Debug log");
/// logger.i("Info log");
/// logger.w("Warning log");
/// logger.e("Error log");
/// logger.wtf("What a terrible failure log");
///
/// // 指定低於某個特定 log 類型的話則不印出來
/// logger.level = Level.<log 類型>
/// ```
///
/// references:
///   https://pub.dev/packages/logger
// logger.Level = Level.Debug;

var logger = Logger(
  // 定義, 生產階段時, info 以上的 log 才打印出來; 開發階段時, 所有 log 都打印出來
  level: (IS_DEVELOPMENT_STAGE == true) ? null : Level.info,
  // 印出來的方法數
  printer: PrettyPrinter(
    methodCount: 0,
    // 是否印出時間的參數
    printTime: true,
  ),
);
