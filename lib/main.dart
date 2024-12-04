import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:namer_app/front/pages/android/projects_screen.dart';
import 'front/pages/android/login_screen.dart';
import 'front/pages/android/home_screen.dart';
import 'front/pages/pc/projects_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Archivo generado por Firebase CLI


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Usa las opciones para cada plataforma
  );
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  bool isDesktopPlatform() {
    return kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }

  @override
  Widget build(BuildContext context) {
    Widget initialScreen;

    if (isDesktopPlatform()) {
      initialScreen = ProjectScreenPC();
    } else {
      initialScreen = LoginScreen();
    }

    return MaterialApp(
      title: 'Namer App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      home: initialScreen,
      onGenerateRoute: (settings) {
        if (isDesktopPlatform()) {
          // Redirige todas las rutas a ProjectScreenPC si es plataforma de escritorio
          return MaterialPageRoute(builder: (context) => ProjectScreenPC());
        } else {
          // Permite las rutas normales en dispositivos móviles
          switch (settings.name) {
            case '/home':
              return MaterialPageRoute(builder: (context) => HomeScreen(userId: '',));
            case '/projects':
              return MaterialPageRoute(builder: (context) => ProjectScreen(projectId: '', userName: '',));
            default:
              return MaterialPageRoute(builder: (context) => LoginScreen());
          }
        }
      },
    );
  }
}
