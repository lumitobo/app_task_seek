import 'package:app_task_seek/config/router/app_router.dart';
import 'package:app_task_seek/presentation/screens/task_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
                itemCount: taskState.filteredTasks.length,
                itemBuilder: (context, index) {
                  final task = taskState.tasks[index];
                  return TaskItem(task: task);
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
}
