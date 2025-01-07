import 'package:flutter/material.dart';
import 'package:vehicle_spare_parts/services/api_service.dart';
import 'update_service_part.dart';

class ServiceDetailsScreen extends StatefulWidget {
  const ServiceDetailsScreen({Key? key}) : super(key: key);

  @override
  _ServiceDetailsScreenState createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Map<String, dynamic>>> _servicePartsFuture;

  @override
  void initState() {
    super.initState();
    _servicePartsFuture = _fetchServicePartsDetails();
  }

  Future<List<Map<String, dynamic>>> _fetchServicePartsDetails() async {
    final serviceParts = await _apiService.getServiceParts(null);
    final List<Map<String, dynamic>> details = [];

    for (var servicePart in serviceParts) {
      final partDetails = await _apiService.getPartById(servicePart['part_id']);
      final serviceDetails =
          await _apiService.getServiceById(servicePart['service_id']);

      if (partDetails != null && serviceDetails != null) {
        details.add({
          'part_name': partDetails['name'] ?? 'Bilinmiyor',
          'part_description': partDetails['description'] ?? 'Bilinmiyor',
          'part_price': partDetails['price'] ?? 'Bilinmiyor',
          'image_url': partDetails['image_url'] ?? '',
          'service_id': servicePart['service_id'],
          'service_date': serviceDetails['service_date'] ?? 'Bilinmiyor',
          'vehicle_plate': serviceDetails['vehicle_plate'] ?? 'Bilinmiyor',
          'part_id': servicePart['part_id'],
          'quantity': _getValidQuantity(servicePart['quantity']),
        });
      }
    }
    return details;
  }

  int _getValidQuantity(dynamic quantity) {
    if (quantity == null) {
      return 1;
    } else if (quantity is int) {
      return quantity;
    } else {
      return int.tryParse(quantity.toString()) ?? 1;
    }
  }

  void _showAddServiceDialog() async {
    List<Map<String, dynamic>> services = await _apiService.getServices();
    Map<int, String> serviceMap = {
      for (var service in services) service['id']: service['vehicle_plate']
    };

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Servis Seçin'),
          content: DropdownButton<int>(
            hint: const Text('Bir servis seçin'),
            items: serviceMap.entries
                .map((entry) => DropdownMenuItem<int>(
                      value: entry.key,
                      child: Text(entry.value),
                    ))
                .toList(),
            onChanged: (serviceId) async {
              if (serviceId != null) {
                List<Map<String, dynamic>> parts = await _apiService.getParts();
                String selectedPart = '';
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Parça Seçin'),
                      content: DropdownButton<String>(
                        hint: const Text('Bir parça seçin'),
                        items: parts
                            .map((part) => DropdownMenuItem<String>(
                                  value: part['name'],
                                  child: Text(part['name']),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedPart = value!;
                          });
                        },
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () async {
                            if (selectedPart.isNotEmpty) {
                              var part = parts.firstWhere(
                                  (part) => part['name'] == selectedPart);
                              var response = await _apiService.addServicePart(
                                serviceId,
                                part['id'],
                                1,
                              );
                              if (response['message'] ==
                                  'Servis parçası eklenemedi!') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(response['message'])),
                                );
                              } else {
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                                setState(() {
                                  _servicePartsFuture =
                                      _fetchServicePartsDetails();
                                });
                              }
                            }
                          },
                          child: const Text('Ekle'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Vazgeç'),
                        ),
                      ],
                    );
                  },
                );
              }
            },
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(int serviceId, int partId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Silme İşlemi'),
          content: const Text(
              'Bu servis parçasını silmek istediğinize emin misiniz?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                var response =
                    await _apiService.deleteServicePart(serviceId, partId);
                if (response['message'] == 'Servis parçası silinemedi!') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(response['message'])),
                  );
                } else {
                  setState(() {
                    _servicePartsFuture = _fetchServicePartsDetails();
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Evet'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Hayır'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Servis Detayları'),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _servicePartsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Bir hata oluştu: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Henüz eklenmiş bir servis parçası yok.'),
            );
          }

          final servicePartsDetails = snapshot.data!;

          Map<int, List<Map<String, dynamic>>> groupedByService = {};
          for (var part in servicePartsDetails) {
            groupedByService
                .putIfAbsent(part['service_id'], () => [])
                .add(part);
          }

          return ListView.builder(
            itemCount: groupedByService.keys.length,
            itemBuilder: (context, index) {
              int serviceId = groupedByService.keys.elementAt(index);
              List<Map<String, dynamic>> serviceParts =
                  groupedByService[serviceId]!;

              double totalPrice = serviceParts.fold(0.0, (sum, part) {
                return sum +
                    (double.tryParse(part['part_price'].toString()) ?? 0.0) *
                        part['quantity'];
              });

              return Card(
                elevation: 8,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Servis Tarihi: ${serviceParts[0]['service_date']}',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent),
                      ),
                      Text(
                        'Araç Plakası: ${serviceParts[0]['vehicle_plate']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Divider(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: serviceParts.map((part) {
                          return Row(
                            children: [
                              if (part['image_url'] != '')
                                Image.network(
                                  part['image_url'],
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.broken_image,
                                        size: 50);
                                  },
                                ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Parça İsmi: ${part['part_name']}',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                        'Parça Açıklaması: ${part['part_description']}'),
                                    Text('Parça Fiyatı: ${part['part_price']}'),
                                    Text('Adet: ${part['quantity']}'),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () async {
                                  final updated = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UpdateServicePart(
                                        partId: part['part_id'],
                                        serviceId: part['service_id'],
                                        quantity: part['quantity'],
                                      ),
                                    ),
                                  );
                                  if (updated != null && updated) {
                                    setState(() {
                                      _servicePartsFuture =
                                          _fetchServicePartsDetails();
                                    });
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                color: Colors.red,
                                onPressed: () {
                                  _showDeleteConfirmationDialog(
                                      part['service_id'], part['part_id']);
                                },
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                      const Divider(),
                      Text(
                        'Toplam Fiyat: $totalPrice₺',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddServiceDialog,
        child: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
