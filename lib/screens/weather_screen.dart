import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
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
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6B73FF), // Vibrant blue
              Color(0xFF00D4FF), // Light cyan
            ],
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
            color: Colors.white,
            backgroundColor: Colors.blueAccent.withOpacity(0.8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  // Search Bar with Glassmorphism
                  _buildSearchBar(context),
                  const SizedBox(height: 20),
                  // Modern Buttons
                  _buildActionButtons(context),
                  const SizedBox(height: 20),
                  // Weather Display
                  Expanded(
                    child: BlocBuilder<WeatherBloc, WeatherState>(
                      builder: (context, state) {
                        debugPrint('BlocBuilder state: $state');
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          transitionBuilder: (child, animation) =>
                              FadeTransition(opacity: animation, child: child),
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

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        color: Colors.white.withOpacity(0.2),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Autocomplete<CitySuggestion>(
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
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            _cityController.value = controller.value;
            return TextField(
              controller: controller,
              focusNode: focusNode,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Search for a city...',
                hintStyle: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                suffixIcon: Icon(
                  FeatherIcons.search,
                  color: Colors.white70,
                  size: 20,
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
                borderRadius: BorderRadius.circular(16),
                color: Colors.white.withOpacity(0.9),
                child: Container(
                  width: MediaQuery.of(context).size.width - 40,
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
                            style: GoogleFonts.poppins(
                              color: Colors.black87,
                              fontSize: 14,
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
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const SizedBox(width: 16),
        _buildModernButton(
          text: '°C/°F',
          onPressed: () {
            debugPrint('Toggling temperature unit');
            context.read<WeatherBloc>().add(const ToggleTemperatureUnit());
          },
        ),
      ],
    );
  }

  Widget _buildModernButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherContent(BuildContext context, WeatherState state) {
    if (state is WeatherInitial) {
      return Center(
        key: const ValueKey('initial'),
        child: Text(
          'Enter a city to see the weather',
          style: GoogleFonts.poppins(
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
        key: const ValueKey('loaded'),
        child: _buildCurrentWeatherCard(state.weather, state.unit),
      );
    } else if (state is WeatherForecastLoaded) {
      debugPrint('WeatherForecastLoaded state with unit: ${state.unit}');
      return SingleChildScrollView(
        key: const ValueKey('forecast'),
        child: Column(
          children: [
            _buildCurrentWeatherCard(state.currentWeather, state.unit),
            const SizedBox(height: 24),
            Text(
              '5-Day Forecast',
              style: GoogleFonts.poppins(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: state.forecast.length,
                itemBuilder: (context, index) {
                  final forecast = state.forecast[index];
                  return _buildForecastCard(forecast, state.unit);
                },
              ),
            ),
          ],
        ),
      );
    } else if (state is WeatherError) {
      return Center(
        key: const ValueKey('error'),
        child: Text(
          state.message,
          style: GoogleFonts.poppins(
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              weather.city,
              style: GoogleFonts.poppins(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              unit == TemperatureUnit.celsius
                  ? '${weather.temperatureCelsius.toStringAsFixed(1)}°C'
                  : '${weather.temperatureFahrenheit.toStringAsFixed(1)}°F',
              style: GoogleFonts.poppins(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              weather.condition,
              style: GoogleFonts.poppins(fontSize: 20, color: Colors.white70),
            ),
            const SizedBox(height: 20),
            Image.network(
              weather.iconUrl,
              width: 100,
              height: 100,
              errorBuilder: (context, error, stackTrace) => Icon(
                FeatherIcons.alertCircle,
                color: Colors.redAccent,
                size: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastCard(Weather forecast, TemperatureUnit unit) {
    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatDate(forecast.date),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Image.network(
              forecast.iconUrl,
              width: 50,
              height: 50,
              errorBuilder: (context, error, stackTrace) => Icon(
                FeatherIcons.alertCircle,
                color: Colors.redAccent,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              unit == TemperatureUnit.celsius
                  ? '${forecast.temperatureCelsius.toStringAsFixed(1)}°C'
                  : '${forecast.temperatureFahrenheit.toStringAsFixed(1)}°F',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              forecast.condition,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
              textAlign: TextAlign.center,
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
