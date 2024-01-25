///github api url
const String API_ENDPOINT = "https://api.github.com/";
///github url
const String ENDPOINT = "https://github.com/";
///github repo 擁有者名稱
const String OWNER = "Forever-Hate";
///github repo 名稱
const String repoName = "McHateBot_UI";
///是否在開發階段
const bool IS_DEVELOPMENT_STAGE = false;
///bot種類
const Map<String,String> BOT_TYPES = {
  "McHateBot_raid":"突襲",
  "McHateBot_emerald":"存綠"
};
///最大使用者名稱長度(超過會使用跑馬燈)
const int MAX_USERNAME_LENGTH = 5;
///最大訊息長度(超過會移除最舊的訊息)
const int MAX_LOG_LENGTH = 1000;

