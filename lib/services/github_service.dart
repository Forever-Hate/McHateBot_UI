
import 'dart:convert';
import 'dart:io';

import "package:http/http.dart" as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/config.dart';
import '../utils/exception.dart';
import '../utils/logger.dart';
import '../services/localization_service.dart';


class GitHubService {
    /// 暫時不動 正式上線時要清空
    static Map<String,List<String>> tagList = {
      "McHateBot_raid":["V1.2.3","V1.2.2","V1.2.1"],
      "McHateBot_emerald":["V1.2","V1.1.92","V1.1.91"],
    };
    ///透過指定的repoName取得版本(Tags)
    static Future<List<String>> getRepoTagList(String repoName) async 
    {
      logger.i("進入getRepoTagList，取得版本號列表");
      if(!tagList.containsKey(repoName))
      {
        logger.d("沒有緩存在map中");
        Uri tagUrl = Uri.parse('${API_ENDPOINT}repos/$OWNER/$repoName/tags');
        logger.d(tagUrl);
        final response = await http.get(tagUrl);

        if (response.statusCode == 200)
        {
          List<dynamic> jsonData = json.decode(response.body);

          tagList[repoName] = jsonData.map((item) => item['name'] as String).toList();

        }
        logger.d(tagList);
      }
      return tagList[repoName]!;
    }
    
    ///透過指定的repoName與version來取得release的壓縮檔
    static Future<String> getReleaseZipFromRepoNameAndVersion(String repoName,String version) async 
    {
      logger.i("進入getReleaseZipFromRepoNameAndVersion，取得取得release的壓縮檔");
      final baseDir = await getApplicationCacheDirectory();
      final releaseUrl = Uri.parse('$ENDPOINT$OWNER/$repoName/releases/download/$version/$repoName.$version.zip');

      final response = await http.get(releaseUrl);
      if (response.statusCode == 200) 
      {
        final file = File(join(baseDir.path,'$repoName.$version.zip'));
        await file.writeAsBytes(response.bodyBytes);
        logger.d('Downloaded: ${file.path}');
      } 
      else 
      {
        logger.d('Failed to download release. Status code: ${response.statusCode}');
        throw DownloadException("${LocalizationService.getLocalizedString("download_fail")}，Status code: ${response.statusCode}");
      }
      return join(baseDir.path,'$repoName.$version.zip');
    }
}