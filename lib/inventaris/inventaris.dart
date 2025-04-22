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
  List<dynamic> _inventoryList = [];

  @override
  void initState() {
    super.initState();
    fetchInventory();
  }

  Future<void> fetchInventory() async {
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
            print("Data inventory: $_inventoryList");
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
    }
  }

  Future<void> addInventory() async {
    try {
      final url = Uri.parse(
          'https://portal.eksam.cloud/api/v1/other/add-self-inventory');
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      String? token = localStorage.getString('token');

      if (token == null) {
        print('Token tidak ditemukan');
        return;
      }

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'keterangan': keterangan,
        }),
      );

      print('Response Add: ${response.body}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['status'] == 'success') {
          await fetchInventory();
        }
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
      request.fields['status'] = '2';

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

  // String _getStatusText(int status) {
  //   switch (status) {
  //     case 1:
  //       return 'Disetujui';
  //     case 2:
  //       return 'Menunggu';
  //     case 3:
  //       return 'Ditolak';
  //     default:
  //       return 'Tidak diketahui';
  //   }
  // }

  Color _getStatusColor(int status) {
    switch (status) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
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
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Aksi')),
                      ],
                      rows: _inventoryList.map((item) {
                        final status = item['status'];
                        return DataRow(cells: [
                          DataCell(Text(item['name'] ?? '-')),
                          DataCell(Text(item['keterangan'] ?? '-')),
                          DataCell(Text(
                            status != null && status['nama'] != null
                                ? status['nama']
                                : 'Tidak diketahui',
                            style: TextStyle(
                              color: _getStatusColor(status),
                            ),
                          )),
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
