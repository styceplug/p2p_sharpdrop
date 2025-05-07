class SessionManager {
  // Private constructor for singleton pattern
  SessionManager._();

  // Static instance
  static final SessionManager _instance = SessionManager._();

  // Public getter to access the instance
  static SessionManager get shared => _instance;

  // Your methods like getUserToken()
  String? getUserToken() {
    return null;

    // return your token
  }
}