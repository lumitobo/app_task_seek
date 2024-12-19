
import 'package:app_task_seek/domain/datasources/local_db_datasource.dart';
import 'package:app_task_seek/domain/entities/task.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';


abstract class DirectoryProvider {
  Future<String> getDirectoryPath();
}

class DefaultDirectoryProvider implements DirectoryProvider {
  @override
  Future<String> getDirectoryPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }
}

/// Abstracción para crear la instancia de Isar
abstract class IsarFactory {
  Future<Isar> createIsar(String directoryPath);
}

class DefaultIsarFactory implements IsarFactory {
  @override
  Future<Isar> createIsar(String directoryPath) async {
    if (Isar.instanceNames.isEmpty) {
      return await Isar.open(
        [TaskSchema],
        inspector: true,
        directory: directoryPath,
      );
    }
    return Future.value(Isar.getInstance());
  }
}

class IsarDatasourceImpl extends LocalDBDatasource {
  final DirectoryProvider directoryProvider;
  final IsarFactory isarFactory;

  late Future<Isar> isarDB;

  IsarDatasourceImpl({
    required this.directoryProvider,
    required this.isarFactory,
  }) {
    isarDB = _initializeDB();
  }

  Future<Isar> _initializeDB() async {
    final directoryPath = await directoryProvider.getDirectoryPath();
    return await isarFactory.createIsar(directoryPath);
  }

  @override
  Future<List<Task>> getTasks({int limit = 10, offset = 0}) async {
    final isar = await isarDB;
    return isar.tasks.where().findAll();
  }

  @override
  Future<void> addTask(Task task) async{
    final isar = await isarDB;

    final existTask = await isar.tasks.filter().idEqualTo(task.id).findFirst();

    if(existTask == null){
      isar.writeTxn(() async => await isar.tasks.put(task));
    }

  }

  @override
  Future<void> editTask(Task task) async {
    final isar = await isarDB;

    final existingTask = await isar.tasks.filter().idEqualTo(task.id).findFirst();

    if (existingTask != null) {

      await isar.writeTxn(() async {
        await isar.tasks.put(task);
      });
    } else {
      throw Exception('Task with ID ${task.id} not found.');
    }
  }


  @override
  Future<bool> removeTask(Task task) async {
      final isar = await isarDB;

      final existTask = await isar.tasks.filter().idEqualTo(task.id).findFirst();

      if(existTask != null){
        isar.writeTxnSync(() => isar.tasks.deleteSync(task.isarId!));
        return true;
      }
      return false;
  }

}