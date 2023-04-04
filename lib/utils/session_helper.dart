class SessionHelper {
  static String? userId;
  static String? authToken;
  static String? username;
}

class SessionHelperEmpty {
  SessionHelperEmpty() {
    SessionHelper.userId = null;
    SessionHelper.authToken = null;
    SessionHelper.username = null;
  }
}
