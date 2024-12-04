import 'package:flutter/material.dart';
import 'package:namer_app/front/utils/android/basescaffold.dart';
import 'projects_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  final String userId;

  HomeScreen({required this.userId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> projects = [];
  String userName = ""; // Nombre del usuario por defecto

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Método para cargar datos del usuario (nombre y proyectos) desde Firestore
  Future<void> _loadUserData() async {
    try {
      // Obtén el documento del usuario
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      // Verifica si el documento existe y extrae el nombre y los IDs de proyectos
      if (userDoc.exists) {
        List<dynamic> userProjectIds = userDoc['proyectos'] ?? [];
        String name = userDoc['name'] ?? 'Usuario';

        // Filtra los proyectos que coincidan con los IDs del usuario
        QuerySnapshot projectSnapshot = await FirebaseFirestore.instance
            .collection('proyectos')
            .where(FieldPath.documentId, whereIn: userProjectIds)
            .get();

        // Actualiza el estado con los datos cargados
        setState(() {
          userName = name;
          projects = projectSnapshot.docs
              .map((doc) => {
                    'id': doc.id,
                    'nombre': doc['nombre'] ?? 'Sin Nombre',
                  })
              .toList();
        });
      }
    } catch (e) {
      print("Error al cargar datos del usuario: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: "Inicio",
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bienvenido Otra Vez, $userName!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              "Proyectos",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: projects.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: 3 / 4,
                      ),
                      itemCount: projects.length,
                      itemBuilder: (context, index) {
                        final project = projects[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProjectScreen(
                                  projectId: project['id'],
                                  userName: userName,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(8.0),
                            color: Colors.grey[300],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  project['nombre'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
