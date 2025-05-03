import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alarm_provider.dart';
import '../providers/theme_provider.dart';  // Importar el proveedor de tema
import '../models/alarm.dart';
import '../widgets/alarm_list_item.dart';
import 'alarm_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      // Usar Future.microtask para evitar llamar a notifyListeners durante la construcción
      Future.microtask(() {
        if (mounted) {
          Provider.of<AlarmProvider>(context, listen: false).loadAlarms();
        }
      });
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarma Matemática'),
        elevation: 0,
        actions: [
          // Botón para cambiar el tema
          IconButton(
            icon: Icon(
              Provider.of<ThemeProvider>(context).isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      body: Consumer<AlarmProvider>(
        builder: (ctx, alarmProvider, _) {
          final alarms = alarmProvider.alarms;
          
          if (alarms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.alarm_off,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay alarmas configuradas',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _navigateToAlarmDetail(context),
                    child: const Text('Crear Alarma'),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            itemCount: alarms.length,
            itemBuilder: (ctx, index) {
              return AlarmListItem(
                alarm: alarms[index],
                onTap: () => _navigateToAlarmDetail(
                  context,
                  alarms[index],
                ),
                onToggle: (value) {
                  alarmProvider.toggleAlarm(alarms[index].id);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAlarmDetail(context),
        child: const Icon(Icons.add),
      ),
    );
  }
  
  void _navigateToAlarmDetail(BuildContext context, [Alarm? alarm]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => AlarmDetailScreen(alarm: alarm),
      ),
    );
  }
}