import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weather_app/models/city_suggestions.dart';
import 'package:weather_app/models/weather.dart';

class WeatherApiClient {
  final String? _apiKey = dotenv.env['WEATHER_API_KEY'];
  final String? _baseUrl = dotenv.env['WEATHER_API_BASE_URL'];

  WeatherApiClient() {
    debugPrint('API Key: $_apiKey');
    debugPrint('Base URL: $_baseUrl');
    if (_apiKey == null || _baseUrl == null) {
      throw Exception('API key or base URL not found in .env file');
    }
  }

  Future<Weather> getWeather(String city) async {
    final url = Uri.parse('$_baseUrl/current.json?key=$_apiKey&q=$city&aqi=no');
    debugPrint('Request URL: $url');
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
    debugPrint('Suggestion URL: $url');
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

  Future<List<Weather>> getForecast(String city) async {
    final url = Uri.parse(
      '$_baseUrl/forecast.json?key=$_apiKey&q=$city&days=5&aqi=no',
    );
    debugPrint('Forecast URL: $url');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final forecastDays = json['forecast']['forecastday'] as List;
      return forecastDays.map((day) => Weather.fromJson(day)).toList();
    } else {
      throw Exception('Failed to load forecast: ${response.statusCode}');
    }
  }
}
