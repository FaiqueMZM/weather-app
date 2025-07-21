import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/api/weather_api_client.dart';
import 'package:weather_app/bloc/weather_event.dart';
import 'package:weather_app/bloc/weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherApiClient weatherApiClient;

  WeatherBloc(this.weatherApiClient) : super(WeatherInitial()) {
    on<FetchWeather>((event, emit) async {
      emit(WeatherLoading());
      try {
        final weather = weatherApiClient.getWeather(event.city);
        emit(WeatherLoaded(await weather));
      } catch (e) {
        emit(WeatherError('Failed to fetch weather: ${e.toString()}'));
      }
    });
  }
}
