import 'package:flutter_test/flutter_test.dart';
import 'package:math_alarm_app_new/models/alarm.dart';
import 'package:math_alarm_app_new/services/alarm_cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AlarmCacheService cacheService;
  
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    cacheService = AlarmCacheService();
  });
  
  test('getAlarms devuelve un mapa vacío cuando no hay alarmas', () async {
    final alarms = await cacheService.getAlarms();
    expect(alarms, isEmpty);
  });
  
  test('saveAlarm guarda correctamente una alarma', () async {
    final alarm = Alarm(
      id: 1,
      time: DateTime.now(),
      days: List.filled(7, false),
      isActive: true,
    );
    
    final result = await cacheService.saveAlarm(alarm);
    expect(result, true);
    
    final alarms = await cacheService.getAlarms();
    expect(alarms.length, 1);
    expect(alarms[1]!.id, alarm.id);
  });
  
  test('deleteAlarm elimina correctamente una alarma', () async {
    final alarm = Alarm(
      id: 1,
      time: DateTime.now(),
      days: List.filled(7, false),
      isActive: true,
    );
    
    await cacheService.saveAlarm(alarm);
    final result = await cacheService.deleteAlarm(1);
    expect(result, true);
    
    final alarms = await cacheService.getAlarms();
    expect(alarms, isEmpty);
  });
  
  test('clearAll elimina todas las alarmas', () async {
    final alarm1 = Alarm(
      id: 1,
      time: DateTime.now(),
      days: List.filled(7, false),
      isActive: true,
    );
    
    final alarm2 = Alarm(
      id: 2,
      time: DateTime.now(),
      days: List.filled(7, false),
      isActive: true,
    );
    
    await cacheService.saveAlarm(alarm1);
    await cacheService.saveAlarm(alarm2);
    
    final result = await cacheService.clearAll();
    expect(result, true);
    
    final alarms = await cacheService.getAlarms();
    expect(alarms, isEmpty);
  });
  
  test('invalidateCache fuerza una recarga desde SharedPreferences', () async {
    final alarm = Alarm(
      id: 1,
      time: DateTime.now(),
      days: List.filled(7, false),
      isActive: true,
    );
    
    await cacheService.saveAlarm(alarm);
    cacheService.invalidateCache();
    
    final alarms = await cacheService.getAlarms();
    expect(alarms.length, 1);
    expect(alarms[1]!.id, alarm.id);
  });
}