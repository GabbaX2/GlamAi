class OutfitItem {
  final String type;
  final String description;
  final String color;
  final String? imageUrl;

  OutfitItem({
    required this.type,
    required this.description,
    required this.color,
    this.imageUrl,
  });

  factory OutfitItem.fromJson(Map<String, dynamic> json) {
    return OutfitItem(
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      color: json['color'] ?? '',
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'description': description,
      'color': color,
      'imageUrl': imageUrl,
    };
  }

  String get typeEmoji {
    switch (type.toLowerCase()) {
      case 'top':
        return '👕';
      case 'bottom':
        return '👖';
      case 'shoes':
        return '👟';
      case 'accessory':
        return '💎';
      case 'bag':
        return '👜';
      case 'jacket':
      case 'outerwear':
        return '🧥';
      default:
        return '👔';
    }
  }
}

class Outfit {
  final String id;
  final String name;
  final String style;
  final String occasion;
  final List<OutfitItem> items;
  final String tips;
  final DateTime createdAt;

  Outfit({
    String? id,
    required this.name,
    required this.style,
    required this.occasion,
    required this.items,
    required this.tips,
    DateTime? createdAt,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt = createdAt ?? DateTime.now();

  factory Outfit.fromJson(Map<String, dynamic> json) {
    return Outfit(
      id: json['id'],
      name: json['name'] ?? 'Unnamed Outfit',
      style: json['style'] ?? 'casual',
      occasion: json['occasion'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OutfitItem.fromJson(item))
              .toList() ??
          [],
      tips: json['tips'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'style': style,
      'occasion': occasion,
      'items': items.map((item) => item.toJson()).toList(),
      'tips': tips,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get styleEmoji {
    switch (style.toLowerCase()) {
      case 'casual':
        return '😎';
      case 'elegant':
      case 'formal':
        return '✨';
      case 'sporty':
        return '🏃';
      case 'streetwear':
        return '🔥';
      case 'vintage':
        return '🕰️';
      case 'minimalist':
        return '⚪';
      default:
        return '👗';
    }
  }
}
