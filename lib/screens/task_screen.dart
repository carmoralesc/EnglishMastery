import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

import '../models/task_model.dart';

class TaskScreen extends StatefulWidget {
  final TaskModel task;

  const TaskScreen({super.key, required this.task});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  int? _selectedOptionIndex;
  bool _isChecked = false;
  bool _isCorrect = false;

  Future<void> _checkAnswer() async {
    if (_selectedOptionIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona una opción.')),
      );
      return;
    }

    final correctIndex = widget.task.contentJson['correctIndex'] as int?;
    final isCorrect = _selectedOptionIndex == correctIndex;

    setState(() {
      _isChecked = true;
      _isCorrect = isCorrect;
    });

    // Si acertó, guardamos el XP en Firestore
    if (isCorrect) {
      final authService = context.read<AuthService>();
      final firestoreService = context.read<FirestoreService>();
      final uid = authService.currentUser?.uid;

      if (uid != null) {
        try {
          await firestoreService.addXpToUser(uid, widget.task.xpReward);
        } catch (e) {
          // Si falla Firestore, no bloqueamos al usuario, pero avisamos en consola
          debugPrint('Error guardando XP: $e');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('No se pudo guardar el XP (offline).')),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extraemos el contenido dinámico
    final prompt = widget.task.contentJson['prompt'] as String? ??
        widget.task.contentJson['passage'] as String? ??
        widget.task.contentJson['promptText'] as String? ??
        'Realiza la siguiente tarea:';

    // Si tiene 'options', asumimos que es de múltiple opción
    final options = widget.task.contentJson['options'] as List<dynamic>?;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instrucción o texto de lectura
            Card(
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  prompt,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Renderizado de opciones (si las hay)
            if (options != null) ...[
              const Text(
                'Selecciona la respuesta correcta:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final optionText = options[index].toString();
                    final isSelected = _selectedOptionIndex == index;

                    // Colores dinámicos basados en si ya se verificó la respuesta
                    Color? tileColor;
                    if (_isChecked) {
                      final correctIndex =
                          widget.task.contentJson['correctIndex'] as int?;
                      if (index == correctIndex) {
                        tileColor = Colors.green.withOpacity(0.2);
                      } else if (isSelected && !_isCorrect) {
                        tileColor = Colors.red.withOpacity(0.2);
                      }
                    }

                    return Card(
                      color: tileColor,
                      elevation: isSelected ? 4 : 1,
                      child: RadioListTile<int>(
                        title: Text(optionText),
                        value: index,
                        groupValue: _selectedOptionIndex,
                        onChanged: _isChecked
                            ? null
                            : (value) {
                                setState(() {
                                  _selectedOptionIndex = value;
                                });
                              },
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              // Placeholder para tareas sin opciones (speaking, writing, etc.)
              const Expanded(
                child: Center(
                  child: Text(
                    'Interfaz de tarea en construcción.\n(Próximamente audio/grabación)',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Botón de acción principal
            FilledButton(
              onPressed: _isChecked
                  ? () => Navigator.pop(context) // Salir al terminar
                  : (options != null
                      ? _checkAnswer
                      : () => Navigator.pop(context)),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                backgroundColor: _isChecked
                    ? (_isCorrect ? Colors.green : Colors.red)
                    : null,
              ),
              child: Text(
                _isChecked
                    ? (_isCorrect ? '¡Correcto! Volver' : 'Incorrecto. Volver')
                    : (options != null
                        ? 'Comprobar respuesta'
                        : 'Completar tarea'),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
