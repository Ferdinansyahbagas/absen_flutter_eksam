// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:intl/intl.dart'; // for formatting date
// import 'package:image_picker/image_picker.dart';
// import 'package:flutter/foundation.dart';
// import 'package:http_parser/http_parser.dart';
// import 'dart:io';

// class InventoryScreen extends StatefulWidget {
//   @override
//   _InventoryScreenState createState() => _InventoryScreenState();
// }

// class _InventoryScreenState extends State<InventoryScreen> {
//   final _formKey = GlobalKey<FormState>();
//   // String? id;
//   String name = '';
//   String keterangan = '';
//   List<dynamic> _inventoryList = [];
//   int _currentPage = 0;
//   String? userId;
//   String tanggalPembelian = '';
//   String tanggalPeminjaman = '';
//   final int _rowsPerPage = 10;
//   final ImagePicker _picker = ImagePicker();
//   File? _image;
//   bool _isImageRequired = false;
//   bool isLoading = false;
//   DateTime? _tanggalPembelian;
//   DateTime? _tanggalPeminjaman;
//   String formattedDate = '';
//   bool _istanggalPembelianEmpty = false;
//   bool _istanggalPeminjamanEmpty = false;
//   bool _isNameEmpty = false;
//   bool _isKeteranganEmpty = false;

//   @override
//   void initState() {
//     super.initState();
//     fetchInventory();
//     getProfil();
//   }

//   List<dynamic> get _pagedInventory {
//     int start = _currentPage * _rowsPerPage;
//     int end = start + _rowsPerPage;
//     end = end > _inventoryList.length ? _inventoryList.length : end;
//     return _inventoryList.sublist(start, end);
//   }

//   // *Menampilkan dialog pilihan sumber gambar*
//   Future<void> _pickImage() async {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return SafeArea(
//           child: Wrap(
//             children: <Widget>[
//               ListTile(
//                 leading: const Icon(Icons.camera_alt),
//                 title: const Text('Ambil dari Kamera'),
//                 onTap: () async {
//                   Navigator.pop(context);
//                   await _getImage(ImageSource.camera);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.photo_library),
//                 title: const Text('Pilih dari Galeri'),
//                 onTap: () async {
//                   Navigator.pop(context);
//                   await _getImage(ImageSource.gallery);
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // *Mengambil gambar dari sumber yang dipilih*
//   Future<void> _getImage(ImageSource source) async {
//     final XFile? pickedFile = await _picker.pickImage(source: source);
//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//         _isImageRequired = false;
//       });
//     }
//   }

//   Future<void> _selectDate(BuildContext context, bool isPembelian) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     );
//     if (picked != null) {
//       setState(() {
//         if (isPembelian) {
//           _tanggalPembelian = picked;
//           tanggalPembelian = DateFormat('yyyy-MM-dd').format(picked);
//         } else {
//           _tanggalPeminjaman = picked;
//           tanggalPeminjaman = DateFormat('yyyy-MM-dd').format(picked);
//         }
//       });
//     }
//   }

//   Future<void> getProfil() async {
//     try {
//       final url =
//           Uri.parse('https://portal.eksam.cloud/api/v1/karyawan/get-profile');
//       SharedPreferences localStorage = await SharedPreferences.getInstance();

//       var request = http.MultipartRequest('GET', url);
//       request.headers['Authorization'] =
//           'Bearer ${localStorage.getString('token')}';

//       var response = await request.send();
//       var rp = await http.Response.fromStream(response);
//       var data = jsonDecode(rp.body.toString());

//       setState(() {
//         userId = data['data']['user_id'].toString();
//       });

//       // Simpan user_id ke SharedPreferences
//       localStorage.setInt('user_id', data['data']['id']);

//       print("Profil pengguna: ${data['data']}");
//     } catch (e) {
//       print("Error mengambil profil pengguna: $e");
//     }
//   }

//   Future<void> fetchInventory() async {
//     setState(() {
//       isLoading = true;
//     });
//     try {
//       final url = Uri.parse(
//           'https://portal.eksam.cloud/api/v1/other/get-self-inventory');
//       SharedPreferences localStorage = await SharedPreferences.getInstance();
//       String? token = localStorage.getString('token');

//       final response = await http.get(
//         url,
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         if (data['data'] != null && data['data'] is List) {
//           setState(() {
//             _inventoryList = data['data'];
//             print("Data inventory: $_inventoryList");
//           });
//         } else {
//           print('Format respons tidak sesuai: ${data['message']}');
//         }
//       } else {
//         print('Gagal ambil data, status: ${response.statusCode}');
//         print('Isi respons: ${response.body}');
//       }
//     } catch (e) {
//       print('Terjadi kesalahan saat fetchInventory: $e');
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> addInventory() async {
//     try {
//       final url = Uri.parse(
//           'https://portal.eksam.cloud/api/v1/other/add-self-inventory');
//       SharedPreferences localStorage = await SharedPreferences.getInstance();
//       String? token = localStorage.getString('token');

//       if (token == null) {
//         print('Token tidak ditemukan');
//         return;
//       }

//       var request = http.MultipartRequest('POST', url)
//         ..headers['Authorization'] = 'Bearer $token'
//         ..fields['name'] = name
//         ..fields['keterangan'] = keterangan
//         ..fields['tanggal_pembelian'] = tanggalPembelian
//         ..fields['tanggal_peminjaman'] = tanggalPeminjaman;

//       // Tambah file foto
//       request.files.add(await http.MultipartFile.fromPath(
//         'foto_barang',
//         _image!.path,
//         contentType: MediaType('image', 'jpeg'),
//       ));

//       final response = await request.send();

//       final resBody = await response.stream.bytesToString();
//       print('Response Add: $resBody');

//       if (response.statusCode == 200) {
//         final result = jsonDecode(resBody);
//         if (result['status'] == 'success') {
//           await fetchInventory();
//         }
//       }
//     } catch (e) {
//       print('Error addInventory: $e');
//     }
//   }

//   Future<void> updateInventory(String id) async {
//     try {
//       // Panggil getProfil untuk memastikan user_id sudah tersimpan
//       await getProfil();

//       final url = Uri.parse(
//           'https://portal.eksam.cloud/api/v1/other/edit-self-inventory/$id');
//       SharedPreferences localStorage = await SharedPreferences.getInstance();
//       String token = localStorage.getString('token') ?? '';
//       int? userId = localStorage.getInt('user_id');

//       if (userId == null) {
//         print('User ID tidak ditemukan.');
//         return;
//       }

//       var request = http.MultipartRequest('POST', url);
//       request.headers['Authorization'] = 'Bearer $token';
//       request.fields['name'] = name;
//       request.fields['keterangan'] = keterangan;
//       request.fields['status'] = '2';
//       request.fields['user_id'] = userId.toString();

//       var response = await request.send();
//       var rp = await http.Response.fromStream(response);

//       if (rp.statusCode == 200) {
//         await fetchInventory();
//       } else {
//         print('Gagal update: ${rp.statusCode} - ${rp.body}');
//       }
//     } catch (e) {
//       print('Error updateInventory: $e');
//     }
//   }

//   Future<void> deleteInventory(String id) async {
//     try {
//       final url = Uri.parse(
//           'https://portal.eksam.cloud/api/v1/other/delete-inventory/$id');
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? token = prefs.getString('token');

//       var request = http.MultipartRequest('DELETE', url); // Sesuaikan metode
//       request.headers['Authorization'] = 'Bearer $token';

//       var response = await request.send();
//       var rp = await http.Response.fromStream(response);

//       if (rp.statusCode == 200) {
//         fetchInventory();
//       } else {
//         print('Gagal hapus data: ${rp.statusCode}');
//       }
//     } catch (e) {
//       print('Error deleteInventory: $e');
//     }
//   }

//   void _showEditDialog(Map item) {
//     name = item['name'];
//     keterangan = item['keterangan'];

//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text('Edit Inventaris'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextFormField(
//               initialValue: item['name'],
//               decoration: InputDecoration(labelText: 'Nama'),
//               onChanged: (val) => name = val,
//             ),
//             TextFormField(
//               initialValue: item['keterangan'],
//               decoration: InputDecoration(labelText: 'Keterangan'),
//               onChanged: (val) => keterangan = val,
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () async {
//               if (_formKey.currentState!.validate()) {
//                 await updateInventory(item['id'].toString());
//                 Navigator.pop(context);
//               }
//             },
//             child: Text('Simpan'),
//           ),
//         ],
//       ),
//     );
//   }

//   Color _getStatusColor(int status) {
//     switch (status) {
//       case 1:
//         return Colors.green;
//       case 2:
//         return Colors.grey;
//       case 3:
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Inventaris Kantor')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(children: [
//           Form(
//             key: _formKey,
//             child: Column(children: [
//               TextFormField(
//                 decoration: InputDecoration(
//                   labelText: 'Nama Barang',
//                   labelStyle:
//                       const TextStyle(color: Color.fromARGB(255, 101, 19, 116)),
//                   floatingLabelBehavior:
//                       FloatingLabelBehavior.always, // Always show label on top
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                         color: _isNameEmpty
//                             ? Colors.red
//                             : const Color.fromARGB(255, 101, 19, 116)),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: const BorderSide(
//                         color: Color.fromARGB(255, 101, 19, 116), width: 2),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   errorBorder: OutlineInputBorder(
//                     borderSide: const BorderSide(
//                         color: Colors.red), // Border saat error
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   focusedErrorBorder: OutlineInputBorder(
//                     borderSide: const BorderSide(
//                         color: Colors.red), // Border saat error dan fokus
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   errorText: _isNameEmpty ? 'Tolong Isi Nama Barang' : null,
//                 ),
//                 onChanged: (value) {
//                   setState(() {
//                     name = value;
//                     _isNameEmpty = false;
//                   });
//                 },
//               ),
//               SizedBox(height: 10),
//               TextFormField(
//                 decoration: InputDecoration(
//                   labelText: 'Keterangan',
//                   labelStyle:
//                       const TextStyle(color: Color.fromARGB(255, 101, 19, 116)),
//                   floatingLabelBehavior:
//                       FloatingLabelBehavior.always, // Always show label on top
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                         color: _isKeteranganEmpty
//                             ? Colors.red
//                             : const Color.fromARGB(255, 101, 19, 116)),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: const BorderSide(
//                         color: Color.fromARGB(255, 101, 19, 116), width: 2),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   errorBorder: OutlineInputBorder(
//                     borderSide: const BorderSide(
//                         color: Colors.red), // Border saat error
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   focusedErrorBorder: OutlineInputBorder(
//                     borderSide: const BorderSide(
//                         color: Colors.red), // Border saat error dan fokus
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   errorText:
//                       _isKeteranganEmpty ? 'Tolong Isi Nama Barang' : null,
//                 ),
//                 onChanged: (value) {
//                   setState(() {
//                     keterangan = value;
//                     _isKeteranganEmpty = false;
//                   });
//                 },
//               ),
//               SizedBox(height: 10),
//               InkWell(
//                 onTap: () => _selectDate(context, true),
//                 child: InputDecorator(
//                   decoration: InputDecoration(
//                     labelText: 'Tanggal Pembelian',
//                     labelStyle: const TextStyle(
//                         color: Color.fromARGB(255, 101, 19, 116)),
//                     floatingLabelBehavior: FloatingLabelBehavior
//                         .always, // Always show label on top
//                     border: const OutlineInputBorder(),
//                     enabledBorder: OutlineInputBorder(
//                       borderSide: BorderSide(
//                           color: _istanggalPembelianEmpty
//                               ? Colors.red
//                               : const Color.fromARGB(255, 101, 19, 116)),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderSide: const BorderSide(
//                           color: Color.fromARGB(255, 101, 19, 116), width: 2),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     errorBorder: OutlineInputBorder(
//                       borderSide: const BorderSide(
//                           color: Colors.red), // Border saat error
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     focusedErrorBorder: OutlineInputBorder(
//                       borderSide: const BorderSide(
//                           color: Colors.red), // Border saat error dan fokus
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     errorText: _istanggalPembelianEmpty
//                         ? 'Tolong Isi Tanggal Pembelian'
//                         : null, // Error message
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         _tanggalPembelian == null
//                             ? 'Select Start Date'
//                             : DateFormat('yyyy-MM-dd')
//                                 .format(_tanggalPembelian!),
//                       ),
//                       const Icon(Icons.calendar_today, color: Colors.orange),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               InkWell(
//                 onTap: () => _selectDate(context, false),
//                 child: InputDecorator(
//                   decoration: InputDecoration(
//                     labelText: 'Tanggal Peminjaman',
//                     labelStyle: const TextStyle(
//                         color: Color.fromARGB(255, 101, 19, 116)),
//                     floatingLabelBehavior: FloatingLabelBehavior
//                         .always, // Always show label on top
//                     border: const OutlineInputBorder(),
//                     enabledBorder: OutlineInputBorder(
//                       borderSide: BorderSide(
//                           color: _istanggalPeminjamanEmpty
//                               ? Colors.red
//                               : const Color.fromARGB(255, 101, 19, 116)),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderSide: const BorderSide(
//                           color: Color.fromARGB(255, 101, 19, 116), width: 2),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     errorBorder: OutlineInputBorder(
//                       borderSide: const BorderSide(
//                           color: Colors.red), // Border saat error
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     focusedErrorBorder: OutlineInputBorder(
//                       borderSide: const BorderSide(
//                           color: Colors.red), // Border saat error dan fokus
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     errorText: _istanggalPeminjamanEmpty
//                         ? 'Tolong Isi Tanggal Peminjaman'
//                         : null, // Error message
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         _tanggalPeminjaman == null
//                             ? 'Select Start Date'
//                             : DateFormat('yyyy-MM-dd')
//                                 .format(_tanggalPeminjaman!),
//                       ),
//                       const Icon(Icons.calendar_today, color: Colors.orange),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               // Upload Photo Button
//               GestureDetector(
//                 onTap: _pickImage,
//                 child: Container(
//                   height: 130,
//                   width: 150,
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       color: _isImageRequired
//                           ? Colors.red
//                           : (_image == null
//                               ? const Color.fromRGBO(101, 19, 116, 1)
//                               : Colors.orange),
//                       width: 2,
//                     ),
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.camera_alt,
//                         size: 35,
//                         color: _isImageRequired
//                             ? Colors.red
//                             : (_image == null
//                                 ? const Color.fromRGBO(101, 19, 116, 1)
//                                 : Colors.orange),
//                       ),
//                       const SizedBox(height: 3),
//                       if (_image == null && !_isImageRequired)
//                         const Text(
//                           'Upload Photo Anda',
//                           style: TextStyle(
//                               fontSize: 14,
//                               color: Color.fromRGBO(101, 19, 116, 1)),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 10),

//               if (_image != null)
//                 Align(
//                   alignment: Alignment.centerLeft,
//                   child: InkWell(
//                     onTap: () {
//                       showDialog(
//                         context: context,
//                         builder: (BuildContext context) {
//                           return Dialog(
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10)),
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 if (kIsWeb)
//                                   Image.network(_image!.path, fit: BoxFit.cover)
//                                 else
//                                   Image.file(_image!, fit: BoxFit.cover),
//                               ],
//                             ),
//                           );
//                         },
//                       );
//                     },
//                     child: const Text(
//                       'Lihat Photo',
//                       style: TextStyle(
//                           fontSize: 15,
//                           color: Colors.orange,
//                           decoration: TextDecoration.underline),
//                     ),
//                   ),
//                 ),
//               SizedBox(height: 10),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () async {
//                     // Pastikan semua input sudah diisi
//                     if (_tanggalPembelian == null) {
//                       setState(() {
//                         _istanggalPembelianEmpty = true;
//                       });
//                     }
//                     if (_tanggalPeminjaman == null) {
//                       setState(() {
//                         _istanggalPeminjamanEmpty = true;
//                       });
//                     }
//                     if (name.isEmpty) {
//                       setState(() {
//                         _isNameEmpty = true;
//                       });
//                     }
//                     if (keterangan.isEmpty) {
//                       setState(() {
//                         _isKeteranganEmpty = true;
//                       });
//                     }

//                     // Jika ada input yang belum diisi, jangan lanjutkan
//                     if (_istanggalPembelianEmpty ||
//                         _istanggalPeminjamanEmpty ||
//                         _isNameEmpty ||
//                         _isKeteranganEmpty) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('Please complete all required fields.'),
//                           backgroundColor: Colors.red,
//                         ),
//                       );
//                       return;
//                     }

//                     // Jika semua input valid, kirim data
//                     await addInventory();
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.orange,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                   ),
//                   child: const Text(
//                     'Tambah',
//                     style: TextStyle(
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//             ]),
//           ),
//           SizedBox(height: 20),
//           Expanded(
//             child: isLoading
//                 ? Center(child: CircularProgressIndicator())
//                 : _inventoryList.isEmpty
//                     ? Center(child: Text('Belum ada data inventaris'))
//                     : Scrollbar(
//                         child: SingleChildScrollView(
//                           scrollDirection: Axis.vertical,
//                           child: SingleChildScrollView(
//                             scrollDirection: Axis.horizontal,
//                             child: DataTable(
//                               headingRowHeight: 40,
//                               dataRowHeight: 48,
//                               columnSpacing: 20,
//                               columns: const [
//                                 DataColumn(
//                                     label: Text('No',
//                                         style: TextStyle(
//                                             fontWeight: FontWeight.bold))),
//                                 DataColumn(
//                                     label: Text('Nama',
//                                         style: TextStyle(
//                                             fontWeight: FontWeight.bold))),
//                                 DataColumn(
//                                     label: Text('Keterangan',
//                                         style: TextStyle(
//                                             fontWeight: FontWeight.bold))),
//                                 DataColumn(
//                                     label: Text('Tanggal Pembelian',
//                                         style: TextStyle(
//                                             fontWeight: FontWeight.bold))),
//                                 DataColumn(
//                                     label: Text('Tanggal Pembelian',
//                                         style: TextStyle(
//                                             fontWeight: FontWeight.bold))),
//                                 DataColumn(
//                                     label: Text('Status',
//                                         style: TextStyle(
//                                             fontWeight: FontWeight.bold))),
//                                 DataColumn(
//                                     label: Text('',
//                                         style: TextStyle(
//                                             fontWeight: FontWeight.bold))),
//                               ],
//                               rows: List<DataRow>.generate(
//                                   _pagedInventory.length, (index) {
//                                 final item = _pagedInventory[index];
//                                 final status = item['status'];
//                                 final statusText =
//                                     (status is Map && status['name'] != null)
//                                         ? status['name'].toString()
//                                         : 'Tidak diketahui';
//                                 return DataRow(cells: [
//                                   DataCell(Text(
//                                       '${_currentPage * _rowsPerPage + index + 1}',
//                                       style: TextStyle(fontSize: 12))),
//                                   DataCell(Text(item['name'] ?? '-',
//                                       style: TextStyle(fontSize: 12))),
//                                   DataCell(Text(item['keterangan'] ?? '-',
//                                       style: TextStyle(fontSize: 12))),
//                                   DataCell(Text(
//                                       item['tanggal_pembelian'] ?? '-',
//                                       style: TextStyle(fontSize: 12))),
//                                   DataCell(Text(
//                                       item['tanggal_peminjaman'] ?? '-',
//                                       style: TextStyle(fontSize: 12))),
//                                   DataCell(Text(
//                                     statusText,
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color:
//                                           _getStatusColor(status?['id'] ?? 0),
//                                     ),
//                                   )),
//                                   DataCell(Row(
//                                     children: [
//                                       IconButton(
//                                         icon: Icon(Icons.edit, size: 18),
//                                         onPressed: () => _showEditDialog(item),
//                                         padding: EdgeInsets.zero,
//                                         constraints: BoxConstraints(),
//                                       ),
//                                       IconButton(
//                                         icon: Icon(Icons.delete, size: 18),
//                                         onPressed: () => deleteInventory(
//                                             item['id'].toString()),
//                                         padding: EdgeInsets.zero,
//                                         constraints: BoxConstraints(),
//                                       ),
//                                     ],
//                                   )),
//                                 ]);
//                               }),
//                             ),
//                           ),
//                         ),
//                       ),
//           ),
//           // if (_inventoryList.isEmpty)
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               IconButton(
//                 icon: Icon(Icons.arrow_back),
//                 onPressed: _currentPage > 0
//                     ? () => setState(() => _currentPage--)
//                     : null,
//               ),
//               Text('Halaman ${_currentPage + 1}'),
//               IconButton(
//                 icon: Icon(Icons.arrow_forward),
//                 onPressed:
//                     (_currentPage + 1) * _rowsPerPage < _inventoryList.length
//                         ? () => setState(() => _currentPage++)
//                         : null,
//               ),
//             ],
//           ),
//         ]),
//       ),
//     );
//   }
// }

