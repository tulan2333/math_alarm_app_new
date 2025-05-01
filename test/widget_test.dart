// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:math_alarm_app_new/main.dart';
import 'package:math_alarm_app_new/services/notification_service.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    // Crear una instancia de NotificationService para pasar a MyApp
    final notificationService = NotificationService();
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(notificationService: notificationService));

    // Verificar que la aplicación se renderiza correctamente
    expect(find.text('Alarma Matemática'), findsOneWidget);
  });
}
