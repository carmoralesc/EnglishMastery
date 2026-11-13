import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'models/task_model.dart';
import 'screens/home_screen.dart';
import 'screens/level_detail_screen.dart';
import 'screens/login_screen.dart';
import 'screens/path_screen.dart';
import 'screens/session_detail_screen.dart';
import 'screens/task_screen.dart';

/// Notifica a go_router cuando el estado de autenticación cambia
/// (login, logout, token refresh). Al cambiar, go_router reevalúa `redirect`.
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier() {
    _subscription = FirebaseAuth.instance.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<User?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  refreshListenable: _AuthChangeNotifier(),
  debugLogDiagnostics: false,
  redirect: (BuildContext context, GoRouterState state) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final isOnLogin = state.matchedLocation == '/login';

    // No logueado fuera de /login → al login.
    if (!isLoggedIn && !isOnLogin) return '/login';

    // Logueado en /login → al home.
    if (isLoggedIn && isOnLogin) return '/home';

    // Cualquier otro caso: dejar pasar.
    return null;
  },
  routes: <RouteBase>[
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (BuildContext context, GoRouterState state) =>
          const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (BuildContext context, GoRouterState state) =>
          const HomeScreen(),
    ),
    GoRoute(
      path: '/path',
      name: 'path',
      builder: (BuildContext context, GoRouterState state) =>
          const PathScreen(),
    ),
    GoRoute(
      path: '/level/:id',
      name: 'level',
      builder: (BuildContext context, GoRouterState state) {
        final String levelId = state.pathParameters['id']!;
        final String levelTitle =
            state.extra is String ? state.extra as String : 'Nivel';
        return LevelDetailScreen(levelId: levelId, levelTitle: levelTitle);
      },
    ),
    GoRoute(
      path: '/session/:id',
      name: 'session',
      builder: (BuildContext context, GoRouterState state) {
        final String sessionId = state.pathParameters['id']!;
        final String sessionTitle =
            state.extra is String ? state.extra as String : 'Sesión';
        return SessionDetailScreen(
            sessionId: sessionId, sessionTitle: sessionTitle);
      },
    ),
    GoRoute(
      path: '/task/:id',
      name: 'task',
      builder: (BuildContext context, GoRouterState state) {
        final String taskId = state.pathParameters['id']!;
        final TaskModel? task =
            state.extra is TaskModel ? state.extra as TaskModel : null;
        if (task == null) {
          // Cold start sobre /task/:id (extra no persistido) o deep link inválido.
          return _TaskNotFoundScreen(taskId: taskId);
        }
        return TaskScreen(task: task);
      },
    ),
  ],
  errorBuilder: (BuildContext context, GoRouterState state) => Scaffold(
    appBar: AppBar(title: const Text('Ruta no encontrada')),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text('No se encontró la ruta: ${state.uri}'),
      ),
    ),
  ),
);

class _TaskNotFoundScreen extends StatelessWidget {
  final String taskId;

  const _TaskNotFoundScreen({required this.taskId});

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/path');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarea no disponible'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _goBack(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'No se pudo cargar la tarea.\nVuelve atrás e inténtalo de nuevo.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => _goBack(context),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
