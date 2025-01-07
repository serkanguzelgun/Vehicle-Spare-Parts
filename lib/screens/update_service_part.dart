import 'package:flutter/material.dart';
import 'package:vehicle_spare_parts/services/api_service.dart';

class UpdateServicePart extends StatefulWidget {
  final int partId;
  final int serviceId;
  final int quantity;

  const UpdateServicePart({
    Key? key,
    required this.partId,
    required this.serviceId,
    required this.quantity,
  }) : super(key: key);

  @override
  _UpdateServicePartState createState() => _UpdateServicePartState();
}

class _UpdateServicePartState extends State<UpdateServicePart> {
  final ApiService _apiService = ApiService();
  late int _newQuantity;
  final TextEditingController _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _newQuantity = widget.quantity;
    _quantityController.text = _newQuantity.toString();
  }

  void _updateQuantity() async {
    if (_newQuantity <= 0) {
      // Show error if quantity is less than or equal to zero
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adet 0’dan büyük olmalıdır!')),
      );
      return;
    }

    var response = await _apiService.updateServicePart(
        widget.serviceId, widget.partId, _newQuantity);

    if (response['message'] == 'Servis parçası başarıyla güncellendi!') {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Bir hata oluştu.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text('Adet Güncelle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lütfen yeni adet miktarını giriniz:',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Yeni Adet',
                  hintText: 'Adet giriniz',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  _newQuantity = int.tryParse(value) ?? _newQuantity;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _newQuantity > 0 ? _updateQuantity : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.green,
                ),
                child: const Text(
                  'Güncelle',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Vazgeç',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blueAccent,
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
