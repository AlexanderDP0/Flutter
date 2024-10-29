import 'package:flutter/material.dart';
import 'package:namer_app/projects_screen.dart';
import 'login_screen.dart'; // Nueva pantalla de inicio de sesión
import 'home_screen.dart'; // Nueva pantalla principal
import 'projects_screen.dart';
// import 'package:provider/provider.dart'; // Comentado por ahora

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // return ChangeNotifierProvider(
    //   create: (context) => MyAppState(),  // Comentado por ahora
    //   child: MaterialApp(
    return MaterialApp(
      title: 'Namer App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      initialRoute: '/', // Define la ruta inicial
      routes: {
        '/': (context) => LoginScreen(), // Pantalla de inicio de sesión
        '/home': (context) => HomeScreen(), // Pantalla principal
        '/projects': (context) => ProjectScreen() // Pantalla de proyectos
      },
    );
  }
}

// class MyAppState extends ChangeNotifier {   // Comentado por ahora
//   var current = WordPair.random();
// }
