enum MessageSender { ai, user }

enum ConversationStep {
  analyzing,
  showingAnalysis,
  selectingStyle,
  showingSuggestions,
  askingOwnership,
  askingBudget,
  showingShopping,
  completed,
}

class ConversationMessage {
  final String id;
  final MessageSender sender;
  final String content;
  final DateTime timestamp;
  final List<String>? options; // For AI messages with selectable options
  final String? selectedOption;
  final bool isLoading;

  ConversationMessage({
    String? id,
    required this.sender,
    required this.content,
    DateTime? timestamp,
    this.options,
    this.selectedOption,
    this.isLoading = false,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       timestamp = timestamp ?? DateTime.now();

  ConversationMessage copyWith({
    String? content,
    List<String>? options,
    String? selectedOption,
    bool? isLoading,
  }) {
    return ConversationMessage(
      id: id,
      sender: sender,
      content: content ?? this.content,
      timestamp: timestamp,
      options: options ?? this.options,
      selectedOption: selectedOption ?? this.selectedOption,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class OutfitSuggestion {
  final String itemType;
  final String description;
  final String color;
  final String? shopUrl;
  final String? shopName;
  final double? price;

  OutfitSuggestion({
    required this.itemType,
    required this.description,
    required this.color,
    this.shopUrl,
    this.shopName,
    this.price,
  });

  factory OutfitSuggestion.fromJson(Map<String, dynamic> json) {
    return OutfitSuggestion(
      itemType: json['itemType'] ?? json['type'] ?? '',
      description: json['description'] ?? '',
      color: json['color'] ?? '',
      shopUrl: json['shopUrl'] ?? json['url'],
      shopName: json['shopName'] ?? json['shop'],
      price: json['price']?.toDouble(),
    );
  }

  String get typeEmoji {
    switch (itemType.toLowerCase()) {
      case 'top':
      case 'shirt':
      case 't-shirt':
        return '👕';
      case 'bottom':
      case 'pants':
      case 'jeans':
        return '👖';
      case 'shoes':
      case 'sneakers':
        return '👟';
      case 'jacket':
      case 'coat':
        return '🧥';
      case 'accessory':
      case 'watch':
      case 'belt':
        return '💎';
      case 'bag':
        return '👜';
      default:
        return '👔';
    }
  }
}
