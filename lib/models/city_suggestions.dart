class CitySuggestion {
  final String name;

  CitySuggestion({required this.name});

  factory CitySuggestion.fromJson(Map<String, dynamic> json) {
    return CitySuggestion(name: json['name'] as String);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CitySuggestion &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}
