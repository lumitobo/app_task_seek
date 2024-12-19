
import '../entities/task.dart';

abstract class LocalDbRepository {

  Future<List<Task>> getTasks({ int limit = 10, offset = 0});
  Future<void> addTask( Task task );
  Future<void> editTask( Task task );
  Future<bool> removeTask( Task task );
  
}