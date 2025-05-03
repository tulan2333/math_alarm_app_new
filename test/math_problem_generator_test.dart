import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:math_alarm_app_new/utils/math_problem_generator.dart';

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
    _playAlarmSound(); // No necesitas await aquí porque initState no puede ser async
  }

  void _generateNewProblem() {
    _currentProblem = MathProblemGenerator.generateProblem(widget.difficulty);
    _options = MathProblemGenerator.generateOptions(_currentProblem.result);
    setState(() {}); // Actualiza la pantalla con nuevos datos
  }

  Future<void> _playAlarmSound() async {
    await _player.play(AssetSource('sounds/alarm_sound.mp3'));
    await _player.setVolume(1.0);
    await _player.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> _stopAlarmSound() async {
    await _player.stop();
  }

  void _checkAnswer(int selected) async {
    if (selected == _currentProblem.result) {
      await _stopAlarmSound();
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
  void dispose() {
    _player.dispose();
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


void main() {
  group('MathProblemGenerator', () {
    test('generateProblem con dificultad 1 debe crear un problema de suma simple', () {
      final problem = MathProblemGenerator.generateProblem(1);
      
      expect(problem.operator, equals('+'));
      expect(problem.left, lessThanOrEqualTo(10));
      expect(problem.right, lessThanOrEqualTo(10));
      expect(problem.result, equals(problem.left + problem.right));
    });

    test('generateProblem con dificultad 2 debe crear un problema de suma o resta', () {
      final problem = MathProblemGenerator.generateProblem(2);
      
      expect(['+', '-'].contains(problem.operator), isTrue);
      expect(problem.left, lessThanOrEqualTo(20));
      expect(problem.right, lessThanOrEqualTo(20));
      
      int expectedResult = problem.operator == '+' 
          ? problem.left + problem.right 
          : problem.left - problem.right;
      expect(problem.result, equals(expectedResult));
    });

    test('generateProblem con dificultad 3 debe crear un problema de multiplicación', () {
      final problem = MathProblemGenerator.generateProblem(3);
      
      expect(problem.operator, equals('*'));
      expect(problem.left, lessThanOrEqualTo(12));
      expect(problem.right, lessThanOrEqualTo(12));
      expect(problem.result, equals(problem.left * problem.right));
    });

    test('generateOptions debe crear 4 opciones incluyendo el resultado correcto', () {
      final options = MathProblemGenerator.generateOptions(10);
      
      expect(options.length, equals(4));
      expect(options.contains(10), isTrue);
      
      // Verificar que todas las opciones son diferentes
      final uniqueOptions = options.toSet();
      expect(uniqueOptions.length, equals(4));
    });
  });
}
