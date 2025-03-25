// // import 'package:shared_preferences/shared_preferences.dart';

// // class Preferences {
// //   static const String _tokenKey = 'token';
// //   static const String _deviceIdKey = 'device_id';

// //   // Simpan token
// //   static Future<void> setToken(String token) async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     await prefs.setString(_tokenKey, token);
// //   }

// //   // Ambil token
// //   static Future<String?> getToken() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     return prefs.getString(_tokenKey);
// //   }

// //   // Hapus token (Logout)
// //   static Future<void> clearToken() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     await prefs.remove(_tokenKey);
// //     print("✅ Token berhasil dihapus");
// //   }

// //   // Simpan device ID
// //   static Future<void> setDeviceId(String deviceId) async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     await prefs.setString(_deviceIdKey, deviceId);
// //   }

// //   // Ambil device ID
// //   static Future<String?> getDeviceId() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     return prefs.getString(_deviceIdKey);
// //   }

// //   // Hapus device ID
// //   static Future<void> clearDeviceId() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     await prefs.remove(_deviceIdKey);
// //     print("✅ Device ID berhasil dihapus");
// //   }

// //   // Hapus semua data (untuk logout)
// //   static Future<void> clearAll() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     await prefs.clear();
// //     print("✅ Semua data berhasil dihapus (Logout)");
// //   }
// // }

// import 'package:shared_preferences/shared_preferences.dart';

// class Preferences {
//   static const String _tokenKey = 'token';
//   static const String _deviceIdKey = 'device_id';
//   static const String _firebaseTokenKey = 'firebase_token';
//   static const String _userIdKey = 'user_id';

//   // Simpan token
//   static Future<bool> setToken(String token) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return await prefs.setString(_tokenKey, token);
//   }

//   // Ambil token
//   static Future<String?> getToken() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_tokenKey);
//   }

//   // Hapus token (Logout)
//   static Future<bool> clearToken() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool result = await prefs.remove(_tokenKey);
//     print(result ? "✅ Token berhasil dihapus" : "❌ Gagal menghapus token");
//     return result;
//   }

//   // Simpan device ID
//   static Future<bool> setDeviceId(String deviceId) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return await prefs.setString(_deviceIdKey, deviceId);
//   }

//   // Ambil device ID
//   static Future<String?> getDeviceId() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_deviceIdKey);
//   }

//   // Hapus device ID
//   static Future<bool> clearDeviceId() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool result = await prefs.remove(_deviceIdKey);
//     print(result ? "✅ Device ID berhasil dihapus" : "❌ Gagal menghapus device ID");
//     return result;
//   }

//   // Simpan Firebase Token
//   static Future<bool> setFirebaseToken(String firebaseToken) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return await prefs.setString(_firebaseTokenKey, firebaseToken);
//   }

//   // Ambil Firebase Token
//   static Future<String?> getFirebaseToken() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_firebaseTokenKey);
//   }

//   // Hapus Firebase Token
//   static Future<bool> clearFirebaseToken() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool result = await prefs.remove(_firebaseTokenKey);
//     print(result ? "✅ Firebase Token berhasil dihapus" : "❌ Gagal menghapus Firebase Token");
//     return result;
//   }

  
// // Simpan userId
// static Future<void> setUserId(String userId) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   await prefs.setString(_userIdKey, userId);
// }

// // Ambil userId
// static Future<String?> getUserId() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   return prefs.getString(_userIdKey);
// }

// // Hapus userId
// static Future<void> clearUserId() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   await prefs.remove(_userIdKey);
//   print("✅ User ID berhasil dihapus");
// }

//   // Hapus semua data (untuk logout)
//   static Future<bool> clearAll() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool result = await prefs.clear();
//     print(result ? "✅ Semua data berhasil dihapus (Logout)" : "❌ Gagal menghapus data");
//     return result;
//   }
// }
