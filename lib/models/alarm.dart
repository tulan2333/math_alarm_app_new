class Alarm {
  final int id;
  final DateTime time;
  final List<bool> days;
  final bool isActive;
  final String label;
  final int mathProblemDifficulty;

  Alarm({
    required this.id,
    required this.time,
    required this.days,
    required this.isActive,
    this.label = '',
    this.mathProblemDifficulty = 1,
  });

  Alarm copyWith({
    int? id,
    DateTime? time,
    List<bool>? days,
    bool? isActive,
    String? label,
    int? mathProblemDifficulty,
  }) {
    return Alarm(
      id: id ?? this.id,
      time: time ?? this.time,
      days: days ?? this.days,
      isActive: isActive ?? this.isActive,
      label: label ?? this.label,
      mathProblemDifficulty: mathProblemDifficulty ?? this.mathProblemDifficulty,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': time.toIso8601String(),
      'days': days,
      'isActive': isActive,
      'label': label,
      'mathProblemDifficulty': mathProblemDifficulty,
    };
  }

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['id'],
      time: DateTime.parse(json['time']),
      days: List<bool>.from(json['days']),
      isActive: json['isActive'],
      label: json['label'] ?? '',
      mathProblemDifficulty: json['mathProblemDifficulty'] ?? 1,
    );
  }
}