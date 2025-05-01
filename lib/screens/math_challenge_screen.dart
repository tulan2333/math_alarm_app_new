import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import '../utils/math_problem_generator.dart';
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
  late final FlutterRingtonePlayer _player;

  @override
  void initState() {
    super.initState();
    _player = FlutterRingtonePlayer();
    _generateNewProblem();
    _playAlarmSound();
  }

  void _playAlarmSound() {
    _player.play(
      android: AndroidSounds.alarm,
      ios: IosSounds.alarm,
      looping: true,
      volume: 1.0,
    );
    _startVibration();
  }

  Future<void> _stopAlarmSound() async {
    await _player.stop();
    Vibration.cancel();
  }

  late MathProblem _currentProblem;
  late List<int> _options;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _generateNewProblem();
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
    // Verificar permisos antes de reproducir
    if (await Permission.notification.isGranted) {
      final player = FlutterRingtonePlayer();
      try {
        await player.play(
          android: AndroidSounds.alarm,
          ios: IosSounds.alarm,
          looping: true,
          volume: 1.0,
        );
        _startVibration();
      } catch (e) {
        print('Error al reproducir el sonido: $e');
      }
    }
  }

  void _generateNewProblem() {
    _currentProblem = MathProblemGenerator.generateProblem(widget.difficulty);
    _options = MathProblemGenerator.generateOptions(_currentProblem.result);
    setState(() {});
  }

  Future<void> _stopAlarmSound() async {
    final player = FlutterRingtonePlayer();
    await player.stop();
    Vibration.cancel(); // <- stops vibration!
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

void _startVibration() async {
  if (await Vibration.hasVibrator() ?? false) {
    if (await Vibration.hasAmplitudeControl() ?? false) {
      Vibration.vibrate(pattern: [0, 500, 1000, 500, 1000], amplitude: 128, repeat: 0);
    } else {
      Vibration.vibrate(pattern: [0, 500, 1000, 500, 1000], repeat: 0);
    }
  }
}
