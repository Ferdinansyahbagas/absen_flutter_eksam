// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';

// class ApiService {
//   static const String baseUrl = 'https://portal.eksam.cloud/api/v1';

//   // Fungsi helper untuk request API
//   static Future<dynamic> sendRequest({
//     required String endpoint,
//     String method = 'GET',
//     Map<String, dynamic>? body,
//   }) async {
//     final url = Uri.parse('$baseUrl/$endpoint');
//     SharedPreferences localStorage = await SharedPreferences.getInstance();
//     String? token = localStorage.getString('token');

//     var headers = {
//       'Authorization': 'Bearer $token',
//       'Accept': 'application/json',
//       'Content-Type': 'application/json',
//     };

//     try {
//       http.Response response;

//       switch (method) {
//         case 'POST':
//           response = await http.post(url, headers: headers, body: jsonEncode(body));
//           break;
//         case 'PUT':
//           response = await http.put(url, headers: headers, body: jsonEncode(body));
//           break;
//         case 'DELETE':
//           response = await http.delete(url, headers: headers);
//           break;
//         default:
//           response = await http.get(url, headers: headers);
//       }

//       if (response.statusCode == 200) {
//         return jsonDecode(response.body);
//       } else {
//         print("Error $method API: ${response.statusCode} - ${response.body}");
//         return null;
//       }
//     } catch (e) {
//       print("Exception in $method request: $e");
//       return null;
//     }
//   }
// }

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "https://portal.eksam.cloud/api/v1/";

  static Future<Map<String, dynamic>?> sendRequest({
    required String endpoint,
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    try {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      String? token = localStorage.getString('token');
      if (token == null) {
        throw Exception("Token tidak ditemukan. Harap login kembali.");
      }

      var url = Uri.parse('$baseUrl$endpoint');
      var headers = {'Authorization': 'Bearer $token'};

      http.Response response;

      if (method == 'POST') {
        response = await http
            .post(url, headers: headers, body: jsonEncode(body))
            .timeout(const Duration(seconds: 10)); // Set timeout 10 detik
      } else if (method == 'PUT') {
        response = await http
            .put(url, headers: headers, body: jsonEncode(body))
            .timeout(const Duration(seconds: 10)); // Set timeout 10 detik
      } else {
        response = await http
            .get(url, headers: headers)
            .timeout(const Duration(seconds: 10)); // Set timeout 10 detik
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Gagal mengambil data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error API: $e");
      return null;
    }
  }
}
