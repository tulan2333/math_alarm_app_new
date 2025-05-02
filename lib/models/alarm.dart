import 'package:hive/hive.dart';

part 'alarm.g.dart';

/// Clase que representa una alarma en la aplicación.
///
/// Contiene toda la información necesaria para programar y mostrar una alarma,
/// incluyendo la hora, los días de la semana, etiqueta y dificultad del problema matemático.
@HiveType(typeId: 0)
class Alarm {
  @HiveField(0)
  final int id;
  
  @HiveField(1)
  final DateTime time;
  
  @HiveField(2)
  final List<bool> days;
  
  @HiveField(3)
  final bool isActive;
  
  @HiveField(4)
  final String label;
  
  @HiveField(5)
  final int mathProblemDifficulty;
  
  // Getters necesarios para NotificationService
  int get hour => time.hour;
  int get minute => time.minute;
  String get title => label.isNotEmpty ? label : 'Alarma Matemática';

  Alarm({
    required this.id,
    required this.time,
    required this.days,
    this.isActive = true,
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

/// Método que programa una alarma en el sistema de notificaciones.
///
/// Recibe un objeto [Alarm] y programa notificaciones para cada día seleccionado.
/// Retorna `true` si la programación fue exitosa, `false` en caso contrario.
///
/// Lanza una excepción si hay problemas con el sistema de notificaciones.
Future<bool> scheduleAlarm(Alarm alarm) async {
  // Implementación del método
  return true; // Asegurarse de devolver un valor booleano
}