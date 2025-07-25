import 'package:equatable/equatable.dart';

abstract class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object> get props => [];
}

class FetchWeather extends WeatherEvent {
  final String city;

  const FetchWeather(this.city);

  @override
  List<Object> get props => [city];
}

class FetchCitySuggestions extends WeatherEvent {
  final String query;

  const FetchCitySuggestions(this.query);

  @override
  List<Object> get props => [query];
}

class ToggleTemperatureUnit extends WeatherEvent {
  const ToggleTemperatureUnit();

  @override
  List<Object> get props => [];
}

class FetchWeatherAndForecast extends WeatherEvent {
  final String city;

  const FetchWeatherAndForecast(this.city);

  @override
  List<Object> get props => [city];
}
