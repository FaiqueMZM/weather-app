import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/bloc/weather_bloc.dart';
import 'package:weather_app/bloc/weather_event.dart';
import 'package:weather_app/bloc/weather_state.dart';
import 'package:weather_app/models/city_suggestions.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _cityController = TextEditingController();

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather App')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Autocomplete<CitySuggestion>(
              optionsBuilder: (TextEditingValue textEditingValue) async {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<CitySuggestion>.empty();
                }
                context.read<WeatherBloc>().add(
                  FetchCitySuggestions(textEditingValue.text),
                );
                return await _getSuggestions(context);
              },
              displayStringForOption: (CitySuggestion option) => option.name,
              fieldViewBuilder:
                  (context, controller, focusNode, onFieldSubmitted) {
                    _cityController.value = controller.value;
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        hintText: 'Enter city name',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          context.read<WeatherBloc>().add(
                            FetchWeatherAndForecast(value),
                          );
                        }
                      },
                    );
                  },
              onSelected: (CitySuggestion selection) {
                _cityController.text = selection.name;
                context.read<WeatherBloc>().add(
                  FetchWeatherAndForecast(selection.name),
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_cityController.text.isNotEmpty) {
                  context.read<WeatherBloc>().add(
                    FetchWeatherAndForecast(_cityController.text),
                  );
                }
              },
              child: const Text('Get Weather'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<WeatherBloc>().add(const ToggleTemperatureUnit());
              },
              child: const Text('Toggle °C/°F'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<WeatherBloc, WeatherState>(
                builder: (context, state) {
                  print('BlocBuilder state: $state'); // Debug print
                  if (state is WeatherInitial) {
                    return const Center(
                      child: Text('Enter a city to see the weather'),
                    );
                  } else if (state is WeatherLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is WeatherLoaded) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            state.weather.city,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            state.unit == TemperatureUnit.celsius
                                ? '${state.weather.temperatureCelsius}°C'
                                : '${state.weather.temperatureFahrenheit}°F',
                            style: const TextStyle(fontSize: 32),
                          ),
                          Text(
                            state.weather.condition,
                            style: const TextStyle(fontSize: 20),
                          ),
                          Image.network(
                            state.weather.iconUrl,
                            width: 64,
                            height: 64,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.error),
                          ),
                        ],
                      ),
                    );
                  } else if (state is WeatherForecastLoaded) {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          // Current Weather
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  state.currentWeather.city,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  state.unit == TemperatureUnit.celsius
                                      ? '${state.currentWeather.temperatureCelsius}°C'
                                      : '${state.currentWeather.temperatureFahrenheit}°F',
                                  style: const TextStyle(fontSize: 32),
                                ),
                                Text(
                                  state.currentWeather.condition,
                                  style: const TextStyle(fontSize: 20),
                                ),
                                Image.network(
                                  state.currentWeather.iconUrl,
                                  width: 64,
                                  height: 64,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.error),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // 5-Day Forecast
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: state.forecast.length,
                              itemBuilder: (context, index) {
                                final forecast = state.forecast[index];
                                return Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          forecast.date,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        Image.network(
                                          forecast.iconUrl,
                                          width: 40,
                                          height: 40,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(Icons.error),
                                        ),
                                        Text(
                                          state.unit == TemperatureUnit.celsius
                                              ? '${forecast.temperatureCelsius}°C'
                                              : '${forecast.temperatureFahrenheit}°F',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (state is WeatherError) {
                    return Center(child: Text(state.message));
                  } else if (state is CitySuggestionsLoaded) {
                    return Container(); // Suggestions handled by Autocomplete
                  }
                  return Container();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Iterable<CitySuggestion>> _getSuggestions(BuildContext context) async {
    final state = context.read<WeatherBloc>().state;
    if (state is CitySuggestionsLoaded) {
      return state.suggestions;
    }
    return [];
  }
}
