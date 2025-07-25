import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/api/weather_api_client.dart';
import 'package:weather_app/bloc/weather_event.dart';
import 'package:weather_app/bloc/weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherApiClient weatherApiClient;

  WeatherBloc(this.weatherApiClient) : super(const WeatherInitial()) {
    on<FetchWeather>((event, emit) async {
      emit(const WeatherLoading(unit: TemperatureUnit.celsius));
      try {
        final weather = await weatherApiClient.getWeather(event.city);
        emit(WeatherLoaded(weather, unit: state.unit));
      } catch (e) {
        emit(
          WeatherError(
            'Failed to fetch weather: ${e.toString()}',
            unit: state.unit,
          ),
        );
      }
    });

    on<FetchCitySuggestions>((event, emit) async {
      try {
        final suggestions = await weatherApiClient.getCitySuggestions(
          event.query,
        );
        emit(CitySuggestionsLoaded(suggestions, unit: state.unit));
      } catch (e) {
        emit(
          WeatherError(
            'Failed to load suggestions: ${e.toString()}',
            unit: state.unit,
          ),
        );
      }
    });

    on<ToggleTemperatureUnit>((event, emit) {
      final newUnit = state.unit == TemperatureUnit.celsius
          ? TemperatureUnit.fahrenheit
          : TemperatureUnit.celsius;
      if (state is WeatherLoaded) {
        emit(WeatherLoaded((state as WeatherLoaded).weather, unit: newUnit));
      } else if (state is WeatherForecastLoaded) {
        emit(
          WeatherForecastLoaded(
            (state as WeatherForecastLoaded).currentWeather,
            (state as WeatherForecastLoaded).forecast,
            unit: newUnit,
          ),
        );
      } else if (state is WeatherError) {
        emit(WeatherError((state as WeatherError).message, unit: newUnit));
      } else if (state is CitySuggestionsLoaded) {
        emit(
          CitySuggestionsLoaded(
            (state as CitySuggestionsLoaded).suggestions,
            unit: newUnit,
          ),
        );
      } else {
        emit(WeatherInitial(unit: newUnit));
      }
    });

    on<FetchWeatherAndForecast>((event, emit) async {
      emit(WeatherLoading(unit: state.unit));
      try {
        final weather = await weatherApiClient.getWeather(event.city);
        final forecast = await weatherApiClient.getForecast(event.city);
        emit(WeatherForecastLoaded(weather, forecast, unit: state.unit));
      } catch (e) {
        emit(
          WeatherError(
            'Failed to fetch weather or forecast: ${e.toString()}',
            unit: state.unit,
          ),
        );
      }
    });
  }
}
