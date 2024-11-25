import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:namer_app/front/utils/android/drawer.dart'; // Asegúrate de que la ruta sea correcta

class BaseScaffold extends StatelessWidget {
  final Widget body;
  final String title;

  BaseScaffold({required this.body, required this.title});

  @override
  Widget build(BuildContext context) {
    // Detectar si el dispositivo es de escritorio o web
    bool isDesktop =
        kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;

    return Scaffold(
      appBar: isDesktop
          ? null
          : AppBar(title: Text(title)), // Quita el AppBar en escritorio
      drawer: isDesktop ? null : AppSideNav(), // Drawer para móviles
      body: Row(
        children: [
          if (isDesktop) AppSideNav(), // SideNav fijo para escritorio
          Expanded(child: body), // Cuerpo principal de la pantalla
        ],
      ),
    );
  }
}
