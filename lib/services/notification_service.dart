import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/alarm.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  
  Future<void> initialize() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Manejar la respuesta de notificación aquí
      },
    );
  }
  
  Future<void> scheduleAlarm(Alarm alarm) async {
    // Cancelar alarma existente si existe
    await _notificationsPlugin.cancel(alarm.id);
    
    if (!alarm.isActive) return;
    
    // Programar la alarma para cada día seleccionado
    for (int i = 0; i < 7; i++) {
      if (alarm.days[i]) {
        final now = DateTime.now();
        final scheduledDate = _nextInstanceOfDay(i, alarm.time);
        
        if (scheduledDate.isBefore(now)) continue;
        
        final androidDetails = AndroidNotificationDetails(
          'alarm_channel',
          'Alarmas',
          channelDescription: 'Canal para notificaciones de alarma',
          importance: Importance.max,
          priority: Priority.high,
          fullScreenIntent: true,
        );
        
        final iosDetails = DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );
        
        final notificationDetails = NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        );
        
        await _notificationsPlugin.zonedSchedule(
          alarm.id + i, // ID único para cada día
          'Alarma Matemática',
          alarm.label.isNotEmpty ? alarm.label : 'Es hora de despertar',
          tz.TZDateTime.from(scheduledDate, tz.local),
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          payload: alarm.id.toString(),
        );
      }
    }
  }
  
  DateTime _nextInstanceOfDay(int day, DateTime time) {
    DateTime now = DateTime.now();
    int currentDay = now.weekday % 7; // 0 = domingo, 1 = lunes, etc.
    
    int daysUntilTarget = (day - currentDay) % 7;
    if (daysUntilTarget == 0) {
      // Si es el mismo día, verificar si la hora ya pasó
      final todayAtTime = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
      
      if (todayAtTime.isBefore(now)) {
        // Si la hora ya pasó, programar para la próxima semana
        daysUntilTarget = 7;
      }
    }
    
    return DateTime(
      now.year,
      now.month,
      now.day + daysUntilTarget,
      time.hour,
      time.minute,
    );
  }
  
  Future<void> cancelAlarm(int id) async {
    // Cancelar todas las instancias de la alarma (para todos los días)
    for (int i = 0; i < 7; i++) {
      await _notificationsPlugin.cancel(id + i);
    }
  }
}

// Eliminar el método initialize duplicado que está fuera de la clase