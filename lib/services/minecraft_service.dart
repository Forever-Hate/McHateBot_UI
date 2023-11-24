import 'package:dart_minecraft/dart_minecraft.dart' as mc;
import 'package:mchatebot_ui/utils/logger.dart';

class MinecraftService{
  static List<String> hosts = [
    'mcfallout.net',
    'na.mcfallout.net',
    'jp.mcfallout.net',
    'sg.mcfallout.net'
  ];
  /// 取得最佳主機
  static Future<String> getBestHost() async 
  {
    logger.i("進入getBestHost，取得最佳主機");
    try 
    {
      final result = await getServerPingMap();
      final bestHost = result.entries.reduce((a, b) => a.value < b.value ? a : b).key;
      return bestHost;
    } 
    catch (e) 
    {
      logger.e(e);
      return 'mcfallout.net';
    }
  }

  /// 取得所有主機的ping值
  static Future<Map<String, int>> getServerPingMap() async 
  {
    final Map<String, int> result = {};
    for (final host in hosts) 
    {
      try 
      {
        final packet = await mc.ping(host, timeout: const Duration(seconds: 1));
        final ping = packet?.ping;
        if (ping != null) 
        {
          result[host] = ping;
        }
      } 
      catch (e) 
      {
        logger.e(e);
      }
    }
    return result;
  }

  /// 從玩家uuid取得玩家的頭像
  static Future<String> getAvatarsFromUuid(String uuid) async 
  {
    logger.i("進入getAvatarsFromUuid，取得玩家的頭像");
    return "https://crafatar.com/avatars/$uuid?overlay"; 
  }

  /// 從玩家名稱取得玩家的uuid
  static Future<String?> getUuidFromName(String name) async 
  {
    logger.i("進入getUuidFromName，取得玩家的uuid");
    try
    {
      final playerUuid = await mc.getUuid(name);
      final profile = await mc.getProfile(playerUuid.second);
      return profile.uuid;
    }
    catch(e)
    {
      logger.e(e);
      return null;
    }
  }

  /// 從玩家uuid取得玩家的名稱
  static Future<String> getNameFromUuid(String uuid) async 
  {
    logger.i("進入getUuidFromName2，取得玩家的uuid");
    try
    {
      final profile = await mc.getProfile(uuid);
      return profile.name;
    }
    catch(e)
    {
      logger.e(e);
      return "";
    }
  }
  
  /// 從玩家名稱取得玩家的頭像
  static Future<String?> getAvatarsFromName(String name) async 
  {
    logger.i("進入getAvatarsFromName，取得玩家的頭像");
    String uuid = await getUuidFromName(name) ?? "";
    if(uuid.isEmpty)
    {
      return null;
    }
    return await getAvatarsFromUuid(uuid);
  }

  
}