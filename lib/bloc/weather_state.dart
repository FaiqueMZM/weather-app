import 'package:equatable/equatable.dart';
import 'package:weather_app/models/city_suggestions.dart';
import 'package:weather_app/models/weather.dart';

enum TemperatureUnit { celsius, fahrenheit }

abstract class WeatherState extends Equatable {
  final TemperatureUnit unit;
  const WeatherState({this.unit = TemperatureUnit.celsius});

  @override
  List<Object> get props => [unit];
}

class WeatherInitial extends WeatherState {
  const WeatherInitial({super.unit});
}

class WeatherLoading extends WeatherState {
  const WeatherLoading({super.unit});
}

class WeatherLoaded extends WeatherState {
  final Weather weather;
  const WeatherLoaded(this.weather, {super.unit});

  @override
  List<Object> get props => [weather, unit];
}

class WeatherForecastLoaded extends WeatherState {
  final Weather currentWeather;
  final List<Weather> forecast;
  const WeatherForecastLoaded(this.currentWeather, this.forecast, {super.unit});

  @override
  List<Object> get props => [currentWeather, forecast, unit];
}

class WeatherError extends WeatherState {
  final String message;
  const WeatherError(this.message, {super.unit});

  @override
  List<Object> get props => [message, unit];
}

class CitySuggestionsLoaded extends WeatherState {
  final List<CitySuggestion> suggestions;
  const CitySuggestionsLoaded(this.suggestions, {super.unit});

  @override
  List<Object> get props => [suggestions, unit];
}
