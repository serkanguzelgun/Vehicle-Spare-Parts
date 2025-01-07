import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5000'; // Flask API'nin URL'si

  // Kullanıcı kaydı
  Future<Map<String, dynamic>> register(
      String username, String password) async {
    final url = Uri.parse('$baseUrl/register');
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'username': username,
          'password': password,
        }));

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      return {'message': 'Kayıt başarısız!'};
    }
  }

  // Kullanıcı girişi
  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);

      if (responseData.containsKey('message') &&
          responseData['message'] == 'Giriş başarılı!') {
        return {
          'message': responseData['message'],
          'id': responseData['id'],
          'username': responseData['username'],
        };
      } else {
        print("API Yanıtı: $responseData");
        return {'message': responseData['message'] ?? 'Giriş başarısız!'};
      }
    } else {
      return {'message': 'Sunucu hatası! Lütfen tekrar deneyin.'};
    }
  }

  // Kullanıcıları listele
  Future<List<Map<String, dynamic>>> getUsers() async {
    final url = Uri.parse('$baseUrl/users');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List users = json.decode(response.body)['users'];
      return users.map((user) => user as Map<String, dynamic>).toList();
    } else {
      return [];
    }
  }

  // Kullanıcı sil (DELETE /users/<id>)
  Future<Map<String, dynamic>> deleteUser(int id) async {
    final url = Uri.parse('$baseUrl/users/$id');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return {'message': 'Kullanıcı silme başarısız!'};
    }
  }

  // Kullanıcı güncelle (PUT /users/<id>)
  Future<Map<String, dynamic>> updateUser(
      int id, String? username, String? password) async {
    final url = Uri.parse('$baseUrl/users/$id');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return {'message': 'Kullanıcı güncelleme başarısız!'};
    }
  }

  // Servisleri listele (GET /services)
  Future<List<Map<String, dynamic>>> getServices() async {
    final url = Uri.parse('$baseUrl/services');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List services = json.decode(response.body)['services'];
      return services
          .map((service) => service as Map<String, dynamic>)
          .toList();
    } else {
      return [];
    }
  }

  // Servis ekle (POST /services)
  Future<Map<String, dynamic>> addService(
      int userId, String vehiclePlate, String serviceDate) async {
    final url = Uri.parse('$baseUrl/services');
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_id': userId,
          'vehicle_plate': vehiclePlate,
          'service_date': serviceDate,
        }));

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      return {'message': 'Servis kaydı başarısız!'};
    }
  }

// Servis güncelle (PUT /services/<id>)
  Future<Map<String, dynamic>> updateService(
      int id, String vehiclePlate, String serviceDate) async {
    final url = Uri.parse('$baseUrl/services/$id');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'vehicle_plate': vehiclePlate,
        'service_date': serviceDate,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return {'message': 'Servis güncelleme başarısız! Hata: ${response.body}'};
    }
  }

  // Servis sil (DELETE /services/<id>)
  Future<Map<String, dynamic>> deleteService(int id) async {
    final url = Uri.parse('$baseUrl/services/$id');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return {'message': 'Servis silme başarısız!'};
    }
  }

  // Parçaları listele (GET /parts)
  Future<List<Map<String, dynamic>>> getParts() async {
    final url = Uri.parse('$baseUrl/parts');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List parts = json.decode(response.body)['parts'];
      return parts.map((part) => part as Map<String, dynamic>).toList();
    } else {
      return [];
    }
  }

  // Parça ekle (POST /parts)
  Future<Map<String, dynamic>> addPart(
      String name, String description, double price, String imageUrl) async {
    final url = Uri.parse('$baseUrl/parts');
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': name,
          'description': description,
          'price': price,
          'image_url': imageUrl,
        }));

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      return {'message': 'Parça kaydı başarısız!'};
    }
  }

  // Parça güncelle (PUT /parts/<id>)
  Future<Map<String, dynamic>> updatePart(int id, String name,
      String description, double price, String imageUrl) async {
    final url = Uri.parse('$baseUrl/parts/$id');
    final response = await http.put(url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': name,
          'description': description,
          'price': price,
          'image_url': imageUrl,
        }));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return {'message': 'Parça güncelleme başarısız!'};
    }
  }

  // Parça sil (DELETE /parts/<id>)
  Future<Map<String, dynamic>> deletePart(int id) async {
    final url = Uri.parse('$baseUrl/parts/$id');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return {'message': 'Parça silme başarısız!'};
    }
  }

  // Servis parçalarını listele (GET /service_parts)
  Future<List<Map<String, dynamic>>> getServiceParts(service) async {
    final url = Uri.parse('$baseUrl/service_parts');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List serviceParts = json.decode(response.body)['service_parts'];
      return serviceParts
          .map((servicePart) => servicePart as Map<String, dynamic>)
          .toList();
    } else {
      return [];
    }
  }

  // Servis parçası ekle (POST /service_parts)
  Future<Map<String, dynamic>> addServicePart(
      int serviceId, int partId, int quantity) async {
    final url = Uri.parse('$baseUrl/service_parts');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'service_id': serviceId,
        'part_id': partId,
        'quantity': quantity,
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      return {'message': 'Servis parçası eklenemedi!'};
    }
  }

  // Servis parçası güncelle (PUT /service_parts/<id>)
  Future<Map<String, dynamic>> updateServicePartQuantity(
      int id, int quantity) async {
    final url = Uri.parse('$baseUrl/service_parts/$id');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'quantity': quantity,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return {'message': 'Güncelleme hatası'};
    }
  }

  // Servis parçası sil (DELETE /service_parts/<service_id>/<part_id>)
  Future<Map<String, dynamic>> deleteServicePart(
      int serviceId, int partId) async {
    final url = Uri.parse('$baseUrl/service_parts/$serviceId/$partId');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return {'message': 'Servis parçası silinemedi!'};
    }
  }

  getServiceDetails(int serviceId) {}

  Future<Map<String, dynamic>?> resetPassword(
      String username, String newPassword) async {
    final url = Uri.parse('$baseUrl/reset-password');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'new_password': newPassword, // Backend ile eşleşen alan
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print("Hata Kodu: ${response.statusCode}, Body: ${response.body}");
        return json.decode(response.body);
      }
    } catch (e) {
      print("Hata: $e");
      return {"message": "Bir hata oluştu. Lütfen tekrar deneyin."};
    }
  }

  // Servisi ID ile getir (GET /services/<id>)
  Future<Map<String, dynamic>?> getServiceById(int id) async {
    final url = Uri.parse('$baseUrl/services/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      return {'message': 'Servis bulunamadı!'};
    } else {
      return {'message': 'Sunucu hatası! Lütfen tekrar deneyin.'};
    }
  }

// Parçayı ID ile getir (GET /parts/<id>)
  Future<Map<String, dynamic>?> getPartById(int id) async {
    final url = Uri.parse('$baseUrl/parts/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      return {'message': 'Parça bulunamadı!'};
    } else {
      return {'message': 'Sunucu hatası! Lütfen tekrar deneyin.'};
    }
  }

  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final url = Uri.parse(
        '$baseUrl/users/username=$username'); // Kullanıcı adını sorgulamak için URL
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['user'] != null) {
        return data['user']
            as Map<String, dynamic>; // Kullanıcı bilgilerini döndür
      }
    }
    return null; // Kullanıcı bulunamazsa null döndür
  }

  Future<Map<String, dynamic>> updateServicePart(
      int serviceId, int partId, int quantity) async {
    final url = Uri.parse('$baseUrl/service_parts');
    final body = json.encode({
      'service_id': serviceId,
      'part_id': partId,
      'quantity': quantity,
    });

    try {
      // PUT isteği gönder
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      // İstek ve yanıt loglama
      debugPrint('PUT URL: $url');
      debugPrint('Request Body: $body');
      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Başarılı güncelleme
        return json.decode(response.body);
      } else if (response.statusCode == 400 || response.statusCode == 404) {
        // İstemci hatası durumları
        final responseData = json.decode(response.body);
        return {
          'message':
              responseData['message'] ?? 'İstemci hatası: Bilinmeyen hata',
        };
      } else {
        // Sunucu hatası veya beklenmeyen durum
        return {
          'message': 'Beklenmeyen bir hata oluştu. Kod: ${response.statusCode}',
        };
      }
    } catch (e) {
      // Ağ hatası veya sunucuya erişim sorunu
      debugPrint('Hata oluştu: $e');
      return {'message': 'Sunucuya ulaşılamadı veya bağlantı hatası oluştu.'};
    }
  }

  Future<List<Map<String, dynamic>>> getServicePartsCustomer(
      int? userId) async {
    final url = Uri.parse('$baseUrl/service-parts/$userId'); // API URL

    try {
      // Servis parçalarını alıyoruz
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Servis Parçaları: $data");

        // Eğer 'data' boşsa, geri dönüyoruz
        if (data['data'] == null || data['data'].isEmpty) {
          print("Servis parçaları boş.");
          return [];
        }

        // Servis parçalarını döndür
        List serviceParts = data['data'];
        List<Map<String, dynamic>> details = [];

        for (var servicePart in serviceParts) {
          details.add({
            'part_name': servicePart['part_name'] ?? 'Bilinmiyor',
            'part_description': servicePart['part_description'] ?? 'Bilinmiyor',
            'part_price': servicePart['part_price'] ?? 'Bilinmiyor',
            'image_url': servicePart['image_url'] ?? '', // Parça resmi URL'si
            'service_id': servicePart['service_id'],
            'service_date': servicePart['service_date'] ?? 'Bilinmiyor',
            'vehicle_plate': servicePart['vehicle_plate'] ?? 'Bilinmiyor',
            'part_id': servicePart['part_id'],
            'quantity': servicePart['quantity'] ?? 1, // Quantity eklendi
            'user_id': userId, // Kullanıcı ID'si
          });
        }

        return details;
      } else if (response.statusCode == 404) {
        final errorData = json.decode(response.body);
        print("Hata: ${errorData['message']}");
        throw Exception(errorData['message']);
      } else {
        print("API Hatası: ${response.statusCode}");
        throw Exception('Servis parçaları alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      print("API Hatası: $e");
      throw Exception('Servis parçaları alınamadı: $e');
    }
  }

  // Kullanıcıyı ID ile almak için fonksiyon
  Future<Map<String, dynamic>> getUserById(int userId) async {
    final url = Uri.parse(
        '$baseUrl/users/$userId'); // Kullanıcı ID'sine göre URL oluşturuluyor
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Gelen JSON verisini alıyoruz ve map'e çeviriyoruz
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      // Eğer kullanıcı bulunamazsa, hata mesajını döndürüyoruz
      return {'message': 'Kullanıcı bulunamadı'};
    } else {
      // Diğer hatalarda, genel bir hata mesajı döndürüyoruz
      throw Exception('Kullanıcı verisi alınamadı!');
    }
  }

  // Servis parçalarını service_id ile sil (DELETE /service-parts/delete/<service_id>)
  Future<Map<String, dynamic>> deleteServicePartsByServiceId(
      int serviceId) async {
    final url = Uri.parse('$baseUrl/service-parts/delete/$serviceId');
    try {
      final response = await http.delete(url, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        return json.decode(response.body); // Başarılı yanıtı döndür
      } else if (response.statusCode == 404) {
        // Servis parçaları bulunamadı
        final errorData = json.decode(response.body);
        return {
          'message': errorData['message'] ?? 'Servis parçaları bulunamadı!'
        };
      } else {
        // Diğer hata durumları
        return {
          'message': 'Servis parçaları silme başarısız! Hata: ${response.body}'
        };
      }
    } catch (e) {
      debugPrint('Hata: $e');
      return {'message': 'Servis parçaları silinirken bir hata oluştu: $e'};
    }
  }

  // Kullanıcıya ait servisleri getir
  Future<List<Map<String, dynamic>>> getServicesByUserId(int userId) async {
    final url = Uri.parse('$baseUrl/services/user/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List services = json.decode(response.body)['services'];
      return services
          .map((service) => service as Map<String, dynamic>)
          .toList();
    } else {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getServicePartsByServiceId(
      int serviceId) async {
    final url = Uri.parse('$baseUrl/service_parts/$serviceId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List serviceParts = json.decode(response.body)['service_parts'];
      return serviceParts
          .map((servicePart) => servicePart as Map<String, dynamic>)
          .toList();
    } else {
      throw Exception('Servis parçaları alınamadı!');
    }
  }
}
