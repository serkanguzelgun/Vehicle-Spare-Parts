class Part {
  final String id;
  final String name;
  final String description;
  final double price;
  final String image_url;

  Part({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image_url,
  });

  factory Part.fromJson(Map<String, dynamic> json) {
    return Part(
      id: json['id'].toString(), // id'nin her zaman String olduğundan emin olun
      name: json['name'],
      description: json['description'],
      price: json['price'] is double
          ? json['price']
          : double.parse(json['price'].toString()),
      image_url: json['image_url'] ?? '', // imageUrl null olabilir
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image_url': image_url,
    };
  }
}
