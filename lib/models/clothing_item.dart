class ClothingItem {
  final String id;
  final String type;
  final String category;
  final String primaryColor;
  final List<String> colors;
  final String pattern;
  final String material;
  final String style;
  final String season;
  final List<String> occasions;
  final String? brand;
  final String description;
  final String? imagePath;
  final DateTime createdAt;

  ClothingItem({
    required this.id,
    required this.type,
    required this.category,
    required this.primaryColor,
    required this.colors,
    required this.pattern,
    required this.material,
    required this.style,
    required this.season,
    required this.occasions,
    this.brand,
    required this.description,
    this.imagePath,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ClothingItem.fromJson(Map<String, dynamic> json, {String? imagePath}) {
    return ClothingItem(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: json['type'] ?? 'unknown',
      category: json['category'] ?? 'casual',
      primaryColor: json['color'] ?? 'unknown',
      colors: List<String>.from(json['colors'] ?? [json['color'] ?? 'unknown']),
      pattern: json['pattern'] ?? 'solid',
      material: json['material'] ?? 'unknown',
      style: json['style'] ?? 'modern',
      season: json['season'] ?? 'all-season',
      occasions: List<String>.from(json['occasion'] ?? ['casual']),
      brand: json['brand'],
      description: json['description'] ?? '',
      imagePath: imagePath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'category': category,
      'color': primaryColor,
      'colors': colors,
      'pattern': pattern,
      'material': material,
      'style': style,
      'season': season,
      'occasion': occasions,
      'brand': brand,
      'description': description,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get displayName {
    final brandPrefix = brand != null ? '$brand ' : '';
    return '$brandPrefix${_capitalize(primaryColor)} ${_capitalize(type)}';
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  // Icon based on type
  String get typeEmoji {
    switch (type.toLowerCase()) {
      case 'shirt':
      case 't-shirt':
      case 'top':
        return '👕';
      case 'pants':
      case 'jeans':
      case 'trousers':
        return '👖';
      case 'dress':
        return '👗';
      case 'jacket':
      case 'coat':
        return '🧥';
      case 'shoes':
      case 'sneakers':
        return '👟';
      case 'bag':
      case 'handbag':
        return '👜';
      case 'hat':
      case 'cap':
        return '🧢';
      case 'watch':
        return '⌚';
      case 'sunglasses':
        return '🕶️';
      default:
        return '👔';
    }
  }
}
