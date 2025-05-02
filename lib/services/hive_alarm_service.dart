import 'package:hive_flutter/hive_flutter.dart';
import '../models/alarm.dart';

class HiveAlarmService {
  static const String _boxName = 'alarms';
  late Box<Alarm> _alarmsBox;
  
  /// Inicializa Hive y abre el box de alarmas
  Future<void> initialize() async {
    await Hive.initFlutter();
    Hive.registerAdapter(AlarmAdapter());
    _alarmsBox = await Hive.openBox<Alarm>(_boxName);
  }
  
  /// Obtiene todas las alarmas
  Map<int, Alarm> getAlarms() {
    final Map<int, Alarm> alarms = {};
    for (var key in _alarmsBox.keys) {
      final alarm = _alarmsBox.get(key);
      if (alarm != null) {
        alarms[key as int] = alarm;
      }
    }
    return alarms;
  }
  
  /// Guarda una alarma
  Future<void> saveAlarm(Alarm alarm) async {
    await _alarmsBox.put(alarm.id, alarm);
  }
  
  /// Elimina una alarma
  Future<void> deleteAlarm(int id) async {
    await _alarmsBox.delete(id);
  }
  
  /// Limpia todas las alarmas
  Future<void> clearAll() async {
    await _alarmsBox.clear();
  }
  
  /// Cierra el box de alarmas
  Future<void> close() async {
    await _alarmsBox.close();
  }
}