import 'package:flutter/material.dart';  
  
class PaymentScreen extends StatelessWidget {  
  const PaymentScreen({super.key});  
  
  @override  
  Widget build(BuildContext context) {  
    return Scaffold(  
      appBar: AppBar(title: const Text('Pembayaran')),  
      body: Center(  
        child: Column(  
          mainAxisAlignment: MainAxisAlignment.center,  
          children: [  
            const Text('Silakan unggah bukti pembayaran'),  
            ElevatedButton(  
              onPressed: () {  
                // Implementasi untuk mengunggah bukti pembayaran  
              },  
              child: const Text('Unggah Bukti Pembayaran'),  
            ),  
          ],  
        ),  
      ),  
    );  
  }  
}  
