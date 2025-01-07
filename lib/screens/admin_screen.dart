import 'package:flutter/material.dart';
import 'package:vehicle_spare_parts/screens/admin_parts_screen.dart';
import 'package:vehicle_spare_parts/screens/customer_management_screen.dart';
import 'package:vehicle_spare_parts/screens/service_management_screen.dart';
import 'package:vehicle_spare_parts/screens/servis_details_screen.dart'; // Yeni import

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Ekranı"),
        backgroundColor: Colors.blue.shade800, // AppBar arka plan rengi
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(80.0), // Kenar boşluklarını azaltalım
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Text(
              'Admin Paneli',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
            const SizedBox(
                height: 100), // Başlık ve butonlar arasındaki boşluğu küçülttüm
            _buildElevatedButton(
              context,
              "Parça Yönetimi",
              const AdminPartsScreen(),
              Icons.build,
            ),
            _buildElevatedButton(
              context,
              "Kullanıcı Yönetimi",
              const CustomerManagementScreen(),
              Icons.person,
            ),
            _buildElevatedButton(
              context,
              "Servis Yönetimi",
              const ServiceManagementScreen(),
              Icons.car_repair,
            ),
            _buildElevatedButton(
              context,
              "Servis Detayları",
              const ServiceDetailsScreen(),
              Icons.details,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElevatedButton(
      BuildContext context, String label, Widget page, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade700,
          padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 30.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // Hafif oval köşeler
          ),
          elevation: 8, // Buton gölgesi
          shadowColor: Colors.blue.shade900,
        ),
        icon: Icon(icon, size: 24, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
