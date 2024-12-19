import 'package:go_router/go_router.dart';

import '../../domain/entities/task.dart';
import '../../presentation/screens/task_form_screen.dart';
import '../../presentation/screens/task_list_screen.dart';


final appRouter = GoRouter(
    initialLocation: '/',
    routes: [

      GoRoute(
        path: '/',
        builder: (context, state) => const TaskListScreen(),
      ),
      GoRoute(
        path: '/add-task',
        builder: (context, state) => const TaskFormScreen(),
      ),
      GoRoute(path: '/crear-oferta',
        builder: (context, state) {
          final Task? obj = state.extra != null ? state.extra as Task : null;
          return TaskFormScreen(task: obj);
        },
      ),
    ]
);