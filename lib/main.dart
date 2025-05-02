import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'providers/alarm_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'services/hive_alarm_service.dart';
import 'models/alarm.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Hive
  await Hive.initFlutter();
  Hive.registerAdapter(AlarmAdapter());
  
  // Inicializar HiveAlarmService
  final hiveAlarmService = HiveAlarmService();
  await hiveAlarmService.initialize();

  // Solicitar permisos al inicio con manejo de errores
  final permissionStatus = await Permission.notification.request();
  if (permissionStatus.isDenied) {
    // Manejo de error si los permisos son denegados
    print('Permiso de notificación denegado');
  }

  // Inicializar notificaciones
  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(MyApp(
    notificationService: notificationService,
    hiveAlarmService: hiveAlarmService,
  ));
}

class MyApp extends StatelessWidget {
  final NotificationService notificationService;
  final HiveAlarmService hiveAlarmService;

  const MyApp({
    super.key, 
    required this.notificationService,
    required this.hiveAlarmService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AlarmProvider(hiveAlarmService: hiveAlarmService),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider.value(value: notificationService),
        Provider.value(value: hiveAlarmService),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Alarma Matemática',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
              brightness: Brightness.light,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            darkTheme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
              brightness: Brightness.dark,
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.grey[900],
                foregroundColor: Colors.white,
              ),
              cardColor: Colors.grey[850],
              scaffoldBackgroundColor: Colors.grey[900],
            ),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
