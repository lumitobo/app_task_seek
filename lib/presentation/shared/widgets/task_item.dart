import 'package:app_task_seek/config/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_task_seek/domain/entities/task.dart';
import 'package:go_router/go_router.dart';

import '../../providers/task_provider.dart';
import '../../screens/task_form_screen.dart';

class TaskItem extends ConsumerWidget {
  final Task task;
  const TaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskNotifier = ref.read(taskProvider.notifier);
    return GestureDetector(
      onTap: () {
        context.push("/add-task", extra: task);
      },
      child: Card(
        child: ListTile(
          title: Text(
            task.title,
            style: TextStyle(decoration: task.isCompleted ? TextDecoration.lineThrough : null),
          ),
          subtitle: Text(task.category),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: task.isCompleted,
                onChanged: (value) {
                  taskNotifier.toggleTaskStatus(task);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                color: Colors.red,
                onPressed: () {
                  _confirmDelete(context, taskNotifier, task);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

void _confirmDelete(BuildContext context, TaskNotifier taskNotifier, Task task) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirmar eliminacion'),
        content: const Text('¿Estas seguro que deseas eliminar esta tarea?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              taskNotifier.deleteTask(task);
              Navigator.of(context).pop();
            },
            child: const Text('Eliminar'),
          )
        ],
      );
    },
  );
}
