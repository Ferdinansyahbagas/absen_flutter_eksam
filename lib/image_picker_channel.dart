// FFuture<void> getuserinfo() async {
//   try {
//     final url = Uri.parse('https://portal.eksam.cloud/api/v1/karyawan/get-user-info');
//     var request = http.MultipartRequest('GET', url);
//     SharedPreferences localStorage = await SharedPreferences.getInstance();
//     request.headers['Authorization'] = 'Bearer ${localStorage.getString('token')}';

//     var response = await request.send();
//     var rp = await http.Response.fromStream(response);
//     var json = jsonDecode(rp.body);

//     if (rp.statusCode == 200) {
//       var data = json['data'];
//       var dataBulanIni = json['data_bulan_ini'];
//       var dataMingguIni = json['data_minggu_ini'];

//       int menit = data['menit'];
//       int hari = data['hari'];
//       int telat = data['telat'];
//       int menitTelat = data['menit_telat'];
//       int lembur = data['lembur'];

//       int menitB = dataBulanIni['menit'];
//       int hariB = dataBulanIni['hari'];
//       int telatB = dataBulanIni['telat'];
//       int menitTelatB = dataBulanIni['menit_telat'];
//       int lemburB = dataBulanIni['lembur'];

//       int menitM = dataMingguIni['menit'];
//       int hariM = dataMingguIni['hari'];
//       int telatM = dataMingguIni['telat'];
//       int menitTelatM = dataMingguIni['menit_telat'];
//       int lemburM = dataMingguIni['lembur'];

//       setState(() {
//         // Simpan data ke dalam variabel state atau lakukan apapun yang diperlukan
//       });
//     } else {
//       print('Error fetching data: ${rp.statusCode}');
//       print(rp.body);
//     }
//   } catch (e) {
//     print('Error occurred: $e');
//   }
// }

// Map<String, dynamic> bulanIni = {};
// Map<String, dynamic> bulanSebelumnya = {};

// Future<void> getTarget() async {
//   try {
//     final url = Uri.parse('https://portal.eksam.cloud/api/v1/attendance/get-target-hour');
//     var request = http.MultipartRequest('GET', url);
//     SharedPreferences localStorage = await SharedPreferences.getInstance();
//     request.headers['Authorization'] =
//         'Bearer ${localStorage.getString('token')}';

//     var response = await request.send();
//     var rp = await http.Response.fromStream(response);
//     var data = jsonDecode(rp.body.toString());

//     if (rp.statusCode == 200) {
//       setState(() {
//         bulanIni = data['data']['bulan_ini'];
//         bulanSebelumnya = data['data']['bulan_sebelumnya'];
//       });
//     } else {
//       print('Error fetching target data: ${rp.statusCode}');
//       print(rp.body);
//     }
//   } catch (e) {
//     print('Error occurred: $e');
//   }
// } 