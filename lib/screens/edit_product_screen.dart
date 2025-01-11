import 'package:flutter/material.dart';  
import '../services/api_service.dart';  
import '../models/product.dart';  
  
class EditProductScreen extends StatefulWidget {  
  final Product product;  
  
  const EditProductScreen({super.key, required this.product});  
  
  @override  
  State<EditProductScreen> createState() => _EditProductScreenState();  
}  
  
class _EditProductScreenState extends State<EditProductScreen> {  
  final ApiService _apiService = ApiService();  
  final TextEditingController _nameController = TextEditingController();  
  final TextEditingController _priceController = TextEditingController();  
  final TextEditingController _descriptionController = TextEditingController();  
  
  @override  
  void initState() {  
    super.initState();  
    _nameController.text = widget.product.name;  
    _priceController.text = widget.product.price.toString();  
    _descriptionController.text = widget.product.description;  
  }  
  
  Future<void> _updateProduct() async {  
    final updatedProduct = Product(  
      id: widget.product.id,  
      name: _nameController.text,  
      price: double.tryParse(_priceController.text) ?? 0.0,  
      description: _descriptionController.text,  
      imageUrl: widget.product.imageUrl, // Assuming imageUrl is not being changed  
    );  
  
    try {  
      await _apiService.updateProduct(updatedProduct);  
      ScaffoldMessenger.of(context).showSnackBar(  
        const SnackBar(content: Text('Produk berhasil diperbarui')),  
      );  
      Navigator.pop(context); // Kembali ke halaman sebelumnya  
    } catch (e) {  
      ScaffoldMessenger.of(context).showSnackBar(  
        SnackBar(content: Text('Gagal memperbarui produk: $e')),  
      );  
    }  
  }  
  
  @override  
  Widget build(BuildContext context) {  
    return Scaffold(  
      appBar: AppBar(title: const Text('Edit Produk')),  
      body: Padding(  
        padding: const EdgeInsets.all(16.0),  
        child: Column(  
          crossAxisAlignment: CrossAxisAlignment.stretch,  
          children: [  
            TextField(  
              controller: _nameController,  
              decoration: const InputDecoration(labelText: 'Nama Produk'),  
            ),  
            const SizedBox(height: 16),  
            TextField(  
              controller: _priceController,  
              decoration: const InputDecoration(labelText: 'Harga Produk'),  
              keyboardType: TextInputType.number,  
            ),  
            const SizedBox(height: 16),  
            TextField(  
              controller: _descriptionController,  
              decoration: const InputDecoration(labelText: 'Deskripsi Produk'),  
            ),  
            const SizedBox(height: 32),  
            ElevatedButton(  
              onPressed: _updateProduct,  
              child: const Text('Perbarui Produk'),  
            ),  
          ],  
        ),  
      ),  
    );  
  }  
}  
