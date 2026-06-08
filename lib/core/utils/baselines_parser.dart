import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class BaselinesParser {
  static Future<Map<String, dynamic>> loadBaselines() async {
    final jsonString = await rootBundle.loadString('assets/crops_and_livestock_baselines.json');
    return json.decode(jsonString);
  }

  static Map<String, dynamic>? getLivestockBaselines(Map<String, dynamic> data, String mainCategory, String subCategory) {
    try {
      return data['livestock'][mainCategory][subCategory];
    } catch (e) {
      return null;
    }
  }

  static Map<String, dynamic>? getCropBaselines(Map<String, dynamic> data, String category) {
    try {
      return data['crops'][category];
    } catch (e) {
      return null;
    }
  }

  static Map<String, dynamic>? getForestryBaselines(Map<String, dynamic> data, String category) {
    try {
      return data['forestry_and_timber'][category];
    } catch (e) {
      return null;
    }
  }
}
