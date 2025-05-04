import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:permission_handler/permission_handler.dart';
// import 'package:device_info_plus/device_info_plus.dart';  // Comentado
import 'dart:io';
import '../models/alarm.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Inicializar zonas horarias
    tz_data.initializeTimeZones();
    
    // Solicitar permiso de notificación para Android 13+
    if (Platform.isAndroid) {
      // Alternativa a device_info_plus
      final androidVersion = _getAndroidVersion();
      if (androidVersion >= 33) { // API 33 = Android 13
        final status = await Permission.notification.status;
        if (status.isDenied) {
          await Permission.notification.request();
        }
      }
    }
    
    // Configurar notificaciones
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: DarwinInitializationSettings(),
    );
    
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Manejar respuesta de notificación
      },
    );
  }

  Future<void> scheduleAlarm(Alarm alarm) async {
    // Crear los detalles de la notificación
    final androidNotificationDetails = AndroidNotificationDetails(
      'alarm_channel',
      'Alarmas',
      channelDescription: 'Canal para notificaciones de alarma',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      actions: [
        const AndroidNotificationAction('snooze', 'Posponer'),
        const AndroidNotificationAction('dismiss', 'Descartar'),
      ],
    );
    
    final notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );
    
    // Calcular la próxima ocurrencia de la alarma
    final now = DateTime.now();
    final alarmTime = DateTime(
      now.year,
      now.month,
      now.day,
      alarm.time.hour,
      alarm.time.minute,
    );
    
    // Ajustar para el día siguiente si la hora ya pasó
    final scheduledDate = alarmTime.isBefore(now)
        ? alarmTime.add(const Duration(days: 1))
        : alarmTime;
    
    // Programar la notificación
    await flutterLocalNotificationsPlugin.zonedSchedule(
      alarm.id,
      'Alarma',
      alarm.label.isNotEmpty ? alarm.label : 'Es hora de despertar',
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // Eliminar este parámetro que causa el error
      // uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
  
  Future<void> cancelAlarm(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
  
  // Implementación simple para obtener la versión de Android
  int _getAndroidVersion() {
  // Valor predeterminado para cuando no se puede determinar
  return 30; // Android 11 como valor seguro predeterminado
  }
}