import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // fetch all available breeds from dog ceo
  static Future<List<String>> fetchBreeds() async {
    final response = await http.get(
      Uri.parse('https://dog.ceo/api/breeds/list/all'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final breedsMap = data['message'] as Map<String, dynamic>;
      return breedsMap.keys.toList();
    } else {
      throw Exception('failed to load breeds');
    }
  }

  // fetch a random image for a specific breed
  static Future<String> fetchRandomImage(String breed) async {
    final response = await http.get(
      Uri.parse('https://dog.ceo/api/breed/$breed/images/random'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['message'] as String;
    } else {
      throw Exception('failed to load image for $breed');
    }
  }
}
