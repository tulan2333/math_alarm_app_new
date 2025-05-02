import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/alarm.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  
  Future<void> initialize() async {
    try {
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
    } catch (e) {
      print('Error al inicializar las notificaciones: $e');
      // Aquí podrías implementar una lógica de reintentos o notificar al usuario
    }
  }
  
  Future<bool> scheduleAlarm(Alarm alarm) async {
    try {
      // Cancelar alarma existente si existe
      await _notificationsPlugin.cancel(alarm.id);
      
      if (!alarm.isActive) return true;
      
      // Programar la alarma para cada día seleccionado
      for (int i = 0; i < 7; i++) {
        if (alarm.days[i]) {
          final scheduledDate = _nextInstanceOfDay(i, alarm.hour, alarm.minute);
          
          // En el método scheduleAlarm, corrige:
          await _notificationsPlugin.zonedSchedule(
            alarm.id + i, // ID único para cada día
            'Alarma Matemática',
            alarm.label.isNotEmpty ? alarm.label : 'Alarma Matemática',
            scheduledDate,
            NotificationDetails(
              android: AndroidNotificationDetails(
                'alarm_channel',
                'Alarmas',
                channelDescription: 'Canal para notificaciones de alarma',
                importance: Importance.max,
                priority: Priority.high,
                sound: const RawResourceAndroidNotificationSound('alarm_sound'),
                fullScreenIntent: true,
              ),
              iOS: const DarwinNotificationDetails(
                sound: 'alarm_sound.aiff',
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            // Corregir esta línea:
            dateTimeInterpretation: DateTimeInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          );
        }
      }
      
      return true;
    } catch (e) {
      print('Error al programar la alarma: $e');
      return false;
    }
  }
  
  // Método para mostrar notificación de error
  Future<void> _showErrorNotification(String message) async {
    await _notificationsPlugin.show(
      999999, // ID único para errores
      'Error en la Alarma',
      message,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'error_channel',
          'Errores',
          channelDescription: 'Canal para notificaciones de error',
          importance: Importance.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }
  
  /// Calcula la próxima instancia de un día específico de la semana a una hora determinada.
  /// 
  /// [dayOfWeek]: Día de la semana (0 = lunes, 6 = domingo)
  /// [hour]: Hora del día (0-23)
  /// [minute]: Minuto de la hora (0-59)
  /// 
  /// Retorna un objeto TZDateTime que representa la próxima ocurrencia
  /// del día y hora especificados. Si la fecha resultante ya ha pasado,
  /// se programa para la próxima semana.
  tz.TZDateTime _nextInstanceOfDay(int dayOfWeek, int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    
    // Convertir de nuestro formato (0 = lunes) a formato DateTime (1 = lunes, 7 = domingo)
    int targetDay = dayOfWeek + 1;
    if (targetDay == 7) targetDay = 0; // Domingo es 0 en DateTime
    
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    
    while (scheduledDate.weekday != targetDay || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }
  
  Future<void> cancelAlarm(int id) async {
    try {
      // Cancelar todas las instancias de la alarma (para todos los días)
      for (int i = 0; i < 7; i++) {
        await _notificationsPlugin.cancel(id + i);
      }
    } catch (e) {
      print('Error al cancelar la alarma: $e');
    }
  }
  
  Future<void> cancelAllAlarms() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      print('Error al cancelar todas las alarmas: $e');
    }
  }
}