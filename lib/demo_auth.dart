// Classroom demo authentication. One registered account is stored in memory.
// A new registration replaces the previous one. Restarting the app removes it.
// The default admin account (admin / admin123) always works. No database.
// currentUsername stores the username that appears on newly created posts.
class DemoAuth {
  static String? registeredUsername;
  static String? registeredPassword;
  static String? currentUsername;

  static bool login(String username, String password) {
    final isAdmin = username == 'admin' && password == 'admin123';

    final isRegisteredUser = registeredUsername != null &&
        username == registeredUsername &&
        password == registeredPassword;

    if (isAdmin || isRegisteredUser) {
      currentUsername = username;
      return true;
    }

    return false;
  }

  static void register(String username, String password) {
    registeredUsername = username;
    registeredPassword = password;
  }

  static void logout() {
    currentUsername = null;
  }
}
