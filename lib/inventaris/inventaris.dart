import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class InventoryScreen extends StatefulWidget {
  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _formKey = GlobalKey<FormState>();
  String? id;
  String name = '';
  String keterangan = '';
  List _inventoryList = [];

  @override
  void initState() {
    super.initState();
    fetchInventory();
    getProfil();
  }

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
        id = data['data']['id'].toString();
      });

      // Simpan user_id ke SharedPreferences
      localStorage.setInt('user_id', data['data']['id']);

      print("Profil pengguna: ${data['data']}");
    } catch (e) {
      print("Error mengambil profil pengguna: $e");
    }
  }

  Future<void> fetchInventory() async {
    try {
      final url = Uri.parse(
          'https://portal.eksam.cloud/api/v1/other/get-self-inventory');
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      String? token = localStorage.getString('token');

      if (token == null) {
        print('Token tidak ditemukan');
        return;
      }

      var request = http.MultipartRequest('GET', url);
      request.headers['Authorization'] = 'Bearer $token';

      var response = await request.send();
      var rp = await http.Response.fromStream(response);

      if (rp.statusCode == 200) {
        var data = jsonDecode(rp.body.toString());

        if (data['data'] != null && data['data'] is List) {
          setState(() {
            _inventoryList = data['data'];
          });
        } else {
          print('Data kosong atau format tidak sesuai');
        }
      } else {
        print('Gagal ambil data: ${rp.statusCode}');
        print(rp.body); // buat lihat isi error-nya
      }
    } catch (e) {
      print('Error fetchInventory: $e');
    }
  }

  Future<void> addInventory() async {
    try {
      final url = Uri.parse(
          'https://portal.eksam.cloud/api/v1/other/add-self-inventory');
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      String token = localStorage.getString('token') ?? '';

      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['name'] = name;
      request.fields['keterangan'] = keterangan;
      request.fields['status'] = '1';

      var response = await request.send();
      var rp = await http.Response.fromStream(response);

      if (rp.statusCode == 200) {
        // name = '';
        // keterangan = '';
        fetchInventory();
        print('Data berhasil ditambahkan');
      } else {
        print('Gagal tambah data: ${rp.statusCode}');
        print(rp.body);
      }
    } catch (e) {
      print('Error addInventory: $e');
    }
  }

  Future<void> updateInventory(String id) async {
    try {
      final url = Uri.parse(
          'https://portal.eksam.cloud/api/v1/other/edit-inventory/$id');
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      String token = localStorage.getString('token') ?? '';

      var request = http.MultipartRequest('PUT', url); // Sesuaikan metode
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['name'] = name;
      request.fields['keterangan'] = keterangan;
      request.fields['status'] = '1';

      var response = await request.send();
      var rp = await http.Response.fromStream(response);

      if (rp.statusCode == 200) {
        fetchInventory();
      } else {
        print('Gagal update: ${rp.statusCode}');
      }
    } catch (e) {
      print('Error updateInventory: $e');
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

  void _showEditDialog(Map item) {
    name = item['name'];
    keterangan = item['keterangan'];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit Inventaris'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: item['name'],
              decoration: InputDecoration(labelText: 'Nama'),
              onChanged: (val) => name = val,
            ),
            TextFormField(
              initialValue: item['keterangan'],
              decoration: InputDecoration(labelText: 'Keterangan'),
              onChanged: (val) => keterangan = val,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              updateInventory(item['id'].toString());
              Navigator.pop(context);
            },
            child: Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inventaris Kantor')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Form(
            key: _formKey,
            child: Column(children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nama Barang',
                  labelStyle: TextStyle(color: Colors.purple),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.purple),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.purple),
                  ),
                ),
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                onChanged: (val) => name = val,
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Keterangan',
                  labelStyle: TextStyle(color: Colors.purple),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.purple),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.purple),
                  ),
                ),
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                onChanged: (val) => keterangan = val,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    addInventory();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  minimumSize:
                      Size(double.infinity, 50), // lebar penuh & tinggi 50
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(40), // bikin melengkung penuh
                  ),
                  elevation: 4,
                ),
                child: Text(
                  'Tambah',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ]),
          ),
          SizedBox(height: 20),
          Expanded(
            child: _inventoryList.isEmpty
                ? Center(child: Text('Belum ada data inventaris'))
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Nama')),
                        DataColumn(label: Text('Keterangan')),
                        DataColumn(label: Text('Aksi')),
                      ],
                      rows: _inventoryList.map((item) {
                        return DataRow(cells: [
                          DataCell(Text(item['name'] ?? '')),
                          DataCell(Text(item['keterangan'] ?? '')),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, size: 20),
                                onPressed: () => _showEditDialog(item),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, size: 20),
                                onPressed: () =>
                                    deleteInventory(item['id'].toString()),
                              ),
                            ],
                          )),
                        ]);
                      }).toList(),
                    ),
                  ),
          ),
        ]),
      ),
    );
  }
}
