
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/logger.dart';

class ZipService {
  /// 解壓縮檔案
  /// 
  /// [zipPath] 壓縮檔案的路徑
  /// 回傳該實例的uuid
  static Future<String> unzip(String zipPath) async {
    logger.i("進入unzip，解壓縮檔案");
    try {
      createInstanceRootFolder();
      const uuidInstance = Uuid(); 
      final uuid = uuidInstance.v4();
      final zipFile = File(zipPath);
      final bytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      //建立資料夾
      final baseDir = await getApplicationCacheDirectory();
      final instanceFolder = Directory(join(baseDir.path,"instance",uuid));
      await instanceFolder.create(recursive: true);
      for (final file in archive) 
      {
        final filename = file.name;
        if (file.isFile) 
        {
          final data = file.content as List<int>;
          final f = File(join(instanceFolder.path,filename));
          await f.create(recursive: true);
          await f.writeAsBytes(data);
        } else {
          final dir = Directory(join(instanceFolder.path,filename));
          await dir.create(recursive: true);
        }
      }
      return uuid;
    } catch (e) {
      logger.e(e);
      return 'error';
    }
  }

  static Future<void> createInstanceRootFolder()
  {
    logger.i("進入createInstanceRootFolder，建立instance資料夾");
    return getApplicationCacheDirectory().then((value) async{
      if(!await Directory(join(value.path,"instance")).exists())
      {
        await Directory(join(value.path,"instance")).create(recursive: true);
      }
    });
  } 
}