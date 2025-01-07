import 'package:flutter/material.dart';
import '../models/part.dart';
import '../services/api_service.dart';

class AdminPartsScreen extends StatefulWidget {
  const AdminPartsScreen({super.key});

  @override
  _AdminPartsScreenState createState() => _AdminPartsScreenState();
}

class _AdminPartsScreenState extends State<AdminPartsScreen> {
  final ApiService _apiService = ApiService();
  List<Part> _parts = [];

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  Part? _editingPart;

  @override
  void initState() {
    super.initState();
    _loadParts();
  }

  Future<void> _loadParts() async {
    try {
      final partsData = await _apiService.getParts();
      if (mounted) {
        setState(() {
          _parts = partsData.map((json) {
            String imageUrl = json['image_url'] ?? '';
            return Part.fromJson({
              ...json,
              'image_url': imageUrl,
            });
          }).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Veriler yüklenemedi: $e');
      }
    }
  }

  Future<void> _addOrUpdatePart() async {
    final name = _nameController.text;
    final description = _descriptionController.text;
    final price = double.tryParse(_priceController.text) ?? 0.0;
    final imageUrl = _imageUrlController.text;

    if (name.isNotEmpty && description.isNotEmpty && imageUrl.isNotEmpty) {
      try {
        if (_editingPart == null) {
          final response =
              await _apiService.addPart(name, description, price, imageUrl);
          if (response.containsKey('message') &&
              response['message'] == 'Parça kaydı başarılı!') {
            if (mounted) {
              setState(() {
                _parts.add(Part(
                  id: DateTime.now().toString(),
                  name: name,
                  description: description,
                  price: price,
                  image_url: imageUrl,
                ));
              });
            }
          } else {
            if (mounted) {
              _showErrorDialog('Parça eklenemedi: ${response['message']}');
            }
          }
        } else {
          final response = await _apiService.updatePart(
              int.tryParse(_editingPart!.id) ?? 0,
              name,
              description,
              price,
              imageUrl);
          if (response.containsKey('message') &&
              response['message'] == 'Parça bilgileri başarıyla güncellendi!') {
            if (mounted) {
              setState(() {
                _parts[_parts
                    .indexWhere((part) => part.id == _editingPart!.id)] = Part(
                  id: _editingPart!.id,
                  name: name,
                  description: description,
                  price: price,
                  image_url: imageUrl,
                );
                _editingPart = null;
              });
            }
          } else {
            if (mounted) {
              _showErrorDialog('Parça güncellenemedi: ${response['message']}');
            }
          }
        }
      } catch (e) {
        if (mounted) {
          _showErrorDialog('Bir hata oluştu: $e');
        }
      }
      _clearInputs();
    } else {
      if (mounted) {
        _showErrorDialog('Tüm alanları doldurduğunuzdan emin olun.');
      }
    }
  }

  Future<void> _removePart(String id) async {
    try {
      final response = await _apiService.deletePart(int.parse(id));
      if (response.containsKey('message') &&
          response['message'] == 'Parça başarıyla silindi!') {
        if (mounted) {
          setState(() {
            _parts.removeWhere((part) => part.id == id);
          });
        }
      } else {
        if (mounted) {
          _showErrorDialog('Parça silinemedi: ${response['message']}');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Bir hata oluştu: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hata'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('Tamam'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _clearInputs() {
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _imageUrlController.clear();
  }

  void _editPart(Part part) {
    _nameController.text = part.name;
    _descriptionController.text = part.description;
    _priceController.text = part.price.toString();
    _imageUrlController.text = part.image_url;
    setState(() {
      _editingPart = part;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yedek Parça Yönetimi'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _editingPart == null
                ? _buildAddPartFields()
                : _buildUpdatePartFields(),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _parts.length,
                itemBuilder: (context, index) {
                  final part = _parts[index];
                  final imageUrl = part.image_url;
                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: imageUrl.isNotEmpty &&
                              (imageUrl.startsWith('http://') ||
                                  imageUrl.startsWith('https://'))
                          ? Image.network(imageUrl,
                              width: 50, height: 50, fit: BoxFit.cover)
                          : const Icon(Icons.image, size: 50),
                      title: Text(
                        part.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Fiyat: ${part.price} TL\nAçıklama: ${part.description}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editPart(part),
                            color: Colors.blueAccent,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _removePart(part.id),
                            color: Colors.red,
                          ),
                        ],
                      ),
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

  Widget _buildAddPartFields() {
    return _buildPartForm('Parça Ekle', _addOrUpdatePart);
  }

  Widget _buildUpdatePartFields() {
    return _buildPartForm('Parça Güncelle', _addOrUpdatePart);
  }

  Widget _buildPartForm(String buttonText, Function onPressed) {
    return Column(
      children: [
        _buildTextField(_nameController, 'Parça Adı'),
        _buildTextField(_descriptionController, 'Açıklama'),
        _buildTextField(_priceController, 'Fiyat', isNumber: true),
        _buildTextField(_imageUrlController, 'Resim URL\'si'),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => onPressed(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(buttonText),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      ),
    );
  }
}
