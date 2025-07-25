class Weather {
  final String city;
  final double temperatureCelsius;
  final double temperatureFahrenheit;
  final String condition;
  final String iconUrl;
  final String date;

  Weather({
    required this.city,
    required this.temperatureCelsius,
    required this.temperatureFahrenheit,
    required this.condition,
    required this.iconUrl,
    required this.date,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    // Handle both current weather and forecast JSON
    final isForecast = json.containsKey('date');
    return Weather(
      city: isForecast ? '' : json['location']['name'] as String,
      temperatureCelsius: isForecast
          ? (json['day']['avgtemp_c'] as num).toDouble()
          : (json['current']['temp_c'] as num).toDouble(),
      temperatureFahrenheit: isForecast
          ? (json['day']['avgtemp_f'] as num).toDouble()
          : (json['current']['temp_f'] as num).toDouble(),
      condition: isForecast
          ? json['day']['condition']['text'] as String
          : json['current']['condition']['text'] as String,
      iconUrl: isForecast
          ? 'https:${json['day']['condition']['icon']}'
          : 'https:${json['current']['condition']['icon']}',
      date: isForecast ? json['date'] as String : '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Weather &&
          runtimeType == other.runtimeType &&
          city == other.city &&
          temperatureCelsius == other.temperatureCelsius &&
          temperatureFahrenheit == other.temperatureFahrenheit &&
          condition == other.condition &&
          iconUrl == other.iconUrl &&
          date == other.date;

  @override
  int get hashCode =>
      city.hashCode ^
      temperatureCelsius.hashCode ^
      temperatureFahrenheit.hashCode ^
      condition.hashCode ^
      iconUrl.hashCode ^
      date.hashCode;
}
