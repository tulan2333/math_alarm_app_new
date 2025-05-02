import 'package:flutter_test/flutter_test.dart';
import 'package:math_alarm_app_new/models/alarm.dart';
import 'package:math_alarm_app_new/providers/alarm_provider.dart';
import 'package:math_alarm_app_new/services/hive_alarm_service.dart';

// En lugar de usar Mock, implementa clases de prueba directamente
class MockHiveAlarmService implements HiveAlarmService {
  @override
  Map<int, Alarm> getAlarms() => {};
  
  @override
  Future<void> saveAlarm(Alarm alarm) async {}
  
  @override
  Future<void> deleteAlarm(int id) async {}
  
  @override
  Future<void> initialize() async {}
  
  @override
  Future<void> clearAll() async {}
  
  @override
  Future<void> close() async {}
}

void main() {
  group('AlarmProvider', () {
    late AlarmProvider provider;
    late MockHiveAlarmService mockHiveService;
    
    setUp(() {
      mockHiveService = MockHiveAlarmService();
      provider = AlarmProvider(hiveAlarmService: mockHiveService);
    });
    
    test('alarms inicialmente está vacío', () {
      expect(provider.alarms, isEmpty);
    });
    
    test('addAlarm añade correctamente una alarma', () async {
      final alarm = Alarm(
        id: 1,
        time: DateTime.now(),
        days: List.filled(7, false),
        isActive: true,
      );
      
      provider.addAlarm(alarm);
      expect(provider.alarms.length, 1);
      expect(provider.alarms[0].id, alarm.id);
    });
    
    test('updateAlarm actualiza correctamente una alarma', () async {
      final alarm = Alarm(
        id: 1,
        time: DateTime.now(),
        days: List.filled(7, false),
        isActive: true,
        label: 'Test',
      );
      
      provider.addAlarm(alarm);
      
      final updatedAlarm = alarm.copyWith(
        label: 'Updated Test',
        isActive: false,
      );
      
      provider.updateAlarm(updatedAlarm);
      
      expect(provider.alarms.length, 1);
      expect(provider.alarms[0].label, 'Updated Test');
      expect(provider.alarms[0].isActive, false);
    });
    
    test('deleteAlarm elimina correctamente una alarma', () async {
      final alarm = Alarm(
        id: 1,
        time: DateTime.now(),
        days: List.filled(7, false),
        isActive: true,
      );
      
      provider.addAlarm(alarm);
      provider.deleteAlarm(1);
      
      expect(provider.alarms, isEmpty);
    });
    
    test('toggleAlarm cambia correctamente el estado de una alarma', () async {
      final alarm = Alarm(
        id: 1,
        time: DateTime.now(),
        days: List.filled(7, false),
        isActive: true,
      );
      
      provider.addAlarm(alarm);
      provider.toggleAlarm(1);
      
      expect(provider.alarms[0].isActive, false);
    });
  });
}