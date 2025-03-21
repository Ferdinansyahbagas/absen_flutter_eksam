import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static const String _tokenKey = 'token';
  static const String _deviceIdKey = 'device_id';

  // Simpan token
  static Future<void> setToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Ambil token
  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Hapus token (Logout)
  static Future<void> clearToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    print("✅ Token berhasil dihapus");
  }

  // Simpan device ID
  static Future<void> setDeviceId(String deviceId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_deviceIdKey, deviceId);
  }

  // Ambil device ID
  static Future<String?> getDeviceId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_deviceIdKey);
  }

  // Hapus device ID
  static Future<void> clearDeviceId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_deviceIdKey);
    print("✅ Device ID berhasil dihapus");
  }

  // Hapus semua data (untuk logout)
  static Future<void> clearAll() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print("✅ Semua data berhasil dihapus (Logout)");
  }
}

// import 'package:shared_preferences/shared_preferences.dart';

// class Preferences {
//   static const String _tokenKey = 'token';

//   // Simpan token
//   static Future<void> setToken(String token) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_tokenKey, token);
//   }

//   // Ambil token
//   static Future<String?> getToken() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_tokenKey);
//   }

//   // Hapus token (Logout)
//   static Future<void> clearToken() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_tokenKey);
//   }
// }
