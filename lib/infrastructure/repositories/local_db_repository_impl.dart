

import 'package:app_task_seek/domain/datasources/local_db_datasource.dart';
import 'package:app_task_seek/domain/entities/task.dart';
import 'package:app_task_seek/domain/repositories/local_db_repository.dart';

class LocalDBRepositoryImpl extends LocalDbRepository {

  final LocalDBDatasource datasource;

  LocalDBRepositoryImpl(this.datasource);

  @override
  Future<void> addTask(Task task) {
    return datasource.addTask(task);
  }

  @override
  Future<void> editTask(Task task) {
    return datasource.editTask(task);
  }

  @override
  Future<List<Task>> getTasks({int limit = 10, offset = 0}) {
    return datasource.getTasks(limit: limit, offset: offset);
  }

  @override
  Future<bool> removeTask(Task task) {
    return datasource.removeTask(task);
  }
  
}