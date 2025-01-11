import 'package:flutter/material.dart';  
import 'package:provider/provider.dart';  
import 'package:shared_preferences/shared_preferences.dart';  
import 'package:uas_ppb/screens/update_page_screen.dart';  
import 'package:uas_ppb/utils/product_provider.dart';  
import 'package:url_launcher/url_launcher.dart';  
import 'package:connectivity_plus/connectivity_plus.dart';  
import '../services/api_service.dart';  
import '../widgets/product_card.dart';  
import '../models/product.dart';  
import '../screens/product_detail_screen.dart'; // Import halaman detail produk  
  
class DashboardScreen extends StatefulWidget {  
  const DashboardScreen({super.key});  
  
  @override  
  State<DashboardScreen> createState() => _DashboardScreenState();  
}  
  
class _DashboardScreenState extends State<DashboardScreen> {  
  String? _role;  
  
  @override  
  void initState() {  
    super.initState();  
    _loadUserRole(); // Load user role from SharedPreferences  
    Provider.of<ProductProvider>(context, listen: false)  
        .fetchProducts(); // Fetch products  
  }  
  
  Future<void> _loadUserRole() async {  
    final prefs = await SharedPreferences.getInstance();  
    setState(() {  
      _role = prefs.getString('role'); // Get the role from SharedPreferences  
    });  
  }  
  
  Future<bool> _checkInternetConnection() async {  
    var connectivityResult = await (Connectivity().checkConnectivity());  
    return connectivityResult != ConnectivityResult.none;  
  }  
  
  void _callCenter() async {  
    if (await _checkInternetConnection()) {  
      const String callCenter = 'tel:+628123456789';  
      if (await canLaunch(callCenter)) {  
        await launch(callCenter);  
      } else {  
        ScaffoldMessenger.of(context).showSnackBar(  
          const SnackBar(content: Text('Tidak dapat melakukan panggilan')),  
        );  
      }  
    } else {  
      ScaffoldMessenger.of(context).showSnackBar(  
        const SnackBar(content: Text('Tidak ada koneksi internet')),  
      );  
    }  
  }  
  
  void _sendSMS() async {  
    if (await _checkInternetConnection()) {  
      const String smsCenter = 'sms:+628123456789';  
      if (await canLaunch(smsCenter)) {  
        await launch(smsCenter);  
      } else {  
        ScaffoldMessenger.of(context).showSnackBar(  
          const SnackBar(content: Text('Tidak dapat mengirim SMS')),  
        );  
      }  
    } else {  
      ScaffoldMessenger.of(context).showSnackBar(  
        const SnackBar(content: Text('Tidak ada koneksi internet')),  
      );  
    }  
  }  
  
  void _openMaps() async {  
    if (await _checkInternetConnection()) {  
      const String locationUrl = 'https://goo.gl/maps/example';  
      if (await canLaunch(locationUrl)) {  
        await launch(locationUrl);  
      } else {  
        ScaffoldMessenger.of(context).showSnackBar(  
          const SnackBar(content: Text('Tidak dapat membuka peta')),  
        );  
      }  
    } else {  
      ScaffoldMessenger.of(context).showSnackBar(  
        const SnackBar(content: Text('Tidak ada koneksi internet')),  
      );  
    }  
  }  
  
  Future<void> _logout() async {  
    final prefs = await SharedPreferences.getInstance();  
    await prefs.clear(); // Menghapus semua data dari SharedPreferences  
    Navigator.pushReplacementNamed(  
        context, '/login'); // Navigasi kembali ke halaman login  
  }  
  
  void _navigateToUpdateUser() async {  
    final prefs = await SharedPreferences.getInstance();  
    int userId =  
        prefs.getInt('user_id') ?? 0; // Ambil userId dari SharedPreferences  
  
    Navigator.push(  
      context,  
      MaterialPageRoute(  
        builder: (context) => UpdateUserScreen(  
            userId: userId), // Navigasi ke halaman update pengguna  
      ),  
    );  
  }  
  
  @override  
  Widget build(BuildContext context) {  
    return Scaffold(  
      appBar: AppBar(  
        title: const Text('Dashboard Produk'),  
        actions: [  
          IconButton(  
            icon: const Icon(Icons.shopping_cart),  
            onPressed: () {  
              Navigator.pushNamed(context, '/cart');  
            },  
          ),  
          IconButton(  
            icon: const Icon(Icons.edit),  
            onPressed:  
                _navigateToUpdateUser, // Navigasi ke halaman update pengguna  
          ),  
          IconButton(  
            icon: const Icon(Icons.logout), // Ikon logout  
            onPressed: _logout, // Fungsi logout  
          ),  
        ],  
      ),  
      body: Consumer<ProductProvider>(  
        builder: (context, productProvider, child) {  
          final products = productProvider.products;  
          if (products.isEmpty) {  
            return const Center(child: CircularProgressIndicator());  
          } else {  
            return GridView.builder(  
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(  
                crossAxisCount: 2,  
                childAspectRatio: 0.75,  
                crossAxisSpacing: 10.0,  
                mainAxisSpacing: 10.0,  
              ),  
              itemCount: products.length,  
              itemBuilder: (context, index) {  
                final product = products[index];  
                return ProductCard(  
                  name: product.name,  
                  description: product.description,  
                  price: product.price.toString(),  
                  imageUrl: product.imageUrl,  
                  onTap: () {  
                    Navigator.push(  
                      context,  
                      MaterialPageRoute(  
                        builder: (context) => ProductDetailScreen(  
                          productId: product.id,  
                        ), // Navigasi ke halaman detail produk  
                      ),  
                    );  
                  },  
                );  
              },  
            );  
          }  
        },  
      ),  
      floatingActionButton: _role == 'admin' // Show button only for admin  
          ? FloatingActionButton(  
              onPressed: () {  
                Navigator.pushNamed(context, '/adminProducts');  
              },  
              child: const Icon(Icons.add),  
            )  
          : null,  
      bottomNavigationBar: BottomAppBar(  
        child: Row(  
          mainAxisAlignment: MainAxisAlignment.spaceAround,  
          children: [  
            IconButton(  
              icon: const Icon(Icons.phone),  
              onPressed: _callCenter,  
            ),  
            IconButton(  
              icon: const Icon(Icons.message),  
              onPressed: _sendSMS,  
            ),  
            IconButton(  
              icon: const Icon(Icons.map),  
              onPressed: _openMaps,  
            ),  
          ],  
        ),  
      ),  
    );  
  }  
}  
