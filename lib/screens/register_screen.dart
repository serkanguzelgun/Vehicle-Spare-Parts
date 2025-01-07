import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vehicle_spare_parts/services/api_service.dart';
import 'package:vehicle_spare_parts/screens/login_screen.dart'; // LoginScreen'i ekliyoruz

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _register() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(msg: "Kullanıcı adı ve şifre gerekli!");
      return;
    }

    try {
      var response = await ApiService().register(username, password);
      if (response.containsKey('message')) {
        if (response['message'] == 'Kayıt başarılı!') {
          Fluttertoast.showToast(msg: response['message']);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        } else {
          Fluttertoast.showToast(msg: response['message']);
        }
      } else {
        Fluttertoast.showToast(msg: "Beklenmeyen bir hata oluştu!");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Bir hata oluştu: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kayıt Ol"),
        backgroundColor: Colors.blue.shade800,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Image.asset(
                  'assets/images/logo.png', // Logonun yolu
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
              // Hoşgeldiniz mesajı
              const Text(
                'Servisimize Hoşgeldiniz :)',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 40), // Başlık ile form arasındaki boşluk

              // Kullanıcı Adı TextField
              _buildTextField(
                controller: _usernameController,
                label: "Kullanıcı Adı",
                icon: Icons.person,
              ),
              const SizedBox(height: 20), // Alanlar arasında boşluk

              // Şifre TextField
              _buildTextField(
                controller: _passwordController,
                label: "Şifre",
                icon: Icons.lock,
                obscureText: true,
              ),
              const SizedBox(height: 30), // Alanlar arasında boşluk

              // Kayıt Ol Butonu
              ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 40.0),
                  backgroundColor: Colors.blue.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(30), // Yuvarlatılmış köşeler
                  ),
                  elevation: 8,
                ),
                child: const Text(
                  "Kayıt Ol",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blue.shade700),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.blue),
        filled: true,
        fillColor: Colors.blue.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
    );
  }
}
