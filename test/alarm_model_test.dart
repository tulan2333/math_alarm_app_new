import 'package:flutter_test/flutter_test.dart';
import 'package:math_alarm_app_new/models/alarm.dart';

void main() {
  group('Alarm', () {
    test('toJson and fromJson should work correctly', () {
      final now = DateTime.now();
      final alarm = Alarm(
        id: 1,
        time: now,
        days: [true, false, true, false, true, false, true],
        isActive: true,
        label: 'Test Alarm',
        mathProblemDifficulty: 2,
      );
      
      final json = alarm.toJson();
      final fromJson = Alarm.fromJson(json);
      
      expect(fromJson.id, equals(alarm.id));
      expect(fromJson.time.hour, equals(alarm.time.hour));
      expect(fromJson.time.minute, equals(alarm.time.minute));
      expect(fromJson.days, equals(alarm.days));
      expect(fromJson.isActive, equals(alarm.isActive));
      expect(fromJson.label, equals(alarm.label));
      expect(fromJson.mathProblemDifficulty, equals(alarm.mathProblemDifficulty));
    });
    
    test('copyWith should create a new instance with updated values', () {
      final now = DateTime.now();
      final alarm = Alarm(
        id: 1,
        time: now,
        days: [true, false, true, false, true, false, true],
        isActive: true,
        label: 'Test Alarm',
        mathProblemDifficulty: 2,
      );
      
      final updatedAlarm = alarm.copyWith(
        isActive: false,
        label: 'Updated Alarm',
      );
      
      expect(updatedAlarm.id, equals(alarm.id));
      expect(updatedAlarm.time, equals(alarm.time));
      expect(updatedAlarm.days, equals(alarm.days));
      expect(updatedAlarm.isActive, equals(false));
      expect(updatedAlarm.label, equals('Updated Alarm'));
      expect(updatedAlarm.mathProblemDifficulty, equals(alarm.mathProblemDifficulty));
    });
  });
}