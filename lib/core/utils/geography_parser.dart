import 'package:flutter/services.dart' show rootBundle;

class GeographyParser {
  static Future<Map<String, Map<String, Map<String, List<String>>>>> parsePoliticalUnits() async {
    final csvString = await rootBundle.loadString('assets/kenya_political_units.csv');
    final lines = csvString.split('\n');
    
    // Structure: County -> Sub-County (Constituency Name used as Sub-County proxy here based on data shape) -> Constituency -> List of Wards
    // The CSV columns are: county_code,county_name,constituency_code,constituency_name,ward_code,ward_name
    
    final Map<String, Map<String, Map<String, List<String>>>> hierarchy = {};

    // Skip header line
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final parts = line.split(',');
      if (parts.length < 6) continue;

      final countyName = parts[1].trim();
      final constituencyName = parts[3].trim();
      final wardName = parts[5].trim();

      // Given the CSV data shape (no sub_county explicit column), we'll use Constituency as Sub-County, 
      // and duplicate Constituency for the 4-tier requirement, or use County as Tier 1, Constituency as Tier 2 and 3, Ward as Tier 4.
      // Wait, let's treat "Sub-County" and "Constituency" as the same level in standard Kenyan admin structure if not separated, 
      // but to strictly meet the 4-tier requirement we'll structure it as:
      // County -> Constituency -> Constituency (Self) -> Ward
      final subCountyName = constituencyName; 

      hierarchy.putIfAbsent(countyName, () => {});
      hierarchy[countyName]!.putIfAbsent(subCountyName, () => {});
      hierarchy[countyName]![subCountyName]!.putIfAbsent(constituencyName, () => []);
      
      if (!hierarchy[countyName]![subCountyName]![constituencyName]!.contains(wardName)) {
        hierarchy[countyName]![subCountyName]![constituencyName]!.add(wardName);
      }
    }

    return hierarchy;
  }
}
