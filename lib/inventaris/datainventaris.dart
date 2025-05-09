import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; 
import 'dart:convert';
import 'dart:io';

class dataInventory extends StatefulWidget {
  @override
  _dataInventoryState createState() => _dataInventoryState();
}

class _dataInventoryState extends State<dataInventory> {
  String name = '';
  String keterangan = '';
  String formattedDate = '';
  String tanggalPembelian = '';
  String tanggalPeminjaman = '';
  String? oldImagePath;
  String? userId;
  File? _image;
  int _currentPage = 0;
  bool isLoading = false;
  DateTime? _tanggalPembelian;
  DateTime? _tanggalPeminjaman;
  List<dynamic> _inventoryList = [];
  final int _rowsPerPage = 15;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    getProfil();
    fetchInventory();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Ambil dari Kamera'),
                onTap: () async {
                  Navigator.pop(context);
                  await _getImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pilih dari Galeri'),
                onTap: () async {
                  Navigator.pop(context);
                  await _getImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

// Mengambil gambar dari sumber yang dipilih
  Future<void> _getImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // Update gambar yang dipilih
      });
    }
  }

  List<dynamic> get _pagedInventory {
    int start = _currentPage * _rowsPerPage;
    int end = start + _rowsPerPage;
    end = end > _inventoryList.length ? _inventoryList.length : end;
    return _inventoryList.sublist(start, end);
  }

  // *Menampilkan dialog pilihan sumber gambar*

  // Future<void> _selectDate(BuildContext context, bool isPembelian) async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now(),
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime(2101),
  //   );
  //   if (picked != null) {
  //     setState(() {
  //       if (isPembelian) {
  //         _tanggalPembelian = picked;
  //         tanggalPembelian = DateFormat('yyyy-MM-dd').format(picked);
  //       } else {
  //         _tanggalPeminjaman = picked;
  //         tanggalPeminjaman = DateFormat('yyyy-MM-dd').format(picked);
  //       }
  //     });
  //   }
  // }

  Future<void> getProfil() async {
    try {
      final url =
          Uri.parse('https://portal.eksam.cloud/api/v1/karyawan/get-profile');
      SharedPreferences localStorage = await SharedPreferences.getInstance();

      var request = http.MultipartRequest('GET', url);
      request.headers['Authorization'] =
          'Bearer ${localStorage.getString('token')}';

      var response = await request.send();
      var rp = await http.Response.fromStream(response);
      var data = jsonDecode(rp.body.toString());

      setState(() {
        userId = data['data']['user_id'].toString();
      });

      // Simpan user_id ke SharedPreferences
      localStorage.setInt('user_id', data['data']['id']);

      print("Profil pengguna: ${data['data']}");
    } catch (e) {
      print("Error mengambil profil pengguna: $e");
    }
  }

  Future<void> deleteInventory(String id) async {
    try {
      final url = Uri.parse(
          'https://portal.eksam.cloud/api/v1/other/delete-inventory/$id');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      var request = http.MultipartRequest('DELETE', url); // Sesuaikan metode
      request.headers['Authorization'] = 'Bearer $token';

      var response = await request.send();
      var rp = await http.Response.fromStream(response);

      if (rp.statusCode == 200) {
        fetchInventory();
      } else {
        print('Gagal hapus data: ${rp.statusCode}');
      }
    } catch (e) {
      print('Error deleteInventory: $e');
    }
  }


  Future<void> fetchInventory() async {
    setState(() {
      isLoading = true;
    });
    try {
      final url = Uri.parse(
          'https://portal.eksam.cloud/api/v1/other/get-self-inventory');
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      String? token = localStorage.getString('token');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['data'] != null && data['data'] is List) {
          setState(() {
            _inventoryList = data['data'];
            // Simpan path foto dari data pertama atau sesuai kebutuhan
            if (_inventoryList.isNotEmpty) {
              oldImagePath = _inventoryList[0]['foto_barang'];
            }
          });
        } else {
          print('Format respons tidak sesuai: ${data['message']}');
        }
      } else {
        print('Gagal ambil data, status: ${response.statusCode}');
        print('Isi respons: ${response.body}');
      }
    } catch (e) {
      print('Terjadi kesalahan saat fetchInventory: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateInventory(String id) async {
    try {
      await getProfil();

      final url = Uri.parse(
          'https://portal.eksam.cloud/api/v1/other/edit-self-inventory/$id');
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      String token = localStorage.getString('token') ?? '';
      int? userId = localStorage.getInt('user_id');

      if (userId == null) {
        print('User ID tidak ditemukan.');
        return;
      }

      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['name'] = name;
      request.fields['keterangan'] = keterangan;
      request.fields['status'] = '2';
      request.fields['user_id'] = userId.toString();
      request.fields['tanggal_pembelian'] = tanggalPembelian;
      request.fields['tanggal_peminjaman'] = tanggalPeminjaman;

      // Cek apakah gambar ada, jika ada baru dikirim
      if (_image != null) {
        // Jika user memilih gambar baru
        print('Mengirim gambar baru...');
        request.files.add(await http.MultipartFile.fromPath(
          'foto_barang',
          _image!.path,
          contentType: MediaType('image', 'jpg'),
        ));
      } else if (oldImagePath != null && oldImagePath!.startsWith('/data')) {
        // Kalau ternyata path lama adalah file lokal (bukan URL), kirim ulang file-nya
        request.files.add(await http.MultipartFile.fromPath(
          'foto_barang',
          oldImagePath!,
          contentType: MediaType('image', 'jpg'),
        ));
      } else {
        // Tidak mengirim field foto_barang, biarkan server tetap pakai gambar lama
        print('Tidak mengirim gambar, tetap pakai yang lama.');
      }
      var response = await request.send();
      var rp = await http.Response.fromStream(response);

      print('Status Code: ${rp.statusCode}');
      print(
          'Response Body: ${rp.body}'); // <<< Tambah ini, supaya kelihatan isinya

      if (rp.statusCode == 200) {
        final result = jsonDecode(rp.body);
        if (result['status'] == 'success') {
          await fetchInventory();
          print('Inventory berhasil diupdate.');
        } else {
          print('Update gagal (status success != "success"): ${result}');
        }
      } else {
        print('Gagal update, status bukan 200: ${rp.statusCode}');
        print(
            'Isi response saat gagal: ${rp.body}'); // <<< Cetak lagi kalau status bukan 200
      }
    } catch (e) {
      print('Error updateInventory: $e');
    }
  }

  void _showEditDialog(Map item) {
    setState(() {
      name = item['name'] ?? '';
      keterangan = item['keterangan'] ?? '';
      tanggalPembelian = item['tanggal_pembelian'] ?? '';
      tanggalPeminjaman = item['tanggal_peminjaman'] ?? '';
      oldImagePath = item['foto_barang']; // simpan path lama
    });

    _tanggalPembelian =
        tanggalPembelian.isNotEmpty ? DateTime.parse(tanggalPembelian) : null;
    _tanggalPeminjaman =
        tanggalPeminjaman.isNotEmpty ? DateTime.parse(tanggalPeminjaman) : null;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Edit Inventaris'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: name,
                  decoration: InputDecoration(labelText: 'Nama'),
                  onChanged: (val) => name = val,
                ),
                TextFormField(
                  initialValue: keterangan,
                  decoration: InputDecoration(labelText: 'Keterangan'),
                  onChanged: (val) => keterangan = val,
                ),
                SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _tanggalPembelian ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );

                    if (picked != null) {
                      setState(() {
                        _tanggalPembelian = picked;
                        tanggalPembelian =
                            DateFormat('dd-MM-yyyy').format(picked);
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Tanggal Pembelian',
                      labelStyle:
                          TextStyle(color: Color.fromARGB(255, 101, 19, 116)),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 101, 19, 116), width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _tanggalPembelian == null
                              ? 'Select Start Date'
                              : DateFormat('dd-MM-yyyy')
                                  .format(_tanggalPembelian!),
                        ),
                        Icon(Icons.calendar_today, color: Colors.orange),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),

                // Tanggal peminjaman
                if (_tanggalPeminjaman != null)
                  Text(
                    'Tanggal Peminjaman: ${DateFormat('dd-MM-yyyy').format(_tanggalPeminjaman!)}',
                  ),
                SizedBox(height: 10),
                Builder(
                  builder: (context) {
                    if (_image != null) {
                      return Image.file(_image!, height: 100);
                    } else if (oldImagePath != null &&
                        oldImagePath!.isNotEmpty) {
                      return Image.network(
                        oldImagePath!.startsWith('http')
                            ? oldImagePath!
                            : 'https://portal.eksam.cloud/storage/$oldImagePath',
                        height: 100,
                        errorBuilder: (context, error, stackTrace) =>
                            Text('Gagal muat gambar lama'),
                      );
                    } else {
                      return Text('Tidak ada gambar');
                    }
                  },
                ),
                SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    await _pickImage();
                  },
                  child: Text(
                    'Ganti Foto Barang',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.blue,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                await updateInventory(item['id'].toString());
                Navigator.pop(context);
              },
              child: Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inventaris Kantor')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          SizedBox(height: 20),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : _inventoryList.isEmpty
                    ? Center(child: Text('Belum ada data inventaris'))
                    : Scrollbar(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowHeight: 40,
                              dataRowHeight: 48,
                              columnSpacing: 20,
                              columns: const [
                                DataColumn(
                                    label: Text('No',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('Nama',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('Keterangan',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('Tanggal Pembelian',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('Tanggal Peminjaman',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('Status',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                              ],
                              rows: List<DataRow>.generate(
                                  _pagedInventory.length, (index) {
                                final item = _pagedInventory[index];
                                final status = item['status'];
                                final statusText =
                                    (status is Map && status['name'] != null)
                                        ? status['name'].toString()
                                        : 'Tidak diketahui';
                                return DataRow(cells: [
                                  DataCell(Text(
                                      '${_currentPage * _rowsPerPage + index + 1}',
                                      style: TextStyle(fontSize: 12))),
                                  DataCell(Text(item['name'] ?? '-',
                                      style: TextStyle(fontSize: 12))),
                                  DataCell(Text(item['keterangan'] ?? '-',
                                      style: TextStyle(fontSize: 12))),
                                  DataCell(Text(
                                      item['tanggal_pembelian'] ?? '-',
                                      style: TextStyle(fontSize: 12))),
                                  DataCell(Text(
                                      item['tanggal_peminjaman'] ?? '-',
                                      style: TextStyle(fontSize: 12))),
                                  DataCell(Text(
                                    statusText,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          _getStatusColor(status?['id'] ?? 0),
                                    ),
                                  )),
                                  DataCell(
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _showEditDialog(item);
                                        } else if (value == 'delete') {
                                          deleteInventory(
                                              item['id'].toString());
                                        }
                                      },
                                      itemBuilder: (BuildContext context) => [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit, size: 18),
                                              SizedBox(width: 8),
                                              Text('Edit'),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete, size: 18),
                                              SizedBox(width: 8),
                                              Text('Delete'),
                                            ],
                                          ),
                                        ),
                                      ],
                                      child: Icon(Icons.more_vert),
                                    ),
                                  ),
                                ]);
                              }),
                            ),
                          ),
                        ),
                      ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: _currentPage > 0
                    ? () => setState(() => _currentPage--)
                    : null,
              ),
              Text('Halaman ${_currentPage + 1}'),
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed:
                    (_currentPage + 1) * _rowsPerPage < _inventoryList.length
                        ? () => setState(() => _currentPage++)
                        : null,
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
