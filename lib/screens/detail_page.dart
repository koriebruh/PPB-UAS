import 'dart:convert';      
import 'package:flutter/material.dart';      
import 'package:http/http.dart' as http;      
import 'payment_page.dart'; // Ensure you have the payment page imported    
    
class DetailPage extends StatefulWidget {      
  final String? kota_asal;      
  final String? kota_tujuan;      
  final String? berat;      
  final String? kurir;      
  final int userId; // Add userId to the constructor    
      
  const DetailPage({super.key, this.kota_asal, this.kota_tujuan, this.berat, this.kurir, required this.userId});      
      
  @override      
  State<DetailPage> createState() => _DetailPageState();      
}      
      
class _DetailPageState extends State<DetailPage> {      
  List listData = [];      
  var strKey = "e5effe93f8bdd6e8e8f09d1d4a1a42c6";      
      
  final List<Map<String, dynamic>> staticData = [      
    {      
      "service": "JNE Reguler",      
      "description": "Pengiriman Reguler",      
      "cost": [{"value": 10000, "etd": "3-5"}],      
    },      
    {      
      "service": "JNE Express",      
      "description": "Pengiriman Ekspres",      
      "cost": [{"value": 20000, "etd": "1-2"}],      
    },      
  ];      
      
  @override      
  void initState() {      
    super.initState();      
    getData();      
  }      
      
  Future<void> getData() async {      
    try {      
      final response = await http.post(      
        Uri.parse("https://api.rajaongkir.com/starter/cost"),      
        body: {      
          "key": strKey,      
          "origin": widget.kota_asal,      
          "destination": widget.kota_tujuan,      
          "weight": widget.berat,      
          "courier": widget.kurir      
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
      print(e);      
      setState(() {      
        listData = staticData;      
      });      
    }      
  }      
      
  @override      
  Widget build(BuildContext context) {      
    return Scaffold(      
      appBar: AppBar(      
        title: Text("Detail Ongkos Kirim ${widget.kurir.toString().toUpperCase()}"),      
      ),      
      body: SingleChildScrollView(      
        child: ListView.builder(      
          itemCount: listData.length,      
          shrinkWrap: true,      
          physics: NeverScrollableScrollPhysics(),      
          itemBuilder: (_, index) {      
            return Card(      
              margin: const EdgeInsets.all(10),      
              clipBehavior: Clip.antiAlias,      
              elevation: 5,      
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),      
              color: Colors.white,      
              child: ListTile(      
                title: Text("${listData[index]['service']}"),      
                subtitle: Text("${listData[index]['description']}"),      
                trailing: Column(      
                  crossAxisAlignment: CrossAxisAlignment.end,      
                  children: [      
                    const SizedBox(height: 5),      
                    Text(      
                      "Rp ${listData[index]['cost'][0]['value']}",      
                      style: const TextStyle(fontSize: 20, color: Colors.red),      
                    ),      
                    const SizedBox(height: 3),      
                    Text("${listData[index]['cost'][0]['etd']} Days"),      
                    const SizedBox(height: 5),      
                    ElevatedButton(      
                      onPressed: () {      
                        double totalShippingCost = double.parse(listData[index]['cost'][0]['value'].toString());      
                        double? totalPrice = double.tryParse(widget.berat ?? '0');      
      
                        if (totalPrice == null) {      
                          ScaffoldMessenger.of(context).showSnackBar(      
                            const SnackBar(content: Text('Berat tidak valid')),      
                          );      
                          return;      
                        }      
      
                        double totalPayment = totalPrice + totalShippingCost;      
      
                        Navigator.push(      
                          context,      
                          MaterialPageRoute(      
                            builder: (context) => PaymentPage(      
                              totalPrice: totalPayment,      
                              shippingCost: totalShippingCost,      
                            ),      
                          ),      
                        );      
                      },      
                      child: const Text('Bayar'),      
                    ),      
                  ],      
                ),      
              ),      
            );      
          },      
        ),      
      ),      
    );      
  }      
}    
