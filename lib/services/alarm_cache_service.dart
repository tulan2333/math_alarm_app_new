import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/alarm.dart';

class AlarmCacheService {
  static const String _alarmsKey = 'alarms';
  Map<int, Alarm>? _cachedAlarms;
  
  Future<Map<int, Alarm>> getAlarms() async {
    if (_cachedAlarms != null) {
      return _cachedAlarms!;
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final alarmsJson = prefs.getStringList(_alarmsKey) ?? [];
      
      final Map<int, Alarm> alarms = {};
      for (final alarmJson in alarmsJson) {
        final alarm = Alarm.fromJson(json.decode(alarmJson));
        alarms[alarm.id] = alarm;
      }
      
      _cachedAlarms = alarms;
      return alarms;
    } catch (e) {
      print('Error al cargar alarmas desde caché: $e');
      return {};
    }
  }
  
  Future<bool> saveAlarm(Alarm alarm) async {
    try {
      final alarms = await getAlarms();
      alarms[alarm.id] = alarm;
      
      final prefs = await SharedPreferences.getInstance();
      final alarmsJson = alarms.values
          .map((alarm) => json.encode(alarm.toJson()))
          .toList();
      
      final result = await prefs.setStringList(_alarmsKey, alarmsJson);
      _cachedAlarms = alarms;
      return result;
    } catch (e) {
      print('Error al guardar alarma en caché: $e');
      return false;
    }
  }
  
  Future<bool> deleteAlarm(int id) async {
    try {
      final alarms = await getAlarms();
      alarms.remove(id);
      
      final prefs = await SharedPreferences.getInstance();
      final alarmsJson = alarms.values
          .map((alarm) => json.encode(alarm.toJson()))
          .toList();
      
      final result = await prefs.setStringList(_alarmsKey, alarmsJson);
      _cachedAlarms = alarms;
      return result;
    } catch (e) {
      print('Error al eliminar alarma de caché: $e');
      return false;
    }
  }
  
  Future<bool> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final result = await prefs.remove(_alarmsKey);
      _cachedAlarms = {};
      return result;
    } catch (e) {
      print('Error al limpiar todas las alarmas: $e');
      return false;
    }
  }
  
  void invalidateCache() {
    _cachedAlarms = null;
  }
}