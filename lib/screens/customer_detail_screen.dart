import 'package:flutter/material.dart';
import 'package:vehicle_spare_parts/services/api_service.dart';

class CustomerDetailScreen extends StatefulWidget {
  final int userId;

  const CustomerDetailScreen({Key? key, required this.userId})
      : super(key: key);

  @override
  _CustomerDetailScreenState createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Map<String, dynamic>>> _servicePartsFuture;

  @override
  void initState() {
    super.initState();
    _servicePartsFuture = _fetchServicePartsDetails();
  }

  Future<List<Map<String, dynamic>>> _fetchServicePartsDetails() async {
    try {
      final serviceParts =
          await _apiService.getServicePartsCustomer(widget.userId);

      final List<Map<String, dynamic>> details = [];

      for (var servicePart in serviceParts) {
        details.add({
          'part_name': servicePart['part_name'] ?? 'Bilinmiyor',
          'part_description': servicePart['part_description'] ?? 'Bilinmiyor',
          'part_price': servicePart['part_price']?.toString() ?? 'Bilinmiyor',
          'image_url': servicePart['image_url'] ?? '',
          'service_id': servicePart['service_id'],
          'service_date': servicePart['service_date'] ?? 'Bilinmiyor',
          'vehicle_plate': servicePart['vehicle_plate'] ?? 'Bilinmiyor',
          'quantity': servicePart['quantity'] ?? 1,
          'part_id': servicePart['part_id'],
          'user_id': servicePart['user_id'],
        });
      }

      return details;
    } catch (e) {
      print("Veri alma hatası: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Servis Detayları'),
        backgroundColor: Colors.blue.shade400, // Mavi tonunda renk
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF66ccff), Color(0xFF0099cc)], // Mavi tonları
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
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
                child: Text(
                  'Henüz eklenmiş bir servis parçası yok.',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              );
            }

            final servicePartsDetails = snapshot.data!;
            Map<int, Map<String, dynamic>> groupedServices = {};

            for (var part in servicePartsDetails) {
              int serviceId = part['service_id'];
              String partId = part['part_id'].toString();

              if (!groupedServices.containsKey(serviceId)) {
                groupedServices[serviceId] = {
                  'service_details': part,
                  'parts': {},
                };
              }

              if (!groupedServices[serviceId]!['parts'].containsKey(partId)) {
                groupedServices[serviceId]!['parts'][partId] = {
                  'part_name': part['part_name'],
                  'part_description': part['part_description'],
                  'part_price': part['part_price'],
                  'image_url': part['image_url'],
                  'quantity': part['quantity'],
                };
              } else {
                groupedServices[serviceId]!['parts'][partId]['quantity']++;
              }
            }

            return ListView.builder(
              itemCount: groupedServices.length,
              itemBuilder: (context, index) {
                int serviceId = groupedServices.keys.elementAt(index);
                var service = groupedServices[serviceId];

                var serviceDetails = service!['service_details'];
                var parts = service['parts'];

                double totalPrice = 0.0;
                parts.values.forEach((part) {
                  double partPrice =
                      double.tryParse(part['part_price'].toString()) ?? 0.0;
                  totalPrice += partPrice * part['quantity'];
                });

                return Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white.withOpacity(0.9),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Servis Tarihi: ${serviceDetails['service_date']}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Araç Plakası: ${serviceDetails['vehicle_plate']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Divider(thickness: 1.2),
                        ...parts.values.map((part) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (part['image_url'] != '')
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      part['image_url'],
                                      height: 70,
                                      width: 70,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          height: 70,
                                          width: 70,
                                          color: Colors.grey[300],
                                          child: const Icon(
                                            Icons.broken_image,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        part['part_name'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        part['part_description'],
                                        style: const TextStyle(
                                            fontSize: 14, color: Colors.grey),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Fiyat: ${part['part_price']} TL',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      Text(
                                        'Adet: ${part['quantity']}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 16),
                        Text(
                          'Toplam Fiyat: ${totalPrice.toStringAsFixed(2)} TL',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
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
      ),
    );
  }
}
