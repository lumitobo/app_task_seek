import 'package:app_task_seek/config/router/app_router.dart';
import 'package:app_task_seek/presentation/screens/task_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/task.dart';
import '../providers/task_provider.dart';
import '../shared/widgets/elevation_button.dart';
import '../shared/widgets/task_item.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskNotifier = ref.read(taskProvider.notifier);
    final taskState = ref.watch(taskProvider);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Lista de Tareas'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  FilterButton(
                    label: 'Todas',
                    isSelected: taskState.filter == TaskFilter.all,
                    onPressed: () => taskNotifier.setFilter(TaskFilter.all),
                  ),
                  const SizedBox(width: 10),
                  FilterButton(
                    label: 'Completadas',
                    isSelected: taskState.filter == TaskFilter.completed,
                    onPressed: () => taskNotifier.setFilter(TaskFilter.completed),
                  ),
                  const SizedBox(width: 10),
                  FilterButton(
                    label: 'Pendientes',
                    isSelected: taskState.filter == TaskFilter.pending,
                    onPressed: () => taskNotifier.setFilter(TaskFilter.pending),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: taskState.tasks.length,
                itemBuilder: (context, index) {
                  final task = taskState.tasks[index];
                  if (_shouldShowTask(task, taskState.filter)) {
                    return TaskItem(task: task);
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            context.push("/add-task");
          },
          label: const Text(
            'Añadir tarea',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          icon: const Icon(Icons.add),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ));
  }

  bool _shouldShowTask(Task task, TaskFilter filter) {
    switch (filter) {
      case TaskFilter.completed:
        return task.isCompleted;
      case TaskFilter.pending:
        return !task.isCompleted;
      case TaskFilter.all:
      default:
        return true;
    }
  }
}
