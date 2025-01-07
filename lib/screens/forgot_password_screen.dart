import 'package:flutter/material.dart';
import 'package:vehicle_spare_parts/services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _usernameController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false; // Yüklenme durumu için

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String username = _usernameController.text.trim();
    String newPassword = _newPasswordController.text;

    try {
      var response = await ApiService().resetPassword(username, newPassword);

      if (response == null || !response.containsKey('message')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Sunucudan geçerli bir yanıt alınamadı!")),
        );
        return;
      }

      String message = response['message'];
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

      if (message == 'Şifre başarıyla sıfırlandı!') {
        Navigator.pop(context); // Başarılıysa önceki ekrana dön
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Bir hata oluştu. Lütfen tekrar deneyin.")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Şifremi Unuttum"),
        backgroundColor: Colors.blue.shade800,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hoş geldiniz mesajı
              const Text(
                'Şifrenizi sıfırlamak için bilgilerinizi girin.',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Kullanıcı adı girişi
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: "Kullanıcı Adı",
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Kullanıcı adı boş olamaz!";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Yeni şifre girişi
              TextFormField(
                controller: _newPasswordController,
                decoration: const InputDecoration(
                  labelText: "Yeni Şifre",
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Yeni şifre boş olamaz!";
                  }
                  if (value.length < 4) {
                    return "Şifre en az 4 karakter olmalıdır!";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Yüklenme durumu veya buton
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _resetPassword,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 40.0),
                        backgroundColor: Colors.blue.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                      ),
                      child: const Text(
                        "Şifreyi Sıfırla",
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
}
