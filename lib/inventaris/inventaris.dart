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
  int _currentPage = 0;
  String? userId;
  final int _rowsPerPage = 10;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchInventory();
  }

  List<dynamic> get _pagedInventory {
    int start = _currentPage * _rowsPerPage;
    int end = start + _rowsPerPage;
    end = end > _inventoryList.length ? _inventoryList.length : end;
    return _inventoryList.sublist(start, end);
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
    } finally {
      setState(() {
        isLoading = false;
      });
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
        await fetchInventory();
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
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                await updateInventory(item['id'].toString());
                Navigator.pop(context);
              }
            },
            child: Text('Simpan'),
          ),
        ],
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
                                    statusText,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          _getStatusColor(status?['id'] ?? 0),
                                    ),
                                  )),
                                  DataCell(Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit, size: 18),
                                        onPressed: () => _showEditDialog(item),
                                        padding: EdgeInsets.zero,
                                        constraints: BoxConstraints(),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete, size: 18),
                                        onPressed: () => deleteInventory(
                                            item['id'].toString()),
                                        padding: EdgeInsets.zero,
                                        constraints: BoxConstraints(),
                                      ),
                                    ],
                                  )),
                                ]);
                              }),
                            ),
                          ),
                        ),
                      ),
          ),
          // if (_inventoryList.isEmpty)
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
