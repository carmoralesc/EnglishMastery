class LevelModel {
  final String id;
  final String languageCode;
  final int order;
  final String title;
  final String description;
  final bool isLocked;
  final int totalTasks;
  final String iconName;
  final int requiredXp;

  const LevelModel({
    required this.id,
    required this.languageCode,
    required this.order,
    required this.title,
    required this.description,
    required this.isLocked,
    required this.totalTasks,
    required this.iconName,
    required this.requiredXp,
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
      requiredXp: (map['requiredXp'] as num?)?.toInt() ?? 0,
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
      'requiredXp': requiredXp,
    };
  }
}
