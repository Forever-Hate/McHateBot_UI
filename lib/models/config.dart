import 'dart:convert';

/// * 存取 Config 的物件
///
/// * 屬性：
/// 1. ip: 連線IP，required [String]
/// 2. port: 連線端口，required [int]
/// 3. username: 帳號，required [String]
/// 4. version: 版本，required [String]
/// 5. auth: 驗證方式，optional [String]
/// 6. language: 語言，optional [String]
/// 7. whitelist: 白名單，required [List]
///
/// * 方法
/// 1. toJsonString: 把物件直接轉換為 json string
/// 2. fromJson: 讀取 json map 並轉換成 Config 的建構子
class Config {
  String ip,username,version;
  String? auth,language;
  int port;
  List<dynamic> whitelist;


  /// 建構子
  Config(this.ip, this.port, this.username,this.version,this.whitelist,
      {this.auth = "microsoft",
      this.language = "zh-tw"});

  /// 把物件直接轉換為 json string
  String toJsonString() {
    Map<String, dynamic> configJsonMap = {
      "ip": ip,
      "port": port,
      "username": username,
      "version": version,
      "auth": auth,
      "language": language,
      "whitelist": whitelist,
    };
    return jsonEncode(configJsonMap);
  }

  /// 讀取 json map 並轉換成 Config 的建構子
  factory Config.fromJson(Map<String, dynamic> json) {
    // 提取內容值
    String ip = json["ip"];
    int port = json["port"];
    String username = json["username"];
    String version = json["version"];
    String auth = json["auth"];
    String language = json["language"];
    List<dynamic> whitelist = json["whitelist"];

    return Config(ip,port,username,version,whitelist,auth: auth,language: language);
  }
}