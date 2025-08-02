import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/bloc/weather_bloc.dart';
import 'package:weather_app/bloc/weather_event.dart';
import 'package:weather_app/bloc/weather_state.dart';
import 'package:weather_app/models/city_suggestions.dart';
import 'package:weather_app/models/weather.dart';

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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blueAccent, Colors.lightBlue],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              if (_cityController.text.isNotEmpty) {
                context.read<WeatherBloc>().add(
                  FetchWeatherAndForecast(_cityController.text),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Search Bar
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Autocomplete<CitySuggestion>(
                      optionsBuilder:
                          (TextEditingValue textEditingValue) async {
                            if (textEditingValue.text.isEmpty) {
                              return const Iterable<CitySuggestion>.empty();
                            }
                            context.read<WeatherBloc>().add(
                              FetchCitySuggestions(textEditingValue.text),
                            );
                            return await _getSuggestions(context);
                          },
                      displayStringForOption: (CitySuggestion option) =>
                          option.name,
                      fieldViewBuilder:
                          (context, controller, focusNode, onFieldSubmitted) {
                            _cityController.value = controller.value;
                            return TextField(
                              controller: controller,
                              focusNode: focusNode,
                              style: const TextStyle(color: Colors.black87),
                              decoration: InputDecoration(
                                hintText: 'Enter city name',
                                hintStyle: TextStyle(color: Colors.grey[600]),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                suffixIcon: Icon(
                                  Icons.search,
                                  color: Colors.grey[600],
                                ),
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
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: MediaQuery.of(context).size.width - 32,
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: ListView.builder(
                                padding: const EdgeInsets.all(8),
                                itemCount: options.length,
                                itemBuilder: (context, index) {
                                  final option = options.elementAt(index);
                                  return GestureDetector(
                                    onTap: () => onSelected(option),
                                    child: ListTile(
                                      title: Text(
                                        option.name,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (_cityController.text.isNotEmpty) {
                            context.read<WeatherBloc>().add(
                              FetchWeatherAndForecast(_cityController.text),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Get Weather',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          print('Toggling temperature unit'); // Debug print
                          context.read<WeatherBloc>().add(
                            const ToggleTemperatureUnit(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Toggle °C/°F',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Weather Display
                  Expanded(
                    child: BlocBuilder<WeatherBloc, WeatherState>(
                      builder: (context, state) {
                        print('BlocBuilder state: $state'); // Debug print
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _buildWeatherContent(context, state),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherContent(BuildContext context, WeatherState state) {
    if (state is WeatherInitial) {
      return const Center(
        key: ValueKey('initial'),
        child: Text(
          'Enter a city to see the weather',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    } else if (state is WeatherLoading) {
      return const Center(
        key: ValueKey('loading'),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else if (state is WeatherLoaded) {
      return Center(
        key: ValueKey('loaded'),
        child: _buildCurrentWeatherCard(state.weather, state.unit),
      );
    } else if (state is WeatherForecastLoaded) {
      print(
        'WeatherForecastLoaded state with unit: ${state.unit}',
      ); // Debug print
      return SingleChildScrollView(
        key: ValueKey('forecast'),
        child: Column(
          children: [
            _buildCurrentWeatherCard(state.currentWeather, state.unit),
            const SizedBox(height: 24),
            const Text(
              '5-Day Forecast',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: state.forecast.length,
                itemBuilder: (context, index) {
                  final forecast = state.forecast[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.white.withOpacity(0.9),
                    child: Container(
                      width: 120,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _formatDate(forecast.date),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Image.network(
                            forecast.iconUrl,
                            width: 48,
                            height: 48,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.error, color: Colors.red),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.unit == TemperatureUnit.celsius
                                ? '${forecast.temperatureCelsius.toStringAsFixed(1)}°C'
                                : '${forecast.temperatureFahrenheit.toStringAsFixed(1)}°F',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            forecast.condition,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
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
      return Center(
        key: ValueKey('error'),
        child: Text(
          state.message,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      );
    } else if (state is CitySuggestionsLoaded) {
      return Container(key: const ValueKey('suggestions'));
    }
    return Container(key: const ValueKey('empty'));
  }

  Widget _buildCurrentWeatherCard(Weather weather, TemperatureUnit unit) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              weather.city,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              unit == TemperatureUnit.celsius
                  ? '${weather.temperatureCelsius.toStringAsFixed(1)}°C'
                  : '${weather.temperatureFahrenheit.toStringAsFixed(1)}°F',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              weather.condition,
              style: const TextStyle(fontSize: 20, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            Image.network(
              weather.iconUrl,
              width: 80,
              height: 80,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String date) {
    if (date.isEmpty) return '';
    final dateTime = DateTime.parse(date);
    return '${dateTime.day}/${dateTime.month}';
  }

  Future<Iterable<CitySuggestion>> _getSuggestions(BuildContext context) async {
    final state = context.read<WeatherBloc>().state;
    if (state is CitySuggestionsLoaded) {
      return state.suggestions;
    }
    return [];
  }
}
