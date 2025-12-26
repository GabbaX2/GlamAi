import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/env_config.dart';
import '../core/constants/app_constants.dart';
import '../models/clothing_item.dart';
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

    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );

    _visionModel = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );

    _isInitialized = true;
  }

  /// Analyze a clothing item from an image file
  Future<ClothingItem?> analyzeClothingFromFile(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return analyzeClothingFromBytes(bytes, imagePath: imageFile.path);
    } catch (e) {
      print('Error analyzing clothing from file: $e');
      return null;
    }
  }

  /// Analyze a clothing item from image bytes
  Future<ClothingItem?> analyzeClothingFromBytes(
    Uint8List imageBytes, {
    String? imagePath,
  }) async {
    try {
      await initialize();

      final prompt = TextPart(AppConstants.clothingAnalysisPrompt);
      final imagePart = DataPart('image/jpeg', imageBytes);

      final response = await _visionModel.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      final responseText = response.text;
      if (responseText == null || responseText.isEmpty) {
        return null;
      }

      // Parse JSON response
      final jsonString = _extractJson(responseText);
      final jsonData = json.decode(jsonString);
      
      return ClothingItem.fromJson(jsonData, imagePath: imagePath);
    } catch (e) {
      print('Error analyzing clothing: $e');
      return null;
    }
  }

  /// Generate outfit suggestions based on a clothing item
  Future<List<Outfit>> generateOutfits(ClothingItem item, {Uint8List? imageBytes}) async {
    try {
      await initialize();

      final itemDescription = '''
The user has a ${item.type} with the following details:
- Color: ${item.primaryColor}
- Style: ${item.style}
- Category: ${item.category}
- Pattern: ${item.pattern}
- Material: ${item.material}
- Season: ${item.season}
- Description: ${item.description}
''';

      final prompt = '$itemDescription\n\n${AppConstants.outfitGenerationPrompt}';

      GenerateContentResponse response;
      
      if (imageBytes != null) {
        response = await _visionModel.generateContent([
          Content.multi([
            TextPart(prompt),
            DataPart('image/jpeg', imageBytes),
          ])
        ]);
      } else {
        response = await _model.generateContent([
          Content.text(prompt)
        ]);
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
''')
      ]);

      return response.text ?? 'Sorry, I could not process your request.';
    } catch (e) {
      print('Error in chat: $e');
      return 'Sorry, something went wrong. Please try again.';
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
