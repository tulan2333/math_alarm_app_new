import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/alarm.dart';
import '../services/hive_alarm_service.dart';

class AlarmProvider with ChangeNotifier {
  final HiveAlarmService hiveAlarmService;
  List<Alarm> _alarms = [];
  bool _isLoaded = false;
  
  AlarmProvider({required this.hiveAlarmService});
  
  List<Alarm> get alarms => [..._alarms];
  
  Future<void> loadAlarms() async {
    if (_isLoaded) return;
    
    try {
      final alarmsMap = hiveAlarmService.getAlarms();
      _alarms = alarmsMap.values.toList();
      _isLoaded = true;
      notifyListeners();
      print('Alarmas cargadas: ${_alarms.length}');
    } catch (e) {
      print('Error al cargar alarmas: $e');
      _alarms = [];
      notifyListeners();
    }
  }
  
  Future<void> saveAlarms() async {
    // No es necesario guardar todas las alarmas juntas con Hive
    // ya que cada alarma se guarda individualmente
  }
  
  void addAlarm(Alarm alarm) {
    try {
      _alarms.add(alarm);
      hiveAlarmService.saveAlarm(alarm);
      notifyListeners();
    } catch (e) {
      print('Error al añadir alarma: $e');
    }
  }
  
  void updateAlarm(Alarm updatedAlarm) {
    try {
      final index = _alarms.indexWhere((alarm) => alarm.id == updatedAlarm.id);
      if (index >= 0) {
        _alarms[index] = updatedAlarm;
        hiveAlarmService.saveAlarm(updatedAlarm);
        notifyListeners();
      }
    } catch (e) {
      print('Error al actualizar alarma: $e');
    }
  }
  
  void deleteAlarm(int id) {
    try {
      _alarms.removeWhere((alarm) => alarm.id == id);
      hiveAlarmService.deleteAlarm(id);
      notifyListeners();
    } catch (e) {
      print('Error al eliminar alarma: $e');
    }
  }
  
  void toggleAlarm(int id) {
    try {
      final index = _alarms.indexWhere((alarm) => alarm.id == id);
      if (index >= 0) {
        final updatedAlarm = _alarms[index].copyWith(
          isActive: !_alarms[index].isActive,
        );
        _alarms[index] = updatedAlarm;
        hiveAlarmService.saveAlarm(updatedAlarm);
        notifyListeners();
      }
    } catch (e) {
      print('Error al cambiar estado de alarma: $e');
    }
  }
  
  Alarm getAlarmById(int id) {
    final alarm = _alarms.firstWhere(
      (alarm) => alarm.id == id,
      orElse: () => throw Exception('Alarma con ID $id no encontrada'),
    );
    return alarm;
  }
}