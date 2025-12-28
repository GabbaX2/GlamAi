import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/env_config.dart';
import '../core/constants/app_constants.dart';
import '../models/clothing_item.dart';
import '../models/conversation_message.dart';
import '../models/outfit.dart';

class GeminiService {
  static GeminiService? _instance;
  late final GenerativeModel _model;
  late final GenerativeModel _visionModel;
  bool _isInitialized = false;

  GeminiService._();

  static GeminiService get instance {
    _instance ??= GeminiService._();
    return _instance!;
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    final apiKey = EnvConfig.geminiApiKey;
    if (apiKey.isEmpty) {
      throw Exception('Gemini API key not found in .env file');
    }

    _model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);

    _visionModel = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);

    _isInitialized = true;
  }

  /// Analyze a clothing item from an image file
  Future<ClothingItem?> analyzeClothingFromFile(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return analyzeClothingFromBytes(bytes, imagePath: imageFile.path);
  }

  /// Analyze a clothing item from image bytes
  Future<ClothingItem?> analyzeClothingFromBytes(
    Uint8List imageBytes, {
    String? imagePath,
  }) async {
    await initialize();

    final prompt = TextPart(AppConstants.clothingAnalysisPrompt);
    final imagePart = DataPart('image/jpeg', imageBytes);

    final response = await _visionModel.generateContent([
      Content.multi([prompt, imagePart]),
    ]);

    final responseText = response.text;
    if (responseText == null || responseText.isEmpty) {
      throw Exception('Gemini returned empty response');
    }

    // Parse JSON response
    try {
      final jsonString = _extractJson(responseText);
      final jsonData = json.decode(jsonString);
      return ClothingItem.fromJson(jsonData, imagePath: imagePath);
    } catch (e) {
      throw Exception(
        'Failed to parse Gemini response: $e\n\nRaw response: $responseText',
      );
    }
  }

  /// Generate outfit suggestions based on a clothing item
  Future<List<Outfit>> generateOutfits(
    ClothingItem item, {
    Uint8List? imageBytes,
  }) async {
    try {
      await initialize();

      final itemDescription =
          '''
The user has a ${item.type} with the following details:
- Color: ${item.primaryColor}
- Style: ${item.style}
- Category: ${item.category}
- Pattern: ${item.pattern}
- Material: ${item.material}
- Season: ${item.season}
- Description: ${item.description}
''';

      final prompt =
          '$itemDescription\n\n${AppConstants.outfitGenerationPrompt}';

      GenerateContentResponse response;

      if (imageBytes != null) {
        response = await _visionModel.generateContent([
          Content.multi([TextPart(prompt), DataPart('image/jpeg', imageBytes)]),
        ]);
      } else {
        response = await _model.generateContent([Content.text(prompt)]);
      }

      final responseText = response.text;
      if (responseText == null || responseText.isEmpty) {
        return [];
      }

      // Parse JSON response
      final jsonString = _extractJson(responseText);
      final jsonData = json.decode(jsonString);

      final outfitsJson = jsonData['outfits'] as List<dynamic>?;
      if (outfitsJson == null) return [];

      return outfitsJson.map((o) => Outfit.fromJson(o)).toList();
    } catch (e) {
      print('Error generating outfits: $e');
      return [];
    }
  }

  /// Chat with the AI about fashion
  Future<String> chat(String message) async {
    try {
      await initialize();

      final response = await _model.generateContent([
        Content.text('''
You are Glam AI, a friendly and knowledgeable fashion stylist assistant. 
Help the user with fashion advice, outfit suggestions, and style tips.
Be concise, friendly, and use emojis occasionally.

User: $message
'''),
      ]);

      return response.text ?? 'Sorry, I could not process your request.';
    } catch (e) {
      print('Error in chat: $e');
      return 'Sorry, something went wrong. Please try again.';
    }
  }

  /// Simple garment analysis - returns type, color, and brief description
  Future<Map<String, String>?> analyzeGarmentSimple(
    Uint8List imageBytes,
  ) async {
    await initialize();

    final prompt = TextPart('''
Analizza questo capo di abbigliamento nell'immagine.
Rispondi SOLO in formato JSON con questa struttura esatta:
{
  "type": "tipo del capo (es: maglietta, pantaloni, giacca, felpa, camicia, jeans, vestito, gonna, scarpe, accessorio)",
  "color": "colore principale del capo in italiano",
  "description": "breve descrizione del capo in 1-2 frasi in italiano, includi dettagli come pattern, materiale se visibile"
}
Rispondi SOLO con il JSON, senza altro testo.
''');
    final imagePart = DataPart('image/jpeg', imageBytes);

    final response = await _visionModel.generateContent([
      Content.multi([prompt, imagePart]),
    ]);

    final responseText = response.text;
    if (responseText == null || responseText.isEmpty) {
      return null;
    }

    try {
      final jsonString = _extractJson(responseText);
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      return {
        'type': jsonData['type']?.toString() ?? '',
        'color': jsonData['color']?.toString() ?? '',
        'description': jsonData['description']?.toString() ?? '',
      };
    } catch (e) {
      print('Error parsing garment analysis: $e');
      return null;
    }
  }

  /// Get outfit suggestions based on garment and style
  Future<List<OutfitSuggestion>> getOutfitSuggestions({
    required String garmentType,
    required String garmentColor,
    required String style,
    Uint8List? imageBytes,
  }) async {
    await initialize();

    final prompt =
        '''
L'utente ha un/una $garmentType di colore $garmentColor.
Vuole creare un look in stile: $style.

Suggerisci 5-6 capi di abbigliamento per creare un OUTFIT COMPLETO dalla testa ai piedi.
Includi diverse categorie: top/maglietta, pantaloni/gonna, giacca/cappotto, scarpe, accessori (cintura, orologio, borsa, etc).
NON includere il capo originale dell'utente ($garmentType) nei suggerimenti.

Rispondi SOLO in formato JSON con questa struttura:
{
  "suggestions": [
    {
      "itemType": "tipo del capo (es: pantaloni, scarpe, giacca, cintura, orologio, borsa)",
      "description": "descrizione specifica del capo consigliato con dettagli su stile e materiale",
      "color": "colore consigliato che si abbina"
    }
  ]
}
Rispondi SOLO con il JSON, senza altro testo.
''';

    GenerateContentResponse response;
    if (imageBytes != null) {
      response = await _visionModel.generateContent([
        Content.multi([TextPart(prompt), DataPart('image/jpeg', imageBytes)]),
      ]);
    } else {
      response = await _model.generateContent([Content.text(prompt)]);
    }

    final responseText = response.text;
    if (responseText == null || responseText.isEmpty) {
      return [];
    }

    try {
      final jsonString = _extractJson(responseText);
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      final suggestions = jsonData['suggestions'] as List<dynamic>?;
      if (suggestions == null) return [];

      return suggestions.map((s) => OutfitSuggestion.fromJson(s)).toList();
    } catch (e) {
      print('Error parsing outfit suggestions: $e');
      return [];
    }
  }

  /// Get shopping links/recommendations for missing items
  Future<List<OutfitSuggestion>> getShoppingLinks({
    required List<OutfitSuggestion> items,
    required double budget,
    required String style,
  }) async {
    await initialize();

    final itemsList = items
        .map((i) => '- ${i.itemType}: ${i.description} (${i.color})')
        .join('\n');
    final budgetPerItem = (budget / items.length).round();

    // Determine price tier based on budget per item
    String priceTier;
    String suggestedStores;

    if (budgetPerItem <= 50) {
      priceTier = 'ECONOMICO';
      suggestedStores = '''
ASOS (asos.com), Uniqlo (uniqlo.com), Zalando (zalando.it), H&M (hm.com), Zara (zara.com)''';
    } else if (budgetPerItem <= 100) {
      priceTier = 'MEDIO';
      suggestedStores = '''
COS (cos.com), Arket (arket.com), Massimo Dutti (massimodutti.com), Yoox (yoox.com), Levi's (levi.com), Mango (mango.com)''';
    } else if (budgetPerItem <= 250) {
      priceTier = 'MEDIO-ALTO';
      suggestedStores = '''
Sézane (sezane.com), Sandro (sandro-paris.com), Maje (maje.com), Ralph Lauren (ralphlauren.it), Reformation (thereformation.com), The Kooples (thekooples.com)''';
    } else if (budgetPerItem <= 500) {
      priceTier = 'ALTO';
      suggestedStores = '''
Farfetch (farfetch.com), LuisaViaRoma (luisaviaroma.com), Max Mara (maxmara.com), Acne Studios (acnestudios.com), Vestiaire Collective (vestiairecollective.com)''';
    } else {
      priceTier = 'LUXURY';
      suggestedStores = '''
Net-a-Porter (net-a-porter.com), Mr Porter (mrporter.com), Mytheresa (mytheresa.com), Matches Fashion (matchesfashion.com), SSENSE (ssense.com)''';
    }

    final prompt =
        '''
L'utente cerca questi capi per completare un outfit in stile $style:
$itemsList

Budget totale: €${budget.round()} (circa €$budgetPerItem per capo)
Fascia di prezzo: $priceTier

USA SOLO questi negozi per la fascia $priceTier:
$suggestedStores

Per ogni capo, suggerisci un prodotto REALE che si può trovare su questi siti.
IMPORTANTE: Fornisci l'URL esatto alla pagina principale del sito (es: https://www.zara.com) 
o alla sezione specifica (es: https://www.zara.com/it/it/uomo-camicie-l737.html)

Rispondi SOLO in formato JSON:
{
  "items": [
    {
      "itemType": "tipo del capo",
      "description": "nome specifico del prodotto",
      "color": "colore",
      "shopName": "nome negozio",
      "shopUrl": "https://url-del-sito",
      "price": prezzo_stimato_numero
    }
  ]
}
Rispondi SOLO con il JSON.
''';

    final response = await _model.generateContent([Content.text(prompt)]);

    final responseText = response.text;
    if (responseText == null || responseText.isEmpty) {
      return items; // Return original items if no response
    }

    try {
      final jsonString = _extractJson(responseText);
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      final shoppingItems = jsonData['items'] as List<dynamic>?;
      if (shoppingItems == null) return items;

      return shoppingItems.map((s) => OutfitSuggestion.fromJson(s)).toList();
    } catch (e) {
      print('Error parsing shopping links: $e');
      return items;
    }
  }

  /// Extract JSON from response (handles markdown code blocks)
  String _extractJson(String text) {
    // Try to extract JSON from markdown code blocks
    final codeBlockPattern = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```');
    final match = codeBlockPattern.firstMatch(text);
    if (match != null) {
      return match.group(1)!.trim();
    }

    // Try to find JSON object directly
    final jsonPattern = RegExp(r'\{[\s\S]*\}');
    final jsonMatch = jsonPattern.firstMatch(text);
    if (jsonMatch != null) {
      return jsonMatch.group(0)!;
    }

    return text.trim();
  }
}
