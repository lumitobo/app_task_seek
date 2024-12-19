import 'dart:io';
import 'package:app_task_seek/domain/datasources/local_db_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:app_task_seek/infrastructure/datasources/isar_datasource_impl.dart';
import 'package:isar/isar.dart';
import 'package:app_task_seek/domain/entities/task.dart';

import 'local_db_repository_impl_test.mocks.dart';

@GenerateMocks([DirectoryProvider, IsarFactory, Isar, IsarCollection<Task>, QueryBuilder<Task, Task, QWhere>])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalDBDatasource sessionsRepository;
  final mockDirectoryProvider = MockDirectoryProvider();
  final mockIsarFactory = MockIsarFactory();

  late Directory tempDirectory;
  late Isar isar;

  setUpAll(() async {
    tempDirectory = await Directory.systemTemp.createTemp('isar_test');
    final directoryPath = tempDirectory.path;

    await Isar.initializeIsarCore(download: true);

    isar = await Isar.open([TaskSchema], directory: directoryPath);

    when(mockDirectoryProvider.getDirectoryPath()).thenAnswer((_) async => directoryPath);
    when(mockIsarFactory.createIsar(directoryPath)).thenAnswer((_) async => isar);
  });

  tearDownAll(() async {
    if (isar.isOpen) {
      await isar.close();
    }
    if (tempDirectory.existsSync()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  setUp(() async {
    sessionsRepository = IsarDatasourceImpl(
      directoryProvider: mockDirectoryProvider,
      isarFactory: mockIsarFactory,
    );
  });

  group('getTasks -', () {

    setUp(() async {
      await isar.writeTxn(() async {
        await isar.tasks.clear();
      });
    });

    test('should add a new task if it does not exist', () async {
      final task = Task(id: '1', title: 'New Task', category: 'Test Description');

      await isar.writeTxn(() async => isar.tasks.put(task));

      final result = await isar.tasks.filter().idEqualTo(task.id).findFirst();
      expect(result, isNotNull);
      expect(result?.title, task.title);
    });

    test('should not add a task if it already exists', () async {
      final task = Task(id: "2", title: 'Existing Task', category: 'Existing Description');

      await isar.writeTxn(() async => isar.tasks.put(task));

      final tasks = await isar.tasks.filter().idEqualTo(task.id).findAll();
      expect(tasks.length, 1);
      expect(tasks.first.title, task.title);
    });

    test('get all task', () async {

      final mockTasks = [
        Task(id: "1", title: 'Task 1', category: 'Description 1'),
        Task(id: "2", title: 'Task 2', category: 'Description 2'),
      ];

      await isar.writeTxn(() async {
        await isar.tasks.putAll(mockTasks);
      });

      final result = await sessionsRepository.getTasks();

      expect(result, isNotEmpty);
      expect(result.length, mockTasks.length);
    });

    test('should edit an existing task', () async {
      final task = Task(id: '1', title: 'Old Task', category: 'Old Description');
      await isar.writeTxn(() async => isar.tasks.put(task));

      final updatedTask = task.copyWith(title: 'Updated Task', category: 'Updated Description');
      await isar.writeTxn(() async {
        await isar.tasks.put(updatedTask);
      });

      final result = await isar.tasks.filter().idEqualTo(updatedTask.id).findFirst();

      expect(result, isNotNull);
      expect(result?.title, updatedTask.title);
      expect(result?.category, updatedTask.category);
    });

    test('should remove an existing task', () async {
      final task = Task(id: '1', title: 'Task to Delete', category: 'Description to Delete');
      await isar.writeTxn(() async => isar.tasks.put(task));

      final addedTask = await isar.tasks.filter().idEqualTo(task.id).findFirst();
      expect(addedTask, isNotNull);

      final result = await sessionsRepository.removeTask(task);

      final deletedTask = await isar.tasks.filter().idEqualTo(task.id).findFirst();
      expect(deletedTask, isNull);
      expect(result, isTrue);
    });

    test('should return false when trying to remove a non-existent task', () async {
      final task = Task(id: 'non_existent_id', title: 'Non-existent Task', category: 'Non-existent Category');
      final result = await sessionsRepository.removeTask(task);

      expect(result, isFalse);
    });


  });
}
