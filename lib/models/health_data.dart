class HealthData {
  final String id;
  final String title;
  final String value;
  final DateTime date;

  HealthData({
    required this.id,
    required this.title,
    required this.value,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'value': value,
      'date': date.toIso8601String(),
    };
  }
}
