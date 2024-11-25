import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:namer_app/front/pages/android/home_screen.dart';
import 'package:namer_app/front/pages/android/login_screen.dart';
import 'package:namer_app/front/pages/android/projects_screen.dart';
import 'package:namer_app/front/pages/pc/projects_screen.dart';

class AppSideNav extends StatelessWidget {
  const AppSideNav({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Detectar si es un dispositivo de escritorio o web
    bool isDesktop =
        kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;

    // Retorna el SideNav fijo en escritorio y el Drawer deslizable en móvil
    return isDesktop ? buildSideNav(context) : buildDrawer(context);
  }

  // Implementación del Drawer para dispositivos móviles
  Widget buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: _menuItems(context, isDesktop: false),
      ),
    );
  }

  // Implementación del SideNav para dispositivos de escritorio
  Widget buildSideNav(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.blue.shade50,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: _menuItems(context, isDesktop: true),
            ),
          ),
        ],
      ),
    );
  }

  // Genera los elementos del menú, dependiendo de si es escritorio o móvil
  List<Widget> _menuItems(BuildContext context, {required bool isDesktop}) {
    if (isDesktop) {
      // Solo muestra "Proyectos" en plataformas de escritorio
      return [
        buildMenuItem(context, Icons.work, 'Proyectos', ProjectScreenPC()),
      ];
    } else {
      // Muestra el menú completo en dispositivos móviles
      return [
        buildMenuItem(context, Icons.home, 'Inicio', HomeScreen()),
        buildMenuItem(context, Icons.work, 'Proyectos', ProjectScreen()),
        buildMenuItem(context, Icons.exit_to_app, 'Salir', LoginScreen()),
      ];
    }
  }

  // Método para construir cada elemento del menú
  Widget buildMenuItem(
      BuildContext context, IconData icon, String title, Widget screen) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
    );
  }
}
