import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  
  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }
  
  static bool get isConfigured => geminiApiKey.isNotEmpty;
}
