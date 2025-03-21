// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:io';

// class DeviceUtils {
//   static Future<void> initializeDeviceId() async {
//     final deviceInfo = DeviceInfoPlugin();
//     String? deviceId;

//     if (Platform.isAndroid) {
//       var androidInfo = await deviceInfo.androidInfo;
//       deviceId = androidInfo.id; // Android ID
//     } else if (Platform.isIOS) {
//       var iosInfo = await deviceInfo.iosInfo;
//       deviceId = iosInfo.identifierForVendor; // iOS Identifier
//     }

//     if (deviceId != null) {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('device_id', deviceId);
//     }
//   }

//   static Future<String?> getDeviceId() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('device_id');
//   }
// }
// ini buat yang device nanti di lanjutkan karena masih ada kurangnya
