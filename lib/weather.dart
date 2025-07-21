class Weather {
  final String city;
  final double temperature;
  final String condition;
  final String iconUrl;

  Weather({
    required this.city,
    required this.temperature,
    required this.condition,
    required this.iconUrl,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      city: json['location']['name'] as String,
      temperature: (json['current']['temp_c'] as num).toDouble(),
      condition: json['current']['condition']['text'] as String,
      iconUrl: 'https:${json['current']['condition']['icon']}',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Weather &&
          runtimeType == other.runtimeType &&
          city == other.city &&
          temperature == other.temperature &&
          condition == other.condition &&
          iconUrl == other.iconUrl;

  @override
  int get hashCode =>
      city.hashCode ^
      temperature.hashCode ^
      condition.hashCode ^
      iconUrl.hashCode;
}
