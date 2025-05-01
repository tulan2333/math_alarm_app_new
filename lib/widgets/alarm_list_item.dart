import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/alarm.dart';

class AlarmListItem extends StatelessWidget {
  final Alarm alarm;
  final VoidCallback onTap;
  final Function(bool) onToggle;

  const AlarmListItem({
    Key? key,
    required this.alarm,
    required this.onTap,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final List<String> dayLabels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    timeFormat.format(alarm.time),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: alarm.isActive ? Theme.of(context).primaryColor : Colors.grey,
                    ),
                  ),
                  Switch(
                    value: alarm.isActive,
                    onChanged: onToggle,
                  ),
                ],
              ),
              if (alarm.label.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    alarm.label,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(
                  7,
                  (index) => Container(
                    width: 30,
                    height: 30,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: alarm.days[index]
                          ? Theme.of(context).primaryColor
                          : Colors.grey[300],
                    ),
                    child: Center(
                      child: Text(
                        dayLabels[index],
                        style: TextStyle(
                          color: alarm.days[index] ? Colors.white : Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calculate,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Dificultad: ${_getDifficultyLabel(alarm.mathProblemDifficulty)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _getDifficultyLabel(int difficulty) {
    switch (difficulty) {
      case 1:
        return 'Fácil';
      case 2:
        return 'Media';
      case 3:
        return 'Difícil';
      default:
        return 'Fácil';
    }
  }
}