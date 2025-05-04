// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:math_alarm_app_new/main.dart';
import 'package:math_alarm_app_new/services/hive_alarm_service.dart';
import 'package:math_alarm_app_new/services/notification_service.dart';
import 'package:math_alarm_app_new/models/alarm.dart';
// Comentamos esta importación para evitar problemas en las pruebas
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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

// Creamos una clase mock más simple que no dependa de FlutterLocalNotificationsPlugin
class MockNotificationService extends NotificationService {
  @override
  Future<void> initialize() async {}
  
  @override
  Future<void> scheduleAlarm(Alarm alarm) async {}
  
  @override
  Future<void> cancelAlarm(int id) async {}
  
  @override
  int _getAndroidVersion() {
    return 0;
  }
}

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Crear un mock de HiveAlarmService
    final mockHiveService = MockHiveAlarmService();
    final notificationService = MockNotificationService();
    
    // Construir nuestra app y disparar un frame.
    await tester.pumpWidget(MyApp(
      notificationService: notificationService,
      hiveAlarmService: mockHiveService,
    ));
    
    // Verificar que la aplicación se renderiza correctamente
    expect(find.text('Alarma Matemática'), findsOneWidget);
  });
}
