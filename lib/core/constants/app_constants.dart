class AppConstants {
  // App Info
  static const String appName = 'Glam AI';
  static const String appTagline = 'Your AI Fashion Stylist';
  
  // AI Prompts
  static const String clothingAnalysisPrompt = '''
Analyze this clothing item image and provide details in the following JSON format:
{
  "type": "shirt/pants/dress/jacket/shoes/accessory/etc",
  "category": "casual/formal/sporty/elegant/streetwear",
  "color": "primary color",
  "colors": ["list", "of", "colors"],
  "pattern": "solid/striped/floral/geometric/etc",
  "material": "cotton/leather/denim/silk/etc",
  "style": "modern/vintage/classic/trendy",
  "season": "spring/summer/fall/winter/all-season",
  "occasion": ["casual", "work", "party", "date", "etc"],
  "brand": "if visible, otherwise null",
  "description": "brief description of the item"
}
Only respond with valid JSON, no additional text.
''';

  static const String outfitGenerationPrompt = '''
Based on this clothing item, suggest 3 complete outfit combinations. 
For each outfit, provide matching items that would create a stylish look.
Respond in the following JSON format:
{
  "outfits": [
    {
      "name": "Outfit name/theme",
      "style": "casual/elegant/sporty/etc",
      "occasion": "when to wear this",
      "items": [
        {"type": "top", "description": "specific item description", "color": "color"},
        {"type": "bottom", "description": "specific item description", "color": "color"},
        {"type": "shoes", "description": "specific item description", "color": "color"},
        {"type": "accessory", "description": "specific item description", "color": "color"}
      ],
      "tips": "styling tip for this outfit"
    }
  ]
}
Only respond with valid JSON, no additional text.
''';

  // Camera
  static const double cameraPreviewAspectRatio = 3 / 4;
  
  // Animation Durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
}
