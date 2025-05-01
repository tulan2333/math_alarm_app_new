import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alarm.dart';
import '../providers/alarm_provider.dart';
import '../services/notification_service.dart';

class AlarmDetailScreen extends StatefulWidget {
  final Alarm? alarm;

  const AlarmDetailScreen({Key? key, this.alarm}) : super(key: key);

  @override
  State<AlarmDetailScreen> createState() => _AlarmDetailScreenState();
}

class _AlarmDetailScreenState extends State<AlarmDetailScreen> {
  late TimeOfDay _selectedTime;
  late List<bool> _selectedDays;
  late TextEditingController _labelController;
  late int _selectedDifficulty;
  
  final List<String> _daysOfWeek = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
  
  @override
  void initState() {
    super.initState();
    
    // Inicializar con valores de la alarma existente o valores predeterminados
    if (widget.alarm != null) {
      _selectedTime = TimeOfDay(
        hour: widget.alarm!.time.hour,
        minute: widget.alarm!.time.minute,
      );
      _selectedDays = List.from(widget.alarm!.days);
      _labelController = TextEditingController(text: widget.alarm!.label);
      _selectedDifficulty = widget.alarm!.mathProblemDifficulty;
    } else {
      _selectedTime = TimeOfDay.now();
      _selectedDays = List.filled(7, false);
      _labelController = TextEditingController();
      _selectedDifficulty = 1;
    }
  }
  
  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }
  
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }
  
  void _saveAlarm() {
    // Verificar que al menos un día esté seleccionado
    if (!_selectedDays.contains(true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona al menos un día de la semana'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final now = DateTime.now();
    final alarmTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    
    final alarmProvider = Provider.of<AlarmProvider>(context, listen: false);
    final notificationService = Provider.of<NotificationService>(context, listen: false);
    
    if (widget.alarm == null) {
      // Crear nueva alarma
      final newAlarm = Alarm(
        id: DateTime.now().millisecondsSinceEpoch,
        time: alarmTime,
        days: _selectedDays,
        isActive: true,
        label: _labelController.text,
        mathProblemDifficulty: _selectedDifficulty,
      );
      
      alarmProvider.addAlarm(newAlarm);
      notificationService.scheduleAlarm(newAlarm);
    } else {
      // Actualizar alarma existente
      final updatedAlarm = widget.alarm!.copyWith(
        time: alarmTime,
        days: _selectedDays,
        label: _labelController.text,
        mathProblemDifficulty: _selectedDifficulty,
      );
      
      alarmProvider.updateAlarm(updatedAlarm);
      notificationService.scheduleAlarm(updatedAlarm);
    }
    
    Navigator.of(context).pop();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.alarm == null ? 'Nueva Alarma' : 'Editar Alarma'),
        actions: [
          if (widget.alarm != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                Provider.of<AlarmProvider>(context, listen: false)
                    .deleteAlarm(widget.alarm!.id);
                Provider.of<NotificationService>(context, listen: false)
                    .cancelAlarm(widget.alarm!.id);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selector de hora
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Hora',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _selectTime(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        alignment: Alignment.center,
                        child: Text(
                          _selectedTime.format(context),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Selector de días
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Repetir',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(7, (index) {
                        return DaySelector(
                          day: _daysOfWeek[index],
                          isSelected: _selectedDays[index],
                          onTap: () {
                            setState(() {
                              _selectedDays[index] = !_selectedDays[index];
                            });
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Campo de etiqueta
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Etiqueta',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _labelController,
                      decoration: const InputDecoration(
                        hintText: 'Opcional',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Selector de dificultad
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dificultad del Problema Matemático',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment<int>(
                          value: 1,
                          label: Text('Fácil'),
                        ),
                        ButtonSegment<int>(
                          value: 2,
                          label: Text('Media'),
                        ),
                        ButtonSegment<int>(
                          value: 3,
                          label: Text('Difícil'),
                        ),
                      ],
                      selected: {_selectedDifficulty},
                      onSelectionChanged: (Set<int> newSelection) {
                        setState(() {
                          _selectedDifficulty = newSelection.first;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveAlarm,
        icon: const Icon(Icons.save),
        label: const Text('Guardar'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class DaySelector extends StatelessWidget {
  final String day;
  final bool isSelected;
  final VoidCallback onTap;

  const DaySelector({
    Key? key,
    required this.day,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: CircleAvatar(
        radius: 20,
        backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
        child: Text(
          day,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}