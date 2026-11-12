// Modelo puro Dart: no importa Flutter ni cloud_firestore.
// id = doc ID de Firestore; no se incluye en toMap.
// languageCode: idioma del contenido. Fallback 'en'. Permite
// reutilizar la estructura para ruso, portugués, turco, etc.
// sin cambiar código.

class LevelModel {
  final String id;

  /// Código ISO 639-1 del idioma del contenido (ej. 'en', 'ru', 'pt').
  final String languageCode;

  final int order;
  final String title;
  final String description;

  /// Estado de bloqueo explícito. En Fase 5+ podría derivarse de
  /// user.currentLevelId vs level.order; por ahora lo controla el seed.
  final bool isLocked;

  /// Denormalizado: suma de tasks de todas las sesiones del nivel.
  /// Lo calcula y mantiene el seed script.
  final int totalTasks;

  /// Nombre lógico del ícono (ej. "rocket_launch", "school").
  /// El mapeo a IconData vive en la capa UI.
  final String iconName;

  const LevelModel({
    required this.id,
    required this.languageCode,
    required this.order,
    required this.title,
    required this.description,
    required this.isLocked,
    required this.totalTasks,
    required this.iconName,
  });

  factory LevelModel.fromMap(String id, Map<String, dynamic> map) {
    return LevelModel(
      id: id,
      languageCode: (map['languageCode'] as String?) ?? 'en',
      order: (map['order'] as num?)?.toInt() ?? 0,
      title: (map['title'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      isLocked: (map['isLocked'] as bool?) ?? false,
      totalTasks: (map['totalTasks'] as num?)?.toInt() ?? 0,
      iconName: (map['iconName'] as String?) ?? 'school',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'languageCode': languageCode,
      'order': order,
      'title': title,
      'description': description,
      'isLocked': isLocked,
      'totalTasks': totalTasks,
      'iconName': iconName,
    };
  }
}
