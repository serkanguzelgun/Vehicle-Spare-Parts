import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPrefsService {
  static const _partsKey = 'parts';
  static const _customersKey = 'customers';
  static const _userIdKey = 'user_id'; // Kullanıcı ID'si için anahtar

  Future<void> saveParts(List<Map<String, dynamic>> parts) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_partsKey, jsonEncode(parts));
  }

  Future<List<Map<String, dynamic>>> loadParts() async {
    final prefs = await SharedPreferences.getInstance();
    final partsJson = prefs.getString(_partsKey);
    if (partsJson != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(partsJson));
    }
    return [];
  }

  Future<void> saveCustomers(List<Map<String, dynamic>> customers) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_customersKey, jsonEncode(customers));
  }

  Future<List<Map<String, dynamic>>> loadCustomers() async {
    final prefs = await SharedPreferences.getInstance();
    final customersJson = prefs.getString(_customersKey);
    if (customersJson != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(customersJson));
    }
    return [];
  }

  // Kullanıcı ID'sini kaydetme
  Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_userIdKey, userId);
  }

  // Kullanıcı ID'sini yükleme
  Future<int?> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey); // Kullanıcı ID'si alınıyor
  }
}
