import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../services/api_service.dart';
import 'customer_detail_screen.dart';

class CustomerManagementScreen extends StatefulWidget {
  const CustomerManagementScreen({super.key});

  @override
  _CustomerManagementScreenState createState() =>
      _CustomerManagementScreenState();
}

class _CustomerManagementScreenState extends State<CustomerManagementScreen> {
  final ApiService _apiService = ApiService();
  List<Customer> _customers = [];

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    try {
      final usersData = await _apiService.getUsers();
      setState(() {
        _customers = usersData.map((json) => Customer.fromJson(json)).toList();
      });
    } catch (e) {
      _showErrorDialog('Müşteriler yüklenemedi: $e');
    }
  }

  Future<void> _addCustomer() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isNotEmpty && password.isNotEmpty) {
      try {
        final response = await _apiService.register(username, password);
        if (response.containsKey('message') &&
            response['message'] == 'Kayıt başarılı!') {
          _loadCustomers();
          _clearInputs();
        } else {
          _showErrorDialog(response['message']);
        }
      } catch (e) {
        _showErrorDialog('Müşteri ekleme hatası: $e');
      }
    }
  }

  Future<void> _removeCustomer(String id) async {
    try {
      // Kullanıcıyı sil
      final response = await _apiService.deleteUser(int.parse(id));
      if (response.containsKey('message') &&
          response['message'] == 'Kullanıcı başarıyla silindi!') {
        setState(() {
          _customers.removeWhere((customer) => customer.id == id);
        });
      } else {
        _showErrorDialog(response['message']);
      }
    } catch (e) {
      _showErrorDialog('Müşteri silme hatası: $e');
    }
  }

  Future<void> _updateCustomer(
      String id, String username, String password) async {
    try {
      final response =
          await _apiService.updateUser(int.parse(id), username, password);
      if (response.containsKey('message') &&
          response['message'] == 'Kullanıcı bilgileri başarıyla güncellendi!') {
        _loadCustomers();
      } else {
        _showErrorDialog(response['message']);
      }
    } catch (e) {
      _showErrorDialog('Müşteri güncelleme hatası: $e');
    }
  }

  void _clearInputs() {
    _usernameController.clear();
    _passwordController.clear();
  }

  void _showUpdateDialog(Customer customer) {
    final updateUsernameController =
        TextEditingController(text: customer.username);
    final updatePasswordController =
        TextEditingController(text: customer.password);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Müşteri Güncelle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: updateUsernameController,
              decoration:
                  const InputDecoration(labelText: 'Yeni Kullanıcı Adı'),
            ),
            TextField(
              controller: updatePasswordController,
              decoration: const InputDecoration(labelText: 'Yeni Şifre'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedUsername = updateUsernameController.text;
              final updatedPassword = updatePasswordController.text;

              if (updatedUsername.isNotEmpty && updatedPassword.isNotEmpty) {
                _updateCustomer(
                  customer.id.toString(),
                  updatedUsername,
                  updatedPassword,
                );
                Navigator.of(context).pop();
              } else {
                _showErrorDialog('Kullanıcı adı ve şifre boş olamaz!');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent, // New modern button color
            ),
            child: const Text('Güncelle'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hata'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Müşteri Yönetimi'),
        backgroundColor: Colors.blueAccent, // Modern app bar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Text fields with modern style
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Kullanıcı Adı',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Şifre',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addCustomer,
              child: const Text('Müşteri Ekle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, // Modern button color
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _customers.length,
                itemBuilder: (context, index) {
                  final customer = _customers[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      title: Text(customer.username),
                      subtitle: const Text('Şifre: ****'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _showUpdateDialog(customer);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () =>
                                _removeCustomer(customer.id.toString()),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CustomerDetailScreen(
                              userId: int.parse(customer.id),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
