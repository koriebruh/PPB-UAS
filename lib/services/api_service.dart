import 'dart:convert';  
import 'package:http/http.dart' as http;  
import '../models/product.dart';  
  
class ApiService {  
  static const String baseUrl = 'https://api-ppb.vercel.app';
  
  // Menambahkan header Authorization dengan token pada request  
  Future<http.Response> _makeRequest(  
    String method,  
    String endpoint, {  
    Map<String, String>? headers,  
    dynamic body,  
  }) async {  
    final requestHeaders = {  
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?headers,  
    };  
  
    final Uri url = Uri.parse('$baseUrl$endpoint');  
    switch (method) {  
      case 'POST':  
        return http.post(url, headers: requestHeaders, body: json.encode(body));  
      case 'GET':  
        return http.get(url, headers: requestHeaders);  
      case 'PUT':  
        return http.put(url, headers: requestHeaders, body: json.encode(body));  
      case 'DELETE':  
        return http.delete(url, headers: requestHeaders);  
      default:  
        throw Exception('Unsupported HTTP method');  
    }  
  }  
  
  // Mendaftar pengguna baru  
  Future<bool> registerUser(  
      String user, String username, String password, String role) async {  
    final response = await _makeRequest(  
      'POST',  
      '/api/users',  
      body: {  
        'user': user, // Mengirim name  
        'username': username, // Mengirim username  
        'password': password, // Mengirim password  
        'role': role, // Mengirim role  
      },  
    );  
  
    if (response.statusCode == 201 || response.statusCode == 200) {  
      return true;  
    } else {  
      throw Exception('Gagal mendaftar pengguna: ${response.body}');  
    }  
  }  
  
  // Login pengguna  
  Future<Map<String, dynamic>> loginUser(  
      String username, String password) async {  
    final response = await _makeRequest(  
      'POST',  
      '/api/users/login',  
      body: {  
        'username': username, // Hanya mengirim username  
        'password': password, // Hanya mengirim password  
      },  
    );  
  
    if (response.statusCode == 200) {  
      final data = json.decode(response.body);  
      // Pastikan respons mengandung data yang diharapkan  
      if (data['data'] == null ||  
          data['data']['id'] == null ||  
          data['data']['role'] == null) {  
        throw Exception('Respons tidak lengkap: $data');  
      }  
      // Mengembalikan userId dan role  
      return {  
        'userId': data['data']['id'], // Mengambil id sebagai userId  
        'role': data['data']['role'], // Mengambil role  
      };  
    } else {  
      print('Error: ${response.statusCode} - ${response.body}');  
      throw Exception('Gagal login: ${response.body}');  
    }  
  }

  Future<List<Product>> fetchProducts() async {
    try {
      print('Mulai fetch products...'); // Log awal request
      final response = await _makeRequest('GET', '/api/products');
      print('Status code: ${response.statusCode}'); // Log status code
      print('Response body: ${response.body}'); // Log response body

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception('Gagal memuat produk: ${response.body}');
      }
    } catch (e) {
      print('Error dalam fetchProducts: $e'); // Log error
      throw e;
    }
  }

  // Mengambil produk berdasarkan ID  
  Future<Product> fetchProductById(int productId) async {  
    final response = await _makeRequest('GET', '/api/products/$productId');  
  
    if (response.statusCode == 200) {  
      final Map<String, dynamic> data = json.decode(response.body);  
      return Product.fromJson(data);  
    } else {  
      throw Exception('Gagal mengambil detail produk: ${response.body}');  
    }  
  }  
  
  // Membuat produk baru  
  Future<Product> createProduct(  
      String name, String description, double price, String imageUrl) async {  
    final response = await http.post(  
      Uri.parse('$baseUrl/api/products'),  
      headers: {  
        'Accept': 'application/json',  
        'Content-Type': 'application/json',  
      },  
      body: jsonEncode({  
        'name': name,  
        'description': description,  
        'price': price,  
        'imageUrl': imageUrl,  
      }),  
    );  
  
    if (response.statusCode == 201) {  
      // Mengembalikan produk yang baru dibuat  
      final productData = jsonDecode(response.body);  
      // Pastikan bahwa data produk yang dikembalikan memiliki struktur yang benar  
      if (productData is Map<String, dynamic>) {  
        return Product.fromJson(  
            productData); // Mengonversi JSON ke objek Product  
      } else {  
        throw Exception('Data produk tidak valid');  
      }  
    } else {  
      // Menangani kesalahan dengan lebih baik  
      final errorMessage =  
          jsonDecode(response.body)['message'] ?? 'Gagal membuat produk';  
      throw Exception('$errorMessage');  
    }  
  }  
  
  // Memperbarui produk  
  Future<bool> updateProduct(Product product) async {  
    final response = await _makeRequest(  
      'PUT',  
      '/api/products/${product.id}',  
      body: product.toJson(),  
    );  
  
    if (response.statusCode == 200) {  
      return true;  
    } else {  
      throw Exception('Gagal memperbarui produk: ${response.body}');  
    }  
  }  
  
  // Menghapus produk  
  Future<bool> deleteProduct(int productId) async {  
    final response = await _makeRequest('DELETE', '/api/products/$productId');  
  
    if (response.statusCode == 200) {  
      return true;  
    } else {  
      throw Exception('Gagal menghapus produk: ${response.body}');  
    }  
  }  
  
  // Menambahkan produk ke keranjang  
  Future<bool> addToCart(int userId, int productId, int quantity) async {  
    final response = await _makeRequest(  
      'POST',  
      '/api/carts',  
      body: {  
        'user_id': userId,  
        'product_id': productId,  
        'jumlah': quantity,  
      },  
    );  
  
    if (response.statusCode == 201 || response.statusCode == 200) {  
      return true;  
    } else {  
      throw Exception('Gagal menambahkan ke keranjang: ${response.body}');  
    }  
  }  
  
  // Mengambil keranjang saat ini  
  Future<List<Map<String, dynamic>>> getCurrentCart(int userId) async {  
    final response = await _makeRequest(  
      'POST',  
      '/api/carts/user',  
      body: {  
        'user_id': userId,  
      },  
    );  
  
    if (response.statusCode == 200) {  
      final Map<String, dynamic> jsonResponse = json.decode(response.body);  
  
      // Pastikan untuk mengakses data dari kunci 'items'  
      if (jsonResponse['items'] is List) {  
        return (jsonResponse['items'] as List)  
            .map((item) => item as Map<String, dynamic>)  
            .toList();  
      } else {  
        throw Exception(  
            'Data tidak dalam format yang diharapkan: ${jsonResponse['items']}');  
      }  
    } else {  
      throw Exception('Gagal mengambil keranjang: ${response.body}');  
    }  
  }  
  
  // Menghapus produk dari keranjang  
  Future<bool> removeFromCart(int userId, int productId) async {  
    final response = await _makeRequest(  
      'POST',  
      '/api/carts/remove',  
      body: {  
        'user_id': userId,  
        'product_id': productId,  
      },  
    );  
  
    if (response.statusCode == 200) {  
      return true;  
    } else {  
      throw Exception('Gagal menghapus dari keranjang: ${response.body}');  
    }  
  }  
  
  // Menambahkan biaya pengiriman  
  Future<bool> addShipping(int userId, String kotaAsal, String kotaTujuan,  
      double biayaOngkir, double weight) async {  
    final response = await _makeRequest(  
      'POST',  
      '/api/carts/add-shipping',  
      body: {  
        'user_id': userId,  
        'kota_asal': kotaAsal,  
        'kota_tujuan': kotaTujuan,  
        'biaya_ongkir': biayaOngkir,  
        'weight': weight,  
      },  
    );  
  
    if (response.statusCode == 200) {  
      return true;  
    } else {  
      throw Exception('Gagal menambahkan biaya pengiriman: ${response.body}');  
    }  
  }  
  
  // Memvalidasi pembayaran  
  Future<bool> validatePayment(int userId, bool isPaid) async {  
    final response = await _makeRequest(  
      'POST',  
      '/api/carts/checkout',  
      body: {  
        'user_id': userId,  
        'is_paid': isPaid,  
      },  
    );  
  
    if (response.statusCode == 200) {  
      return true;  
    } else {  
      throw Exception('Gagal memvalidasi pembayaran: ${response.body}');  
    }  
  }  
  
  // Memperbarui pengguna  
  Future<bool> updateUser(int userId, String user, String username,  
      String password, String role) async {  
    final response = await _makeRequest(  
      'PUT',  
      '/api/users/$userId',  
      body: {  
        'user': user, // Mengirimkan nama lengkap pengguna  
        'username': username, // Mengirimkan username  
        'password': password, // Mengirimkan password  
        'role': role, // Mengirimkan role  
      },  
    );  
  
    if (response.statusCode == 200) {  
      return true;  
    } else {  
      throw Exception('Gagal memperbarui pengguna: ${response.body}');  
    }  
  }  
}  
