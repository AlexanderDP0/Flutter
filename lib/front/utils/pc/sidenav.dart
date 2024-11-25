import 'package:flutter/material.dart';
import 'package:namer_app/front/pages/pc/projects_screen.dart';
import 'package:namer_app/front/pages/pc/projects_list.dart';

class SideNav extends StatelessWidget {
  const SideNav({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200, // Ancho máximo del menú lateral en pantallas grandes
      color: Colors.blueGrey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Create Project'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProjectScreenPC()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Projects'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProjectList()),
              );
            },
          ),
        ],
      ),
    );
  }
}
