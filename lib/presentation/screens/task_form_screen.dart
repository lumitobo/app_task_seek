import 'package:app_task_seek/config/router/app_router.dart';
import 'package:app_task_seek/presentation/shared/widgets/custom_filled_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/task.dart';
import '../providers/task_provider.dart';

class TaskFormScreen extends ConsumerStatefulWidget {
  final Task? task;
  const TaskFormScreen({super.key, this.task});

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  late TextEditingController _titleController;
  late TextEditingController _categoryController;
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();

    if (widget.task != null) {
      _isEditing = true;
      _titleController = TextEditingController(text: widget.task!.title);
      _categoryController = TextEditingController(text: widget.task!.category);
    } else {
      _titleController = TextEditingController();
      _categoryController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskNotifier = ref.read(taskProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Tarea' : 'Añadir tarea'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Titulo'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un titulo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Categoría'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese una categoría';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomFilledButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    if (_isEditing) {
                      taskNotifier.editTask(
                        widget.task!,
                        _titleController.text,
                        _categoryController.text,
                      );
                    } else {
                      taskNotifier.addTask(
                        _titleController.text,
                        _categoryController.text,
                      );
                    }
                    context.pop();
                  }
                },
                text: _isEditing ? 'Guardar Cambios' : 'Añadir Tarea',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
