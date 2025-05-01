import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'providers/alarm_provider.dart';  // Corregido el nombre del paquete
import 'screens/home_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Solicitar permisos al inicio con manejo de errores
  final permissionStatus = await Permission.notification.request();
  if (permissionStatus.isDenied) {
    // Manejo de error si los permisos son denegados
    print('Permiso de notificación denegado');
  }

  // Inicializar notificaciones
  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(MyApp(notificationService: notificationService));
}

class MyApp extends StatelessWidget {
  final NotificationService notificationService;

  const MyApp({super.key, required this.notificationService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AAlarmProvider()),
        Provider.value(value: notificationService),
      ],
      child: MaterialApp(
        title: 'Alarma Matemática',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
