class AppConstants {

  // basic
  static const String APP_NAME = 'P2P Sharp Drop';


  static const String BASE_URL = 'https://sharp-drop.onrender.com/api';

  //TOKEN
  static const authToken = 'authToken';
  static const cacheUserProfile = 'cacheUserProfile';
  static String chatCache(String channelId) => 'chat_cache_$channelId';





  //auth
  static const String REGISTER_USER = '/auth/register/user';
  static const String CREATE_PIN = '/auth/register/security';
  static const String LOGIN_USER = '/auth/login/user';


  //user
  static const String GET_USER = '/user/profile';
  static const String GET_PERSONAL_REFERRALS= '/user/referrals/personal';
  static const String GET_CHANNELS= '/channel';

  //chat
  static const String GET_CHATS = '/chat/v2/user/channel/{channelId}';
  static const String GET_CHAT_DETAILS = '/chat/v2/user/chat/{chatId}';
  static const String SEND_MESSAGE = '/message/text';
  static const String SEND_IMAGE_MESSAGE = '/message/image';
  static const String SEND_VIDEO_MESSAGE = '/message/video';
  static const String MARK_CHAT_READ = '/message/{chatId}/read';






  static const String TOKEN = 'token';

  static const String FIRST_INSTALL = 'first-install';
  static const String REMEMBER_KEY = 'remember-me';



  static String getPngAsset(String image) {
    return 'assets/images/$image.png';
  }
  static String getGifAsset(String image) {
    return 'assets/gif/$image.gif';
  }
  static String getMenuIcon(String image) {
    return 'assets/menu_icons/$image.png';
  }

}
