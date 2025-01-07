import 'package:flutter/material.dart';
import 'package:vehicle_spare_parts/screens/customer_detail_screen.dart';

class CustomerScreen extends StatefulWidget {
  final int userId; // Kullanıcı ID'si buraya aktarılıyor
  const CustomerScreen({super.key, required this.userId});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Müşteri Ekranı")),
      body: ElevatedButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      CustomerDetailScreen(userId: widget.userId)));
        },
        child: const Text("Servis Detayı"),
      ),
    );
  }
}
