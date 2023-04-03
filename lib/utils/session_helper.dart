class SessionHelper {
  static String? userId;
  static String? authToken;
}

class SessionHelperEmpty {
  SessionHelperEmpty() {
    SessionHelper.userId = null;
    SessionHelper.authToken = null;
  }
}
