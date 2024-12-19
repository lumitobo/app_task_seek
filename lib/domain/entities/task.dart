
import 'package:isar/isar.dart';
part 'task.g.dart';

@collection
class Task {
  Id? isarId;

  final String id;
  final String title;
  final String category;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.category,
    this.isCompleted = false,
    this.isarId
  });

  Task copyWith({
    String? id,
    String? title,
    String? category,
    bool? isCompleted,
    Id? isarId
  }) {
    return Task(
      isarId: isarId ?? this.isarId,
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
