import 'package:flutter/material.dart';  
import '../models/product.dart';  
import '../services/api_service.dart';  
  
class ProductProvider with ChangeNotifier {  
  final ApiService _apiService = ApiService();  
  List<Product> _products = [];  
  
  List<Product> get products => _products;

  double? get totalPrice => null;  
  
  Future<void> fetchProducts() async {  
    _products = await _apiService.fetchProducts();  
    notifyListeners(); // Memberitahu listener bahwa data telah diperbarui  
  }  
  
  Future<void> addProduct(  
      String name, String description, double price, String imageUrl) async {  
    final newProduct =  
        await _apiService.createProduct(name, description, price, imageUrl);  
    _products.add(newProduct); // Menambahkan produk baru ke daftar  
    notifyListeners(); // Memberitahu listener bahwa data telah diperbarui  
  }  
  
  Future<void> deleteProduct(int productId) async {  
    await _apiService.deleteProduct(productId);  
    _products.removeWhere((product) => product.id == productId);  
    notifyListeners(); // Memberitahu listener bahwa data telah diperbarui  
  }  
}  
