import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uas_ppb/screens/admin_panel_page.dart';
import 'package:uas_ppb/utils/product_provider.dart';  
import 'screens/login_screen.dart';  
import 'screens/dashboard_screen.dart';  
import 'screens/register_screen.dart';  
import 'screens/cart_screen.dart';  
import 'screens/payment_screen.dart';  
import 'screens/history_screen.dart';  
import 'screens/admin_product_screen.dart';  
import 'screens/splash_screen.dart';


class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(  
    ChangeNotifierProvider(  
      create: (context) => ProductProvider(),  
      child: const MyApp(),  
    ),  
  );  
}  
  
class MyApp extends StatelessWidget {  
  const MyApp({super.key});  
  
  @override  
  Widget build(BuildContext context) {  
    return MaterialApp(  
      debugShowCheckedModeBanner: false,  
      title: 'UMKM Warung Ajib',  
      theme: ThemeData(  
        primarySwatch: Colors.blue,  
      ),  
      initialRoute: '/',  
      routes: {  
        '/': (context) => const SplashScreen(),  
        '/register': (context) => const RegisterScreen(),  
        '/login': (context) => const LoginScreen(),  
        '/dashboard': (context) => const DashboardScreen(),  
        '/cart': (context) => const CartScreen(),  
        '/payment': (context) => const PaymentScreen(),  
        '/history': (context) => const HistoryScreen(),  
        '/adminProducts': (context) => const AdminProductScreen(),  
        '/adminPanel': (context) => AdminPanelPage(),
      },
    );  
  }  
}  
