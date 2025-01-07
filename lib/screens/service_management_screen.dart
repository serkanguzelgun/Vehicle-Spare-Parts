import 'package:flutter/material.dart';
import 'package:vehicle_spare_parts/services/api_service.dart';
import 'package:intl/intl.dart';

class ServiceManagementScreen extends StatefulWidget {
  const ServiceManagementScreen({super.key});

  @override
  State<ServiceManagementScreen> createState() =>
      _ServiceManagementScreenState();
}

class _ServiceManagementScreenState extends State<ServiceManagementScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _services = [];
  List<Map<String, dynamic>> _users = [];

  final TextEditingController _vehiclePlateController = TextEditingController();
  final TextEditingController _serviceDateController = TextEditingController();

  int? _selectedUserId;

  @override
  void initState() {
    super.initState();
    _fetchServices();
    _fetchUsers();
  }

  Future<void> _fetchServices() async {
    final services = await _apiService.getServices();
    setState(() {
      _services = services;
    });
  }

  Future<void> _fetchUsers() async {
    final users = await _apiService.getUsers();
    setState(() {
      _users = users;
    });
  }

  Future<void> _addService() async {
    if (_selectedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen bir kullanıcı seçin")),
      );
      return;
    }

    final response = await _apiService.addService(
      _selectedUserId!,
      _vehiclePlateController.text,
      _serviceDateController.text,
    );

    if (response.containsKey('message')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'])),
      );
    }
    await _fetchServices();
  }

  Future<void> _updateService(int id) async {
    final response = await _apiService.updateService(
      id,
      _vehiclePlateController.text,
      _serviceDateController.text,
    );
    if (response.containsKey('message')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'])),
      );
    }
    await _fetchServices();
  }

  Future<void> _selectDate() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      _serviceDateController.text =
          DateFormat('yyyy-MM-dd').format(selectedDate);
    }
  }

  Future<void> _deleteService(int serviceId) async {
    final deletePartsResponse =
        await _apiService.deleteServicePartsByServiceId(serviceId);
    if (deletePartsResponse.containsKey('message')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(deletePartsResponse['message'])),
      );
    }

    final response = await _apiService.deleteService(serviceId);
    if (response.containsKey('message')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'])),
      );
    }

    await _fetchServices();
  }

  void _showServiceDialog({Map<String, dynamic>? service}) {
    if (service != null) {
      _vehiclePlateController.text = service['vehicle_plate'];
      _serviceDateController.text = service['service_date'];
      _selectedUserId = service['user_id'];
    } else {
      _vehiclePlateController.clear();
      _serviceDateController.clear();
      _selectedUserId = null;
    }

    final selectedUserName = service != null
        ? _users.firstWhere(
            (user) => user['id'] == service['user_id'],
            orElse: () => {'username': 'Bilinmiyor'},
          )['username']
        : 'Bilinmiyor';

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  service == null ? "Servis Ekle" : "Servis Güncelle",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 10),
                if (service == null)
                  DropdownButtonFormField<int>(
                    value: _selectedUserId,
                    items: _users
                        .where((user) => user['username'] != 'admin')
                        .map((user) => DropdownMenuItem<int>(
                              value: user['id'] as int,
                              child: Text(user['username']),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedUserId = value;
                      });
                    },
                    decoration:
                        const InputDecoration(labelText: "Kullanıcı Seç"),
                  ),
                if (service != null)
                  Text(
                    "Kullanıcı: $selectedUserName",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                TextField(
                  controller: _vehiclePlateController,
                  decoration: const InputDecoration(labelText: "Araç Plakası"),
                ),
                GestureDetector(
                  onTap: _selectDate,
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _serviceDateController,
                      decoration: const InputDecoration(
                          labelText: "Servis Tarihi (Tıkla)"),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("İptal"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (service == null && _selectedUserId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Lütfen bir kullanıcı seçin")),
                          );
                          return;
                        }

                        if (service == null) {
                          await _addService();
                        } else {
                          await _updateService(service['id']);
                        }
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Ana buton rengi
                        foregroundColor: Colors.white, // Yazı rengi
                      ),
                      child: Text(service == null ? "Ekle" : "Güncelle"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Servis Yönetimi"),
        backgroundColor: Colors.blue, // App bar rengi
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _services.length,
                itemBuilder: (context, index) {
                  final service = _services[index];
                  final user = _users.firstWhere(
                    (user) => user['id'] == service['user_id'],
                    orElse: () => {'username': 'Bilinmiyor'},
                  );

                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        '${service['vehicle_plate']} - ${user['username']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(service['service_date']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () =>
                                _showServiceDialog(service: service),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteService(service['id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () => _showServiceDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Ana buton rengi
                foregroundColor: Colors.white, // Yazı rengi
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              ),
              child: const Text(
                "Yeni Servis Ekle",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
