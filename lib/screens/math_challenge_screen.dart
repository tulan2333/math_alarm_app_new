import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart'; // Añadir esta importación
import '../utils/math_problem_generator.dart';
import '../providers/alarm_provider.dart'; // Añadir esta importación
import '../models/alarm.dart'; // Añadir esta importación
import 'package:vibration/vibration.dart';
import 'package:permission_handler/permission_handler.dart';

class MathChallengeScreen extends StatefulWidget {
  final int difficulty;
  final int alarmId;

  const MathChallengeScreen({
    Key? key,
    required this.difficulty,
    required this.alarmId,
  }) : super(key: key);

  @override
  State<MathChallengeScreen> createState() => _MathChallengeScreenState();
}

class _MathChallengeScreenState extends State<MathChallengeScreen> {
  late final AudioPlayer _player;
  late MathProblem _currentProblem;
  late List<int> _options;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _generateNewProblem();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // Solicitar permisos de notificación
    var status = await Permission.notification.request();
    if (status.isGranted) {
      _playAlarmSound();
    } else {
      // Si los permisos son denegados, mostrar un diálogo
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permisos necesarios'),
            content: const Text('La aplicación necesita permisos para reproducir sonidos y vibrar.'),
            actions: [
              TextButton(
                onPressed: () {
                  openAppSettings();
                },
                child: const Text('Abrir Configuración'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _playAlarmSound() async {
    if (await Permission.notification.isGranted) {
      try {
        // Obtener la alarma del provider
        final alarmProvider = Provider.of<AlarmProvider>(context, listen: false);
        final alarm = alarmProvider.alarms.firstWhere(
          (a) => a.id == widget.alarmId,
          orElse: () => throw Exception('Alarma no encontrada'),
        );
        
        print('Reproduciendo sonido para alarma ID: ${widget.alarmId}');
        
        if (alarm.customSoundUri != null && alarm.customSoundUri!.isNotEmpty) {
          // Reproducir sonido personalizado
          print('Usando sonido personalizado: ${alarm.customSoundUri}');
          await _player.play(DeviceFileSource(alarm.customSoundUri!));
        } else {
          // Reproducir sonido predeterminado
          print('Usando sonido predeterminado: assets/sounds/alarm_sound.mp3');
          await _player.play(AssetSource('sounds/alarm_sound.mp3'));
        }
        
        await _player.setVolume(1.0);
        await _player.setReleaseMode(ReleaseMode.loop);
        
        _startVibration();
      } catch (e) {
        print('Error al reproducir el sonido: $e');
        // Fallback a sonido predeterminado si hay error
        try {
          print('Intentando reproducir sonido predeterminado como fallback');
          await _player.play(AssetSource('sounds/alarm_sound.mp3'));
        } catch (e) {
          print('Error al reproducir sonido predeterminado: $e');
        }
      }
    }
  }

  void _startVibration() async {
    if (await Vibration.hasVibrator() ?? false) {
      if (await Vibration.hasAmplitudeControl() ?? false) {
        Vibration.vibrate(pattern: [500, 1000, 500, 1000], amplitude: 128, repeat: 0);
      } else {
        Vibration.vibrate(pattern: [500, 1000, 500, 1000], repeat: 0);
      }
    }
  }

  void _generateNewProblem() {
    _currentProblem = MathProblemGenerator.generateProblem(widget.difficulty);
    _options = MathProblemGenerator.generateOptions(_currentProblem.result);
    setState(() {});
  }

  Future<void> _stopAlarmSound() async {
    await _player.stop();
    Vibration.cancel(); // Detiene la vibración
  }

  void _checkAnswer(int selected) async {
    if (selected == _currentProblem.result) {
      await _stopAlarmSound();
      setState(() {
        _isCorrect = true;
      });
      // Puedes cerrar la pantalla si quieres
      // Navigator.pop(context);
    } else {
      setState(() {
        _isCorrect = false;
      });
      _generateNewProblem(); // Si quieres castigar errores
    }
  }

  @override
  void dispose() {
    _player.dispose();
    Vibration.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Desafío Matemático')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              '¿Cuánto es ${_currentProblem.left} ${_currentProblem.operator} ${_currentProblem.right}?',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              children: _options.map((option) {
                return ElevatedButton(
                  onPressed: () => _checkAnswer(option),
                  child: Text(option.toString()),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            if (_isCorrect)
              const Text('¡Correcto!', style: TextStyle(color: Colors.green))
            else
              const Text('Inténtalo de nuevo.', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
