import 'package:flutter/material.dart';
import 'package:namer_app/front/utils/android/basescaffold.dart';
import 'projects_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class HomeScreen extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> projects = [];


 @override
  void initState() {
    super.initState();
    _loadProjects();
  }

// Método para cargar proyectos desde Firestore
  Future<void> _loadProjects() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('proyectos')
          .get();

      setState(() {
        projects = snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'nombre': doc['nombre'] ?? 'Sin Nombre',
                })
            .toList();
      });
    } catch (e) {
      print("Error al cargar proyectos: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: "Pantalla Principal",
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bienvenido Otra Vez!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text("User", style: TextStyle(fontSize: 16)),
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
                itemCount: projects.length, // Número de tarjetas
                itemBuilder: (context, index) {
                  final project = projects[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProjectScreen(
                              projectId: project['id'],
                            )
                            ),
                      );
                    },
                    child:Container(
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
