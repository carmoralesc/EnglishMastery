import 'package:flutter_test/flutter_test.dart';
import 'package:english_master_academy/models/level_model.dart';
import 'package:english_master_academy/models/session_model.dart';
import 'package:english_master_academy/models/task_model.dart';

void main() {
  group('LevelModel Tests', () {
    test('fromMap debe parsear todos los campos correctamente', () {
      final map = {
        'languageCode': 'en',
        'order': 1,
        'title': 'Nivel 1',
        'description': 'Desc',
        'isLocked': false,
        'totalTasks': 10,
        'iconName': 'rocket_launch',
        'requiredXp': 100,
      };

      final level = LevelModel.fromMap('level_1', map);

      expect(level.id, 'level_1');
      expect(level.title, 'Nivel 1');
      expect(level.requiredXp, 100);
      expect(level.isLocked, false);
    });

    test('fromMap debe usar valores por defecto si faltan campos', () {
      final level = LevelModel.fromMap('level_2', {});

      expect(level.languageCode, 'en');
      expect(level.title, '');
      expect(level.requiredXp, 0); // Vital para el desbloqueo
      expect(level.iconName, 'school');
    });

    test('toMap debe devolver el mapa correcto', () {
      const level = LevelModel(
        id: 'level_3',
        languageCode: 'en',
        order: 3,
        title: 'Nivel 3',
        description: 'Desc 3',
        isLocked: true,
        totalTasks: 5,
        iconName: 'star',
        requiredXp: 250,
      );

      final map = level.toMap();

      expect(map['title'], 'Nivel 3');
      expect(map['requiredXp'], 250);
      expect(map['isLocked'], true);
    });
  });

  group('SessionModel Tests', () {
    test('fromMap debe parsear correctamente incluyendo DifficultyTier', () {
      final map = {
        'levelId': 'level_1',
        'order': 1,
        'title': 'Sesión 1',
        'description': 'Desc',
        'difficultyTier': 'basic',
        'taskIds': ['task_1', 'task_2'],
      };

      final session = SessionModel.fromMap('session_1', map);

      expect(session.title, 'Sesión 1');
      expect(session.difficultyTier, DifficultyTier.basic);
      expect(session.taskIds.length, 2);
      expect(session.taskIds.first, 'task_1');
    });

    test('fromMap debe manejar DifficultyTier desconocido o nulo', () {
      final session1 =
          SessionModel.fromMap('s1', {'difficultyTier': 'super_hard'});
      final session2 = SessionModel.fromMap('s2', {});

      expect(session1.difficultyTier, DifficultyTier.unknown);
      expect(session2.difficultyTier, isNull);
    });
  });

  group('TaskModel Tests', () {
    test('fromMap debe parsear TaskType y contentJson', () {
      final map = {
        'sessionId': 'session_1',
        'order': 1,
        'type': 'grammar',
        'title': 'Tarea 1',
        'xpReward': 50,
        'contentJson': {
          'prompt': 'Elige la opción correcta',
          'options': ['A', 'B', 'C'],
          'correctIndex': 1,
        },
      };

      final task = TaskModel.fromMap('task_1', map);

      expect(task.type, TaskType.grammar);
      expect(task.xpReward, 50);
      expect(task.contentJson['prompt'], 'Elige la opción correcta');
      expect(task.contentJson['correctIndex'], 1);
    });

    test('fromMap debe manejar TaskType desconocido y contentJson vacío', () {
      final task = TaskModel.fromMap('task_2', {'type': 'dancing'});

      expect(task.type, TaskType.unknown);
      expect(task.xpReward, 0);
      expect(task.contentJson, isEmpty);
    });

    test('Los getters de contentJson deben extraer los datos correctamente',
        () {
      final map = {
        'contentJson': {
          'videoId': 'abc123',
          'startSecond': 10,
          'endSecond': 20,
          'promptText': 'Repite esto',
          'durationSeconds': 30,
        }
      };

      final task = TaskModel.fromMap('task_3', map);

      expect(task.videoId, 'abc123');
      expect(task.startSecond, 10);
      expect(task.endSecond, 20);
      expect(task.promptText, 'Repite esto');
      expect(task.durationSeconds, 30);
    });
  });
}
