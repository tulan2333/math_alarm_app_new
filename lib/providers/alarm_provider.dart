import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/alarm.dart';

class AlarmProvider with ChangeNotifier {
  List<Alarm> _alarms = [];
  
  List<Alarm> get alarms => [..._alarms];
  
  Future<void> loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final alarmsJson = prefs.getStringList('alarms') ?? [];
    
    _alarms = alarmsJson
        .map((alarmJson) => Alarm.fromJson(json.decode(alarmJson)))
        .toList();
    
    notifyListeners();
  }
  
  Future<void> saveAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final alarmsJson = _alarms
        .map((alarm) => json.encode(alarm.toJson()))
        .toList();
    
    await prefs.setStringList('alarms', alarmsJson);
  }
  
  void addAlarm(Alarm alarm) {
    _alarms.add(alarm);
    saveAlarms();
    notifyListeners();
  }
  
  void updateAlarm(Alarm updatedAlarm) {
    final index = _alarms.indexWhere((alarm) => alarm.id == updatedAlarm.id);
    if (index >= 0) {
      _alarms[index] = updatedAlarm;
      saveAlarms();
      notifyListeners();
    }
  }
  
  void deleteAlarm(int id) {
    _alarms.removeWhere((alarm) => alarm.id == id);
    saveAlarms();
    notifyListeners();
  }
  
  void toggleAlarm(int id) {
    final index = _alarms.indexWhere((alarm) => alarm.id == id);
    if (index >= 0) {
      final alarm = _alarms[index];
      _alarms[index] = alarm.copyWith(isActive: !alarm.isActive);
      saveAlarms();
      notifyListeners();
    }
  }
}