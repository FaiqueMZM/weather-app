import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weather_app/models/city_suggestions.dart';
import 'package:weather_app/models/weather.dart';

class WeatherApiClient {
  final String? _apiKey = dotenv.env['WEATHER_API_KEY'];
  final String? _baseUrl = dotenv.env['WEATHER_API_BASE_URL'];

  WeatherApiClient() {
    print('API Key: $_apiKey'); // Debug print
    print('Base URL: $_baseUrl'); // Debug print
    if (_apiKey == null || _baseUrl == null) {
      throw Exception('API key or base URL not found in .env file');
    }
  }

  Future<Weather> getWeather(String city) async {
    final url = Uri.parse('$_baseUrl/current.json?key=$_apiKey&q=$city&aqi=no');
    print('Request URL: $url'); // Debug print
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Weather.fromJson(json);
    } else {
      throw Exception('Failed to load weather data: ${response.statusCode}');
    }
  }

  Future<List<CitySuggestion>> getCitySuggestions(String query) async {
    if (query.isEmpty) return [];
    final url = Uri.parse('$_baseUrl/search.json?key=$_apiKey&q=$query');
    print('Suggestion URL: $url'); // Debug print
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as List;
      return json.map((item) => CitySuggestion.fromJson(item)).toList();
    } else {
      throw Exception(
        'Failed to load city suggestions: ${response.statusCode}',
      );
    }
  }
}
