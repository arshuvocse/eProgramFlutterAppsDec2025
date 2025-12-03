class ProviderModel {
  final int? id;
  final String name;
  final String code;
  final String category; // Blue Star, Green Star, Silver
  final String type; // Retailer, Wholesaler
  final String phone;

  const ProviderModel({
    this.id,
    required this.name,
    required this.code,
    required this.category,
    required this.type,
    required this.phone,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'code': code,
        'category': category,
        'type': type,
        'phone': phone,
      };

  factory ProviderModel.fromMap(Map<String, dynamic> m) => ProviderModel(
        id: m['id'] as int?,
        name: (m['name'] ?? '') as String,
        code: (m['code'] ?? '') as String,
        category: (m['category'] ?? '') as String,
        type: (m['type'] ?? '') as String,
        phone: (m['phone'] ?? '') as String,
      );
}
