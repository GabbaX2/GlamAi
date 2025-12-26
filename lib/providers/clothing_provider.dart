import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/clothing_item.dart';
import '../models/outfit.dart';
import '../services/gemini_service.dart';

enum AnalysisState { idle, analyzing, success, error }

class ClothingProvider extends ChangeNotifier {
  ClothingItem? _currentItem;
  List<Outfit> _outfits = [];
  AnalysisState _analysisState = AnalysisState.idle;
  AnalysisState _outfitState = AnalysisState.idle;
  String? _errorMessage;

  ClothingItem? get currentItem => _currentItem;
  List<Outfit> get outfits => _outfits;
  AnalysisState get analysisState => _analysisState;
  AnalysisState get outfitState => _outfitState;
  String? get errorMessage => _errorMessage;

  bool get isAnalyzing => _analysisState == AnalysisState.analyzing;
  bool get isGeneratingOutfits => _outfitState == AnalysisState.analyzing;

  final GeminiService _geminiService = GeminiService.instance;

  Future<void> analyzeImage(String imagePath) async {
    _analysisState = AnalysisState.analyzing;
    _errorMessage = null;
    _currentItem = null;
    _outfits = [];
    notifyListeners();

    try {
      final file = File(imagePath);
      final item = await _geminiService.analyzeClothingFromFile(file);
      
      if (item != null) {
        _currentItem = item;
        _analysisState = AnalysisState.success;
      } else {
        _analysisState = AnalysisState.error;
        _errorMessage = 'Could not analyze the image. Please try again.';
      }
    } catch (e) {
      _analysisState = AnalysisState.error;
      _errorMessage = 'Error: ${e.toString()}';
    }

    notifyListeners();
  }

  Future<void> analyzeImageFromBytes(List<int> bytes, {String? imagePath}) async {
    _analysisState = AnalysisState.analyzing;
    _errorMessage = null;
    _currentItem = null;
    _outfits = [];
    notifyListeners();

    try {
      final item = await _geminiService.analyzeClothingFromBytes(
        Uint8List.fromList(bytes),
        imagePath: imagePath,
      );
      
      if (item != null) {
        _currentItem = item;
        _analysisState = AnalysisState.success;
      } else {
        _analysisState = AnalysisState.error;
        _errorMessage = 'Could not analyze the image. Please try again.';
      }
    } catch (e) {
      _analysisState = AnalysisState.error;
      _errorMessage = 'Error: ${e.toString()}';
    }

    notifyListeners();
  }

  Future<void> generateOutfits() async {
    if (_currentItem == null) return;

    _outfitState = AnalysisState.analyzing;
    _outfits = [];
    notifyListeners();

    try {
      Uint8List? imageBytes;
      if (_currentItem!.imagePath != null) {
        final file = File(_currentItem!.imagePath!);
        if (await file.exists()) {
          imageBytes = await file.readAsBytes();
        }
      }

      final outfits = await _geminiService.generateOutfits(
        _currentItem!,
        imageBytes: imageBytes,
      );
      
      if (outfits.isNotEmpty) {
        _outfits = outfits;
        _outfitState = AnalysisState.success;
      } else {
        _outfitState = AnalysisState.error;
        _errorMessage = 'Could not generate outfits. Please try again.';
      }
    } catch (e) {
      _outfitState = AnalysisState.error;
      _errorMessage = 'Error: ${e.toString()}';
    }

    notifyListeners();
  }

  void reset() {
    _currentItem = null;
    _outfits = [];
    _analysisState = AnalysisState.idle;
    _outfitState = AnalysisState.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
