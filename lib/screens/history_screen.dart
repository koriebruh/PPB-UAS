import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<Map<String, dynamic>>>
      _cartHistory; // Menggunakan peta untuk data keranjang
  final ApiService _apiService = ApiService();
  final int userId = 1; // Ganti dengan ID pengguna yang sesuai

  @override
  void initState() {
    super.initState();
    _fetchCartHistory(); // Memanggil fungsi untuk mengambil riwayat belanja
  }

  Future<void> _fetchCartHistory() async {
    setState(() {
      _cartHistory =
          _apiService.getCurrentCart(userId); // Mengambil riwayat belanja
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Belanja'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _cartHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada riwayat belanja'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final cartItem = snapshot.data![index];
                return ListTile(
                  leading: const Icon(Icons.receipt),
                  title: Text('Pesanan ${cartItem['product_id']}'), // ID produk
                  subtitle:
                      Text('Jumlah: ${cartItem['jumlah']}'), // Jumlah produk
                  trailing: Text(
                      'Rp ${cartItem['total'] ?? 0}'), // Total pesanan, jika ada
                );
              },
            );
          }
        },
      ),
    );
  }
}
