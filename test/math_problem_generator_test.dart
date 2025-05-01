import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import '../utils/math_problem_generator.dart';

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
  late MathProblem _currentProblem;
  late List<int> _options;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _generateNewProblem();
    _playAlarmSound();
  }

  void _generateNewProblem() {
    _currentProblem = MathProblemGenerator.generateProblem(widget.difficulty);
    _options = MathProblemGenerator.generateOptions(_currentProblem.result);
    setState(() {}); // Actualiza la pantalla con nuevos datos
  }

  void _playAlarmSound() {
    FlutterRingtonePlayer.play(
      android: AndroidSounds.alarm,
      ios: IosSounds.alarm,
      looping: true,
      volume: 1.0,
    );
  }

  void _stopAlarmSound() {
    FlutterRingtonePlayer.stop();
  }

  void _checkAnswer(int selected) {
    if (selected == _currentProblem.result) {
      _stopAlarmSound();
      setState(() {
        _isCorrect = true;
      });
      // Si quieres volver a la pantalla anterior:
      // Navigator.pop(context);
    } else {
      setState(() {
        _isCorrect = false;
      });
      _generateNewProblem(); // Genera otro reto si falla
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
