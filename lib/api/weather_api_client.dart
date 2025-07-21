import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather_app/weather.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherApiClient {
  final String? _apiKey = dotenv.env['WEATHER_API_KEY'];
  final String? _baseUrl = dotenv.env['WEATHER_API_BASE_URL'];

  WeatherApiClient() {
    print('API Key: $_apiKey');
    print('Base URL: $_baseUrl');
    if (_apiKey == null || _baseUrl == null) {
      throw Exception('API key or base URL not found in .env file');
    }
  }

  Future<Weather> getWeather(String city) async {
    final url = Uri.parse('$_baseUrl/current.json?key=$_apiKey&q=$city&aqi=no');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Weather.fromJson(json);
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
