import 'package:flutter/material.dart';    
import 'package:pdf/pdf.dart';    
import 'package:pdf/widgets.dart' as pw;    
import 'package:printing/printing.dart';    
    
class PaymentPage extends StatefulWidget {    
  final double totalPrice;    
  final double shippingCost;    
    
  const PaymentPage({Key? key, required this.totalPrice, required this.shippingCost}) : super(key: key);    
    
  @override    
  State<PaymentPage> createState() => _PaymentPageState();    
}    
    
class _PaymentPageState extends State<PaymentPage> {    
  final TextEditingController _amountController = TextEditingController();    
  double? _totalPayment;    
    
  @override    
  void initState() {    
    super.initState();    
    _totalPayment = widget.totalPrice + widget.shippingCost;    
  }    
    
  Future<void> _generatePdf() async {    
    final pdf = pw.Document();    
    
    pdf.addPage(    
      pw.Page(    
        build: (pw.Context context) {    
          return pw.Center(    
            child: pw.Column(    
              mainAxisAlignment: pw.MainAxisAlignment.center,    
              children: [    
                pw.Text('Nota Pembayaran', style: pw.TextStyle(fontSize: 24)),    
                pw.SizedBox(height: 20),    
                pw.Text('Total Harga: Rp ${widget.totalPrice}'),    
                pw.Text('Ongkir: Rp ${widget.shippingCost}'),    
                pw.Text('Total Pembayaran: Rp $_totalPayment'),    
              ],    
            ),    
          );    
        },    
      ),    
    );    
    
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());    
  }    
    
  @override    
  Widget build(BuildContext context) {    
    return Scaffold(    
      appBar: AppBar(title: const Text('Pembayaran')),    
      body: Padding(    
        padding: const EdgeInsets.all(16.0),    
        child: Column(    
          crossAxisAlignment: CrossAxisAlignment.start,    
          children: [    
            Text('Total Pembayaran: Rp $_totalPayment', style: const TextStyle(fontSize: 20)),    
            const SizedBox(height: 20),    
            TextField(    
              controller: _amountController,    
              keyboardType: TextInputType.number,    
              decoration: const InputDecoration(labelText: 'Masukkan Total Harga'),    
            ),    
            const SizedBox(height: 20),    
            ElevatedButton(    
              onPressed: () {    
                _generatePdf(); // Menghasilkan PDF    
              },    
              child: const Text('Bayar'),    
            ),    
          ],    
        ),    
      ),    
    );    
  }    
}  
