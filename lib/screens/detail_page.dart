import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:image_picker/image_picker.dart';

class DetailPage extends StatefulWidget {
  final String? kota_asal;
  final String? kota_tujuan;
  final String? berat;
  final String? kurir;
  final int userId;

  const DetailPage({
    super.key,
    this.kota_asal,
    this.kota_tujuan,
    this.berat,
    this.kurir,
    required this.userId
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  List listData = [];
  var strKey = "e5effe93f8bdd6e8e8f09d1d4a1a42c6";
  bool isLoading = false;
  final ImagePicker _picker = ImagePicker();
  XFile? _buktiTransferFile;

  final List<Map<String, dynamic>> staticData = [
    {
      "service": "TIKI Regular",
      "description": "Pengiriman Regular",
      "cost": [{"value": 10000, "etd": "3-5"}],
    },
    {
      "service": "TIKI Express",
      "description": "Pengiriman Express",
      "cost": [{"value": 20000, "etd": "1-2"}],
    },
  ];

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse("https://api.rajaongkir.com/starter/cost"),
        body: {
          "key": strKey,
          "origin": widget.kota_asal,
          "destination": widget.kota_tujuan,
          "weight": widget.berat,
          "courier": widget.kurir?.toLowerCase()
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          listData = data['rajaongkir']['results'][0]['costs'];
        });
      } else {
        throw Exception('Gagal memuat data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        listData = staticData;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> addShipping(double shippingCost) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://api-ppb.vercel.app/api/carts/add-shipping'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': widget.userId,
          'kota_asal': widget.kota_asal,
          'kota_tujuan': widget.kota_tujuan,
          'biaya_ongkir': shippingCost,
          'weight': double.parse(widget.berat ?? '0'),
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _showPaymentDialog(responseData);
      } else {
        throw Exception('Gagal menambahkan biaya pengiriman');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> generatePDF(Map<String, dynamic> data) async {
    final doc = pw.Document();

    try {
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'BUKTI PEMBAYARAN',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                ...data['items'].map<pw.Widget>((item) {
                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Produk: ${item['product_name']}'),
                      pw.Text('Harga: Rp ${item['price']}'),
                      pw.Text('Jumlah: ${item['quantity']}'),
                      pw.Text('Subtotal: Rp ${item['subtotal']}'),
                      pw.SizedBox(height: 10),
                    ],
                  );
                }).toList(),
                pw.Divider(),
                pw.Text('Detail Pengiriman:'),
                pw.Text('Dari: ${data['shipping']['city_from']}'),
                pw.Text('Ke: ${data['shipping']['city_to']}'),
                pw.Text('Berat: ${data['shipping']['weight']} kg'),
                pw.Text('Biaya Pengiriman: Rp ${data['shipping']['shipping_cost']}'),
                pw.Divider(),
                pw.Text(
                  'Total Pembayaran: Rp ${data['total']}',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Dapatkan directory temporary
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/bukti_pembayaran.pdf');

      // Simpan PDF ke file
      await file.writeAsBytes(await doc.save());

      // Buka file PDF
      OpenFile.open(file.path);

    } catch (e) {
      print('Error generating PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat PDF: $e')),
      );
    }
  }

  // Fungsi untuk memilih gambar bukti transfer
  Future<void> _pickBuktiTransfer() async {
    // Mengambil foto bukti transfer dari kamera atau galeri
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);  // Atau bisa ImageSource.camera untuk langsung mengambil foto
    if (pickedFile != null) {
      setState(() {
        _buktiTransferFile = pickedFile;
      });

      // Menampilkan foto bukti transfer langsung setelah dipilih
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Foto bukti transfer berhasil dipilih')),
      );
    }
  }

  void _showPaymentDialog(Map<String, dynamic> data) {
    // Fungsi untuk memeriksa apakah foto sudah di-upload
    bool isPhotoUploaded() {
      return _buktiTransferFile != null;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Total Pembayaran: Rp ${data['total']}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Silakan upload bukti transfer Anda'),
                  // Tombol untuk memilih gambar bukti transfer
                  ElevatedButton(
                    onPressed: _pickBuktiTransfer,
                    child: Text('Pilih Foto Bukti Transfer'),
                  ),
                  if (_buktiTransferFile != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Image.file(
                        File(_buktiTransferFile!.path),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                ],
              ),
              actions: [
                // Tombol "Upload Bukti Transfer"
                TextButton(
                  onPressed: () async {
                    // Cek jika foto telah di-upload
                    if (_buktiTransferFile != null) {
                      // Simpan gambar bukti transfer
                      final directory = await getApplicationDocumentsDirectory();
                      final file = File('${directory.path}/bukti_transfer_${DateTime.now().millisecondsSinceEpoch}.jpg');
                      await file.writeAsBytes(await _buktiTransferFile!.readAsBytes());

                      // Memperbarui UI setelah upload
                      setState(() {}); // Ini untuk memastikan UI ter-refresh

                      // Membuat PDF bukti pembayaran setelah upload
                      generatePDF(data);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Bukti transfer berhasil di-upload!')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Pilih foto bukti transfer terlebih dahulu')),
                      );
                    }
                  },
                  child: Text('Upload Bukti Transfer'),
                ),
                // Tombol "Selesai" hanya muncul setelah foto bukti transfer di-upload
                if (isPhotoUploaded())
                  TextButton(
                    onPressed: () async {
                      // Lakukan POST ke API checkout dan tunggu hasilnya
                      bool success = await completeCheckout();
                      if (success) {
                        Navigator.pop(context);  // Menutup dialog setelah checkout berhasil
                        Navigator.pushReplacementNamed(context, '/dashboard');  // Navigasi ke /dashboard
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal menyelesaikan checkout')),
                        );
                      }
                    },
                    child: Text('Selesai'),
                  ),
                // Tombol "Batal"
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Batal dan tutup dialog
                  },
                  child: Text('Batal'),
                ),
              ],
            );
          },
        );
      },
    );
  }

// Fungsi untuk memanggil API checkout
  Future<bool> completeCheckout() async {
    try {
      final response = await http.post(
        Uri.parse("https://api-ppb.vercel.app/api/carts/checkout"),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': widget.userId,
          'is_paid': true,
        }),
      );

      if (response.statusCode == 200) {
        // Jika berhasil
        return true;
      } else {
        throw Exception('Gagal menyelesaikan checkout');
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Ongkos Kirim ${widget.kurir?.toUpperCase() ?? ''}"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: listData.length,
              itemBuilder: (context, index) {
                final item = listData[index];
                final cost = item['cost'][0];

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item['service'] ?? '',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                            Text(
                              'Rp ${cost['value']}',
                              style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item['description'] ?? ''),
                            Text('${cost['etd']} Hari'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              double shippingCost = double.parse(cost['value'].toString());
                              addShipping(shippingCost);
                            },
                            child: const Text('Pilih'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
