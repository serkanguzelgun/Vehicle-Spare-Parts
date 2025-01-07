class Customer {
  final String id;
  final String username;
  final String password;

  Customer({
    required this.id,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'password': password,
      };

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'].toString(),
        username: json['username'],
        password: json['password'] ?? '',
      );
}
