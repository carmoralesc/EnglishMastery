import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_router.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const EnglishMasterAcademyApp());
}

class EnglishMasterAcademyApp extends StatelessWidget {
  const EnglishMasterAcademyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        Provider<AuthService>(
          create: (ctx) => AuthService(
            firestoreService: ctx.read<FirestoreService>(),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'English Master Academy',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E88E5),
          ),
          useMaterial3: true,
        ),
        routerConfig: appRouter,
      ),
    );
  }
}
