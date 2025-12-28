import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/conversation_message.dart';
import '../services/gemini_service.dart';

class ConversationProvider extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService.instance;

  ConversationStep _currentStep = ConversationStep.analyzing;
  List<ConversationMessage> _messages = [];
  String? _imagePath;
  Uint8List? _imageBytes;

  // Analysis results
  String? _garmentType;
  String? _garmentColor;
  String? _garmentDescription;

  // User choices
  String? _selectedStyle;
  List<OutfitSuggestion> _suggestions = [];
  List<bool> _ownedItems = [];
  double? _budget;
  List<OutfitSuggestion> _shoppingItems = [];

  // Getters
  ConversationStep get currentStep => _currentStep;
  List<ConversationMessage> get messages => _messages;
  String? get imagePath => _imagePath;
  Uint8List? get imageBytes => _imageBytes;
  String? get garmentType => _garmentType;
  String? get garmentColor => _garmentColor;
  String? get selectedStyle => _selectedStyle;
  List<OutfitSuggestion> get suggestions => _suggestions;
  List<bool> get ownedItems => _ownedItems;
  double? get budget => _budget;
  List<OutfitSuggestion> get shoppingItems => _shoppingItems;
  bool get isLoading => _messages.isNotEmpty && _messages.last.isLoading;

  void reset() {
    _currentStep = ConversationStep.analyzing;
    _messages = [];
    _imagePath = null;
    _imageBytes = null;
    _garmentType = null;
    _garmentColor = null;
    _garmentDescription = null;
    _selectedStyle = null;
    _suggestions = [];
    _ownedItems = [];
    _budget = null;
    _shoppingItems = [];
    notifyListeners();
  }

  Future<void> startConversation(
    Uint8List imageBytes, {
    String? imagePath,
  }) async {
    reset();
    _imageBytes = imageBytes;
    _imagePath = imagePath;
    _currentStep = ConversationStep.analyzing;

    // Add loading message
    _addMessage(
      sender: MessageSender.ai,
      content: 'Analizzo il tuo capo... ✨',
      isLoading: true,
    );
    notifyListeners();

    try {
      final result = await _geminiService.analyzeGarmentSimple(imageBytes);

      if (result != null) {
        _garmentType = result['type'];
        _garmentColor = result['color'];
        _garmentDescription = result['description'];

        // Update message with result
        _updateLastMessage(
          content:
              'Ho analizzato il tuo capo! 👀\n\n'
              '**Tipo:** ${_garmentType ?? "Non identificato"}\n'
              '**Colore:** ${_garmentColor ?? "Non identificato"}\n\n'
              '${_garmentDescription ?? ""}\n\n'
              'Che stile vuoi creare con questo capo?',
          isLoading: false,
          options: [
            'Casual',
            'Elegante',
            'Sportivo',
            'Streetwear',
            'Minimal',
            'Vintage',
          ],
        );
        _currentStep = ConversationStep.selectingStyle;
      } else {
        _updateLastMessage(
          content:
              'Non sono riuscito ad analizzare il capo. Riprova con un\'altra foto.',
          isLoading: false,
        );
      }
    } catch (e) {
      _updateLastMessage(content: 'Errore: ${e.toString()}', isLoading: false);
    }

    notifyListeners();
  }

  Future<void> selectStyle(String style) async {
    _selectedStyle = style;

    // Add user selection message
    _addMessage(sender: MessageSender.user, content: style);

    // Add loading message
    _addMessage(
      sender: MessageSender.ai,
      content: 'Cerco abbinamenti $style... 🔍',
      isLoading: true,
    );
    _currentStep = ConversationStep.showingSuggestions;
    notifyListeners();

    try {
      final suggestions = await _geminiService.getOutfitSuggestions(
        garmentType: _garmentType ?? '',
        garmentColor: _garmentColor ?? '',
        style: style,
        imageBytes: _imageBytes,
      );

      _suggestions = suggestions;
      _ownedItems = List.filled(suggestions.length, false);

      if (suggestions.isNotEmpty) {
        final suggestionsText = suggestions
            .asMap()
            .entries
            .map((e) {
              final idx = e.key + 1;
              final s = e.value;
              return '$idx. ${s.typeEmoji} **${s.itemType}** - ${s.description} (${s.color})';
            })
            .join('\n');

        _updateLastMessage(
          content:
              'Ecco cosa abbinerei al tuo ${_garmentType ?? "capo"} per un look $style:\n\n$suggestionsText\n\n'
              'Possiedi già qualcuno di questi capi?',
          isLoading: false,
        );
        _currentStep = ConversationStep.askingOwnership;
      } else {
        _updateLastMessage(
          content: 'Non sono riuscito a trovare abbinamenti. Riprova.',
          isLoading: false,
        );
      }
    } catch (e) {
      _updateLastMessage(content: 'Errore: ${e.toString()}', isLoading: false);
    }

    notifyListeners();
  }

  void toggleOwnedItem(int index) {
    if (index >= 0 && index < _ownedItems.length) {
      _ownedItems[index] = !_ownedItems[index];
      notifyListeners();
    }
  }

  Future<void> confirmOwnedItems() async {
    final owned = <String>[];
    final notOwned = <OutfitSuggestion>[];

    for (int i = 0; i < _suggestions.length; i++) {
      if (_ownedItems[i]) {
        owned.add(_suggestions[i].itemType);
      } else {
        notOwned.add(_suggestions[i]);
      }
    }

    if (owned.isNotEmpty) {
      _addMessage(
        sender: MessageSender.user,
        content: 'Possiedo: ${owned.join(", ")}',
      );
    } else {
      _addMessage(
        sender: MessageSender.user,
        content: 'Non possiedo nessuno di questi capi',
      );
    }

    if (notOwned.isEmpty) {
      _addMessage(
        sender: MessageSender.ai,
        content:
            'Perfetto! 🎉 Hai già tutto per creare questo look!\n\n'
            'Indossa i tuoi capi e sarai fantastico/a! ✨',
      );
      _currentStep = ConversationStep.completed;
    } else {
      _shoppingItems = notOwned;
      _addMessage(
        sender: MessageSender.ai,
        content:
            'Capito! Ti mancano ${notOwned.length} capi.\n\n'
            'Qual è il tuo budget per completare il look? 💰',
      );
      _currentStep = ConversationStep.askingBudget;
    }

    notifyListeners();
  }

  Future<void> setBudget(double budget) async {
    _budget = budget;

    _addMessage(
      sender: MessageSender.user,
      content: '€${budget.toStringAsFixed(0)}',
    );

    _addMessage(
      sender: MessageSender.ai,
      content: 'Cerco i migliori capi nel tuo budget... 🛍️',
      isLoading: true,
    );
    _currentStep = ConversationStep.showingShopping;
    notifyListeners();

    try {
      final shoppingLinks = await _geminiService.getShoppingLinks(
        items: _shoppingItems,
        budget: budget,
        style: _selectedStyle ?? 'casual',
      );

      if (shoppingLinks.isNotEmpty) {
        _shoppingItems = shoppingLinks;

        final linksText = shoppingLinks
            .map((s) {
              final priceText = s.price != null
                  ? ' - €${s.price!.toStringAsFixed(0)}'
                  : '';
              final shopText = s.shopName != null ? '🏪 ${s.shopName}' : '';
              final urlText = s.shopUrl != null ? '\n   🔗 ${s.shopUrl}' : '';
              return '${s.typeEmoji} **${s.itemType}**$priceText\n   ${s.description}\n   $shopText$urlText';
            })
            .join('\n\n');

        _updateLastMessage(
          content:
              'Ecco dove puoi acquistare i capi! 🎁\n\n$linksText\n\n'
              'Clicca sui link per andare direttamente ai negozi! 🛒✨',
          isLoading: false,
        );
      } else {
        _updateLastMessage(
          content:
              'Non ho trovato link specifici, ma cerca questi capi nei tuoi negozi preferiti!',
          isLoading: false,
        );
      }
      _currentStep = ConversationStep.completed;
    } catch (e) {
      _updateLastMessage(content: 'Errore: ${e.toString()}', isLoading: false);
    }

    notifyListeners();
  }

  void _addMessage({
    required MessageSender sender,
    required String content,
    List<String>? options,
    bool isLoading = false,
  }) {
    _messages.add(
      ConversationMessage(
        sender: sender,
        content: content,
        options: options,
        isLoading: isLoading,
      ),
    );
  }

  void _updateLastMessage({
    String? content,
    List<String>? options,
    bool? isLoading,
  }) {
    if (_messages.isNotEmpty) {
      _messages[_messages.length - 1] = _messages.last.copyWith(
        content: content,
        options: options,
        isLoading: isLoading,
      );
    }
  }
}
