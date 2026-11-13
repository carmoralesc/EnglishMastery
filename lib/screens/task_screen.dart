import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/task_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

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

    if (isCorrect) {
      final authService = context.read<AuthService>();
      final firestoreService = context.read<FirestoreService>();
      final uid = authService.currentUser?.uid;

      if (uid != null) {
        try {
          await firestoreService.addXpToUser(uid, widget.task.xpReward);
        } catch (e) {
          debugPrint('Error guardando XP: $e');
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('No se pudo guardar el XP (offline).')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final prompt = widget.task.contentJson['prompt'] as String? ??
        widget.task.contentJson['passage'] as String? ??
        widget.task.contentJson['promptText'] as String? ??
        'Realiza la siguiente tarea:';

    final options = widget.task.contentJson['options'] as List<dynamic>?;

    return Scaffold(
      appBar: AppBar(title: Text(widget.task.title)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(prompt, style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 24),
            if (options != null) ...<Widget>[
              const Text(
                'Selecciona la respuesta correcta:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                // AbsorbPointer bloquea los clics cuando ya se comprobó la respuesta
                child: AbsorbPointer(
                  absorbing: _isChecked,
                  child: RadioGroup<int>(
                    groupValue: _selectedOptionIndex,
                    onChanged: (int? value) {
                      setState(() => _selectedOptionIndex = value);
                    },
                    child: ListView.builder(
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final optionText = options[index].toString();
                        final isSelected = _selectedOptionIndex == index;
                        Color? tileColor;
                        if (_isChecked) {
                          final correctIndex =
                              widget.task.contentJson['correctIndex'] as int?;
                          if (index == correctIndex) {
                            tileColor = Colors.green.withValues(alpha: 0.2);
                          } else if (isSelected && !_isCorrect) {
                            tileColor = Colors.red.withValues(alpha: 0.2);
                          }
                        }
                        return Card(
                          color: tileColor,
                          elevation: isSelected ? 4 : 1,
                          child: RadioListTile<int>(
                            value: index,
                            title: Text(optionText),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ] else ...<Widget>[
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
            FilledButton(
              onPressed: _isChecked
                  ? () => context.pop()
                  : (options != null ? _checkAnswer : () => context.pop()),
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
