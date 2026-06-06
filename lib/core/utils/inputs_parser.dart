import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class InputsParser {
  static Future<List<dynamic>> parseInputs() async {
    final jsonString = await rootBundle.loadString('assets/crops_and_livestock.json');
    return json.decode(jsonString);
  }

  static List<String> getCategories(List<dynamic> data) {
    return data.map<String>((e) => e['category'] as String).toList();
  }

  static List<String> getSubcategories(List<dynamic> data, String category) {
    final catData = data.firstWhere((e) => e['category'] == category, orElse: () => null);
    if (catData == null || catData['subcategories'] == null) return [];
    return (catData['subcategories'] as List).map<String>((e) => e['name'] as String).toList();
  }

  static List<String> getItems(List<dynamic> data, String category, String subcategory) {
    final catData = data.firstWhere((e) => e['category'] == category, orElse: () => null);
    if (catData == null || catData['subcategories'] == null) return [];
    
    final subData = (catData['subcategories'] as List).firstWhere((e) => e['name'] == subcategory, orElse: () => null);
    if (subData == null || subData['items'] == null) return [];

    return (subData['items'] as List).map<String>((e) => e['name'] as String).toList();
  }

  static List<String> getVarieties(List<dynamic> data, String category, String subcategory, String item) {
    final catData = data.firstWhere((e) => e['category'] == category, orElse: () => null);
    if (catData == null || catData['subcategories'] == null) return [];
    
    final subData = (catData['subcategories'] as List).firstWhere((e) => e['name'] == subcategory, orElse: () => null);
    if (subData == null || subData['items'] == null) return [];

    final itemData = (subData['items'] as List).firstWhere((e) => e['name'] == item, orElse: () => null);
    if (itemData == null || itemData['types_or_varieties'] == null) return [];

    return (itemData['types_or_varieties'] as List).map<String>((e) => e as String).toList();
  }
}
