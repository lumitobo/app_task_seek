import 'package:app_task_seek/domain/repositories/local_db_repository.dart';
import 'package:app_task_seek/infrastructure/datasources/isar_datasource_impl.dart';
import 'package:app_task_seek/infrastructure/repositories/local_db_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task.dart';

enum TaskFilter { all, completed, pending }

class TaskState {
  final List<Task> tasks;
  final TaskFilter filter;
  final bool isLoading;
  final bool isSaving;

  TaskState({
    required this.tasks,
    required this.filter,
    this.isLoading = true,
    this.isSaving = false,
  });

  TaskState copyWith({
    List<Task>? tasks,
    TaskFilter? filter,
    bool? isLoading,
    bool? isSaving,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
    );
  }

}

class TaskNotifier extends StateNotifier<TaskState> {

  final LocalDbRepository localDBRepository;

  TaskNotifier({
    required this.localDBRepository
  }) : super(TaskState(tasks: [], filter: TaskFilter.all)){
    loadAllTasks();
  }

  Future<void> loadAllTasks() async {

    try {

      final List<Task> tasks = await localDBRepository.getTasks();

      state = state.copyWith(isLoading: false, tasks: tasks);

    } catch (e) {
      print(e);
    }

  }

  void setFilter(TaskFilter filter) {
    state = state.copyWith(filter: filter);
  }

  void addTask(String title, String category) async {
    final newTask = Task(
      id: DateTime.now().toString(),
      title: title,
      category: category,
    );

    try {

      await localDBRepository.addTask(newTask);
      state = state.copyWith(tasks: [...state.tasks, newTask]);


    } catch (e) {
      print(e);
    }

  }

  void editTaskRepository (Task task) async {
    try {
      await localDBRepository.editTask(task);
      loadAllTasks();

    } catch (e) {
      print(e);
    }
  }

  void toggleTaskStatus(Task task) async {

    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    editTaskRepository(updatedTask);

    state = state.copyWith(
      tasks: [...state.tasks], // Esto forza la actualización del estado de las tareas
      filter: state.filter, // Mantén el filtro actual
    );
  }

  void editTask(Task task, String newTitle, String newCategory) async{

    final updatedTask = task.copyWith(title: newTitle, category: newCategory);
    editTaskRepository(updatedTask);

  }

  void deleteTask(Task task) async {

    try {

      bool deletedTask = await localDBRepository.removeTask(task);

      if(deletedTask){
        loadAllTasks();
      }

    } catch (e) {
      print(e);
    }

  }
}

final taskProvider = StateNotifierProvider<TaskNotifier, TaskState>((ref) {
  final localDBRepository = LocalDBRepositoryImpl(IsarDatasourceImpl(
    directoryProvider: DefaultDirectoryProvider(),
    isarFactory: DefaultIsarFactory(),
  ));

  return TaskNotifier(localDBRepository: localDBRepository);
});
