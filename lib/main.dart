import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as ui;
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';
import 'package:hiking_app/screens/trails_list_screen.dart';
import 'package:hiking_app/screens/hike_logs_screen.dart';
import 'package:hiking_app/screens/hike_log_form_screen.dart';
import 'package:hiking_app/models/hike_log.dart';

/// Notifies GoRouter when the auth state changes.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;

    final router = GoRouter(
      initialLocation: '/',
      refreshListenable: GoRouterRefreshStream(auth.authStateChanges()),
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const HomeScreen(),
        ),
        GoRoute(
          path: '/sign-in',
          builder: (_, __) => ui.SignInScreen(
            providers: [ui.EmailAuthProvider()],
            actions: [
              ui.AuthStateChangeAction<ui.SignedIn>((ctx, state) {
                ctx.go('/');
              }),
            ],
          ),
        ),
        GoRoute(
          path: '/trails',
          builder: (_, __) => const TrailsListScreen(),
        ),
        GoRoute(
          path: '/logs',
          builder: (_, __) => const HikeLogsScreen(),
        ),
        GoRoute(
          path: '/logs/new',
          builder: (_, __) => const HikeLogFormScreen(),
        ),
        GoRoute(
          path: '/logs/:id/edit',
          builder: (ctx, state) {
            final log = state.extra as HikeLog;
            return HikeLogFormScreen(existing: log);
          },
        ),
      ],
      redirect: (context, state) {
        final loggedIn = auth.currentUser != null;
        final loggingIn = state.uri.toString() == '/sign-in';

        if (!loggedIn && !loggingIn) return '/sign-in';
        if (loggedIn && loggingIn) return '/';
        return null;
      },
    );

    return MaterialApp.router(
      title: 'NL Hikes',
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover & Log NL Hikes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.explore),
            tooltip: 'Browse Trails',
            onPressed: () => context.push('/trails'),
          ),
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'My Logs',
            onPressed: () => context.push('/logs'),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New Log',
            onPressed: () => context.push('/logs/new'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Welcome, ${user.email}!',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
