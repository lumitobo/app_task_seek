
import 'package:app_task_seek/domain/datasources/local_db_datasource.dart';
import 'package:app_task_seek/domain/entities/task.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';


class IsarDatasourceImpl extends LocalDBDatasource {

  late Future<Isar> isarDB;

  IsarDatasourceImpl(){
    isarDB = openDB();
  }

  Future<Isar> openDB() async {

    final dir = await getApplicationDocumentsDirectory();
    if (Isar.instanceNames.isEmpty) {
      return await Isar.open( [ TaskSchema ], inspector: true, directory: dir.path);
    }

    return Future.value(Isar.getInstance());
  }

  @override
  Future<void> addTask(Task task) async{
    final isar = await isarDB;

    final existTask = await isar.tasks.filter().idEqualTo(task.id).findFirst();

    if(existTask == null){
      isar.writeTxn(() async => isar.tasks.put(task));
    }
    else {
      // TODO: desarrollar cuando el id de la tarea que se quiere agregar ya se encuentre en la base de datos
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
  Future<List<Task>> getTasks({int limit = 10, offset = 0}) async {
    final isar = await isarDB;
    return isar.tasks.where().offset(offset).limit(limit).findAll();
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