import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alarm.dart';
import '../providers/alarm_provider.dart';
import '../services/notification_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class AlarmDetailScreen extends StatefulWidget {
  final Alarm? alarm;

  const AlarmDetailScreen({Key? key, this.alarm}) : super(key: key);

  @override
  State<AlarmDetailScreen> createState() => _AlarmDetailScreenState();
}

class _AlarmDetailScreenState extends State<AlarmDetailScreen> {
  late Alarm _currentAlarm;
  final _formKey = GlobalKey<FormState>();
  late TimeOfDay _selectedTime;
  late List<bool> _selectedDays;
  late TextEditingController _labelController;
  late int _selectedDifficulty;

  final List<String> _daysOfWeek = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  void initState() {
    super.initState();

    // Inicializar alarma con valores existentes o predeterminados
    _currentAlarm = widget.alarm?.copyWith() ??
        Alarm(
          id: DateTime.now().millisecondsSinceEpoch,
          time: DateTime.now(),
          days: List.filled(7, false),
        );

    // Inicializar controladores de UI con valores de la alarma
    _selectedTime = TimeOfDay(
      hour: _currentAlarm.time.hour,
      minute: _currentAlarm.time.minute,
    );
    _selectedDays = List.from(_currentAlarm.days);
    _labelController = TextEditingController(text: _currentAlarm.label);
    _selectedDifficulty = _currentAlarm.mathProblemDifficulty;
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

    // Usar _currentAlarm para guardar el customSoundUri
    final alarmToSave = (widget.alarm == null)
        ? Alarm(
            id: DateTime.now().millisecondsSinceEpoch,
            time: alarmTime,
            days: _selectedDays,
            isActive: true,
            label: _labelController.text,
            mathProblemDifficulty: _selectedDifficulty,
            customSoundUri: _currentAlarm.customSoundUri, // Añadir esto
          )
        : widget.alarm!.copyWith(
            time: alarmTime,
            days: _selectedDays,
            label: _labelController.text,
            mathProblemDifficulty: _selectedDifficulty,
            customSoundUri: _currentAlarm.customSoundUri, // Añadir esto
          );

    if (widget.alarm == null) {
      alarmProvider.addAlarm(alarmToSave);
    } else {
      alarmProvider.updateAlarm(alarmToSave);
    }
    notificationService.scheduleAlarm(alarmToSave);

    Navigator.of(context).pop();
  }

  // Mover este método dentro de la clase
  String _getFileName(String path) {
    return path.split('/').last;
  }

  // Mover este método dentro de la clase
  Future<void> _showSoundPicker(BuildContext context) async {
    if (Platform.isAndroid) {
      try {
        final FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.audio,
        );

        if (result != null && result.files.single.path != null) {
          // Usar setState para actualizar _currentAlarm
          setState(() {
            _currentAlarm = _currentAlarm.copyWith(
              customSoundUri: result.files.single.path!,
            );
          });

          // Usar mounted para verificar si el widget está montado
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Sonido seleccionado: ${_getFileName(result.files.single.path!)}')),
            );
          }
        }
      } catch (e) {
        // Usar mounted para verificar si el widget está montado
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al seleccionar sonido: $e')),
          );
        }
      }
    } else if (Platform.isIOS) {
      // Usar mounted para verificar si el widget está montado
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selección de sonidos personalizados no disponible en iOS')),
        );
      }
    }
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
            // Añadir esta sección en el formulario
            ListTile(
              title: const Text('Sonido de alarma'),
              subtitle: Text(_currentAlarm.customSoundUri != null
                  ? _getFileName(_currentAlarm.customSoundUri!)
                  : 'Sonido predeterminado'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showSoundPicker(context),
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
} // Fin de la clase _AlarmDetailScreenState

// La clase DaySelector permanece fuera como un widget separado
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