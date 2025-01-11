import 'package:flutter/material.dart';  
  
class ProductCard extends StatelessWidget {  
  final String name;  
  final String description;  
  final String price;  
  final String imageUrl;  
  final VoidCallback onTap;  
  
  const ProductCard({  
    super.key,  
    required this.name,  
    required this.description,  
    required this.price,  
    required this.imageUrl,  
    required this.onTap,  
  });  
  
  @override  
  Widget build(BuildContext context) {  
    return GestureDetector(  
      onTap: onTap, // Menambahkan onTap untuk navigasi  
      child: Card(  
        child: Column(  
          crossAxisAlignment: CrossAxisAlignment.start,  
          children: [  
            Image.network(imageUrl,  
                fit: BoxFit.cover, height: 100, width: double.infinity),  
            Padding(  
              padding: const EdgeInsets.all(8.0),  
              child: Text(name,  
                  style: const TextStyle(fontWeight: FontWeight.bold)),  
            ),  
            Padding(  
              padding: const EdgeInsets.symmetric(horizontal: 8.0),  
              child: Text(description,  
                  maxLines: 2, overflow: TextOverflow.ellipsis),  
            ),  
            Padding(  
              padding: const EdgeInsets.all(8.0),  
              child: Text('Rp$price',  
                  style: const TextStyle(color: Colors.green)),  
            ),  
          ],  
        ),  
      ),  
    );  
  }  
}  
