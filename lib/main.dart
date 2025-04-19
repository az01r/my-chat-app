import 'package:chat_app/screens/auth.dart';
import 'package:chat_app/screens/index.dart';
import 'package:chat_app/screens/splash.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chat App',
      theme: ThemeData().copyWith(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 59, 43, 28)),
      ),
      home: StreamBuilder(
        stream: authService.authStateChanges,
        initialData: authService.currentState,
        builder: (ctx, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }
          if (authSnapshot.hasData && authSnapshot.data!.isAuthenticated) {
            return const IndexScreen();
          }
          return const AuthScreen();
        },
      ),
    );
  }
}
