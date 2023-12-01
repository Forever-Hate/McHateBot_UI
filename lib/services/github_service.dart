
import 'dart:convert';
import 'dart:io';

import "package:http/http.dart" as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../services/localization_service.dart';
import '../utils/config.dart';
import '../utils/exception.dart';
import '../utils/logger.dart';
import '../utils/util.dart';


class GitHubService {

    static Map<String,List<String>> tagList = {
      
    };
    ///透過指定的repoName取得版本(Tags)
    static Future<List<String>> getRepoTagList(String repoName) async 
    {
      logger.i("進入getRepoTagList，取得版本號列表");
      if(!tagList.containsKey(repoName))
      {
        logger.d("沒有緩存在map中");
        if(IS_DEVELOPMENT_STAGE)
        {
          tagList["McHateBot_raid"] = ["V1.2.3","V1.2.2","V1.2.1"];
          tagList["McHateBot_emerald"] = ["V1.2","V1.1.92","V1.1.91"];
        }
        else
        {
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

    /// 檢查是否有新版本
    static Future<String?> checkNewVersion() async {
      logger.i("進入checkNewVersion，檢查是否有新版本");
      Uri tagUrl = Uri.parse('${API_ENDPOINT}repos/$OWNER/$repoName/tags');
      logger.d(tagUrl);
      final response = await http.get(tagUrl);
      if (response.statusCode == 200)
      {
        List<dynamic> jsonData = json.decode(response.body);
        if(jsonData.isNotEmpty)
        {
          final String latestVersion = jsonData[0]['name'] as String;
          logger.d("最新版本：$latestVersion");
          final String currentVersion = await Util.getProjectVersion();
          logger.d("目前版本：$currentVersion");
          if(currentVersion != latestVersion.substring(1))
          {
            logger.d("有新版本");
            return latestVersion;
          }
        }
      }
      return null;
    }

    /// 取得release的url
    static String getReleaseUrl(String version) {
      return '$ENDPOINT$OWNER/$repoName/releases/tag/$version';
    }
}