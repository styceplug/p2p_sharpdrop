import 'package:flutter/foundation.dart';

class AppConstants {

  // basic
  static const String APP_NAME = 'Sharp Drop Digital Services';


  static const String BASE_URL = 'https://api.sharpdropapp.com/api';

  //TOKEN
  static const authToken = 'authToken';
  static const cacheUserProfile = 'cacheUserProfile';
  static const String UPDATE_DEVICE_TOKEN = '/user/profile/device-token';
  static String chatCache(String channelId) => 'chat_cache_$channelId';





  //auth
  static const String REGISTER_USER = '/auth/register/user';
  static const String CREATE_PIN = '/auth/register/security';
  static const String LOGIN_USER = '/auth/login/user';
  static const String REQUEST_OTP = '/auth/otp/request';
  static const String RESET_PASSWORD = '/auth/reset-password';


  //user
  static const String GET_USER = '/user/profile';
  static const String GET_PERSONAL_REFERRALS= '/user/referrals/personal';
  static const String GET_CHANNELS= '/channel/user';
  static const String GET_NOTIFICATIONS= '/notification';
  static const String PUT_NOTIFICATIONS_READ= '/notification';

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



/*  static String getPngAsset(String image) {
    return 'assets/images/$image.png';
  }*/
  static String getPngAsset(String image) {
    if (kIsWeb) {
      // Try removing the assets/ prefix for web
      return 'images/$image.png';
    } else {
      return 'assets/images/$image.png';
    }
  }
  static String getGifAsset(String image) {
    return 'assets/gif/$image.gif';
  }
  static String getMenuIcon(String image) {
    return 'assets/menu_icons/$image.png';
  }

}
