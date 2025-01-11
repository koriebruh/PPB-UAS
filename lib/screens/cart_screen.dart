import 'dart:convert';      
import 'package:flutter/material.dart';      
import 'package:shared_preferences/shared_preferences.dart';      
import 'package:uas_ppb/models/model_kota.dart';      
import '../services/api_service.dart';      
import 'package:http/http.dart' as http;      
import 'detail_page.dart';      
import 'package:dropdown_search/dropdown_search.dart';      
      
class CartScreen extends StatefulWidget {      
  const CartScreen({Key? key}) : super(key: key);      
      
  @override      
  State<CartScreen> createState() => _CartScreenState();      
}      
      
class _CartScreenState extends State<CartScreen> {      
  final ApiService _apiService = ApiService();      
  List<Map<String, dynamic>> _cartItems = [];      
  double _totalPrice = 0.0;      
      
  var strKey = "92d97e445ee8ff572e9774fdbc30e726";      
  String? strKotaAsal;      
  String? strKotaTujuan;      
  String? strBerat;      
  String? strEkspedisi;      
      
  final List<ModelKota> _staticCities = [      
    ModelKota(cityId: "1", cityName: "Jakarta", type: "Kota"),      
    ModelKota(cityId: "2", cityName: "Bandung", type: "Kota"),      
    ModelKota(cityId: "3", cityName: "Surabaya", type: "Kota"),      
  ];      
      
  @override      
  void initState() {      
    super.initState();      
    _fetchCartItems();      
  }      
      
  Future<void> _fetchCartItems() async {      
    final prefs = await SharedPreferences.getInstance();      
    final userId = prefs.getInt('user_id');      
      
    if (userId != null) {      
      try {      
        final cartData = await _apiService.getCurrentCart(userId);      
        setState(() {      
          _cartItems = cartData;      
          _calculateTotalPrice();      
        });      
      } catch (e) {      
        ScaffoldMessenger.of(context).showSnackBar(      
          SnackBar(content: Text('Gagal mengambil keranjang: $e')),      
        );      
      }      
    } else {      
      ScaffoldMessenger.of(context).showSnackBar(      
        const SnackBar(content: Text('Silakan login terlebih dahulu')),      
      );      
    }      
  }      
      
  void _calculateTotalPrice() {      
    _totalPrice = _cartItems.fold(      
        0.0, (sum, item) => sum + (item['subtotal']));      
  }      
      
  Future<void> _removeFromCart(int productId) async {      
    final prefs = await SharedPreferences.getInstance();      
    final userId = prefs.getInt('user_id');      
      
    if (userId != null) {      
      try {      
        await _apiService.removeFromCart(userId, productId);      
        setState(() {      
          _cartItems.removeWhere((item) => item['product_id'] == productId);      
          _calculateTotalPrice();      
        });      
        ScaffoldMessenger.of(context).showSnackBar(      
          const SnackBar(content: Text('Produk berhasil dihapus dari keranjang')),      
        );      
      } catch (e) {      
        ScaffoldMessenger.of(context).showSnackBar(      
          SnackBar(content: Text('Gagal menghapus produk: $e')),      
        );      
      }      
    }      
  }      
      
  @override      
  Widget build(BuildContext context) {      
    return Scaffold(      
      appBar: AppBar(title: const Text('Keranjang')),      
      body: Column(      
        children: [      
          Expanded(      
            child: _cartItems.isEmpty      
                ? const Center(child: Text('Keranjang kosong'))      
                : ListView.builder(      
                    itemCount: _cartItems.length,      
                    itemBuilder: (context, index) {      
                      final item = _cartItems[index];      
                      return ListTile(      
                        title: Text('Produk: ${item['product_name']}'),      
                        subtitle: Text('Jumlah: ${item['quantity']} - Rp${item['subtotal']}'),      
                        trailing: IconButton(      
                          icon: const Icon(Icons.delete),      
                          onPressed: () {      
                            _removeFromCart(item['product_id']);      
                          },      
                        ),      
                      );      
                    },      
                  ),      
          ),      
          Padding(      
            padding: const EdgeInsets.all(20),      
            child: Column(      
              crossAxisAlignment: CrossAxisAlignment.start,      
              children: [      
                DropdownSearch<ModelKota>(      
                  dropdownDecoratorProps: const DropDownDecoratorProps(      
                    dropdownSearchDecoration: InputDecoration(      
                      labelText: "Kota Asal",      
                      hintText: "Pilih Kota Asal",      
                    ),      
                  ),      
                  popupProps: const PopupProps.menu(      
                    showSearchBox: true,      
                  ),      
                  onChanged: (value) {      
                    strKotaAsal = value?.cityId;      
                  },      
                  itemAsString: (item) => "${item.type} ${item.cityName}",      
                  asyncItems: (text) async {      
                    try {      
                      var response = await http.get(Uri.parse(      
                          "https://api.rajaongkir.com/starter/city?key=${strKey}"));      
                      if (response.statusCode == 200) {      
                        List allKota = (jsonDecode(response.body) as Map<String, dynamic>)['rajaongkir']['results'];      
                        var dataKota = ModelKota.fromJsonList(allKota);      
                        return dataKota;      
                      } else {      
                        throw Exception('Gagal memuat data kota: ${response.statusCode}');      
                      }      
                    } catch (e) {      
                      print('Error fetching cities: $e');      
                      return _staticCities;      
                    }      
                  },      
                ),      
                const SizedBox(height: 20),      
                DropdownSearch<ModelKota>(      
                  dropdownDecoratorProps: const DropDownDecoratorProps(      
                    dropdownSearchDecoration: InputDecoration(      
                      labelText: "Kota Tujuan",      
                      hintText: "Pilih Kota Tujuan",      
                    ),      
                  ),      
                  popupProps: const PopupProps.menu(      
                    showSearchBox: true,      
                  ),      
                  onChanged: (value) {      
                    strKotaTujuan = value?.cityId;      
                  },      
                  itemAsString: (item) => "${item.type} ${item.cityName}",      
                  asyncItems: (text) async {      
                    try {      
                      var response = await http.get(Uri.parse(      
                          "https://api.rajaongkir.com/starter/city?key=${strKey}"));      
                      if (response.statusCode == 200) {      
                        List allKota = (jsonDecode(response.body) as Map<String, dynamic>)['rajaongkir']['results'];      
                        var dataKota = ModelKota.fromJsonList(allKota);      
                        return dataKota;      
                      } else {      
                        throw Exception('Gagal memuat data kota: ${response.statusCode}');      
                      }      
                    } catch (e) {      
                      print('Error fetching cities: $e');      
                      return _staticCities;      
                    }      
                  },      
                ),      
                const SizedBox(height: 20),      
                TextField(      
                  keyboardType: TextInputType.number,      
                  decoration: const InputDecoration(      
                    labelText: "Berat Paket (gram)",      
                    hintText: "Input Berat Paket",      
                  ),      
                  onChanged: (text) {      
                    strBerat = text;      
                  },      
                ),      
                const SizedBox(height: 20),      
                DropdownSearch<String>(      
                  items: const ["jne", "tiki", "pos"],      
                  dropdownDecoratorProps: const DropDownDecoratorProps(      
                    dropdownSearchDecoration: InputDecoration(      
                      labelText: "Kurir",      
                      hintText: "Kurir",      
                    ),      
                  ),      
                  onChanged: (text) {      
                    strEkspedisi = text?.toLowerCase();      
                  },      
                ),      
                const SizedBox(height: 20),      
                ElevatedButton(      
                  onPressed: () async {      
                    if (strKotaAsal == null ||      
                        strKotaTujuan == null ||      
                        strBerat == null ||      
                        strEkspedisi == null) {      
                      const snackBar = SnackBar(content: Text("Ups, form tidak boleh kosong!"));      
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);      
                    } else {      
                      final prefs = await SharedPreferences.getInstance();      
                      final userId = prefs.getInt('user_id');      
      
                      if (userId != null) {      
                        Navigator.push(      
                          context,      
                          MaterialPageRoute(      
                            builder: (context) => DetailPage(      
                              kota_asal: strKotaAsal,      
                              kota_tujuan: strKotaTujuan,      
                              berat: strBerat,      
                              kurir: strEkspedisi,      
                              userId: userId, // Pass userId to DetailPage      
                            ),      
                          ),      
                        );      
                      } else {      
                        ScaffoldMessenger.of(context).showSnackBar(      
                          const SnackBar(content: Text('Silakan login terlebih dahulu')),      
                        );      
                      }      
                    }      
                  },      
                  child: const Text("Cek Ongkir"),      
                ),      
              ],      
            ),      
          ),      
        ],      
      ),      
      floatingActionButton: FloatingActionButton(      
        onPressed: () {      
          Navigator.pushNamed(context, '/payment');      
        },      
        child: const Icon(Icons.payment),      
      ),      
    );      
  }      
}    
