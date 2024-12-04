import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/pc/header.dart';
import '../../utils/pc/sidenav.dart';
import 'package:intl/intl.dart'; // Para formatear fechas

class ProjectList extends StatelessWidget {
  const ProjectList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MediaQuery.of(context).size.width < 600
          ? Drawer(child: const SideNav())
          : null,
      body: Column(
        children: [
          const Header(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool isWideScreen = constraints.maxWidth > 600;
                return Row(
                  children: [
                    if (isWideScreen) const SideNav(),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Proyectos',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                  ),
                                  child: Text('Create'),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Expanded(
                              child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('proyectos')
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                    return Center(
                                      child: Text('No projects found.'),
                                    );
                                  }
                                  final projects = snapshot.data!.docs;
                                  return GridView.builder(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: isWideScreen ? 3 : 1,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      childAspectRatio: 1.5,
                                    ),
                                    itemCount: projects.length,
                                    itemBuilder: (context, index) {
                                      final project = projects[index].data() as Map<String, dynamic>;
                                      return ProjectCard(project: project, projectId: projects[index].id);
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProjectCard extends StatefulWidget {
  final Map<String, dynamic> project;
  final String projectId;

  const ProjectCard({Key? key, required this.project, required this.projectId}) : super(key: key);

  @override
  _ProjectCardState createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  @override
  Widget build(BuildContext context) {
    double progreso = (widget.project['progreso'] ?? 0.0).toDouble();
    
    return GestureDetector(
      onTap: () => _showCommentsModal(context),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.project['nombre'] ?? 'Unnamed Project',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.open_in_full),
                ],
              ),
              SizedBox(height: 10),
              Text(
                widget.project['descripcion'] ?? 'No description available.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.redAccent),
                  SizedBox(width: 5),
                  Text(
                    '${widget.project['fechaInicio'] ?? 'No start date'} - ${widget.project['fechaFin'] ?? 'No end date'}',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ],
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _showActivitiesModal(context);
                },
                child: Text('Ver Actividades'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),SizedBox(height: 10),
              // Mostrar progreso en grande
              Center(
                child: Text(
                  '${progreso.toStringAsFixed(1)}%', // Mostrar el progreso como porcentaje
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _showCommentsModal(BuildContext context) {
    final comments = widget.project['comentarios'] as List<dynamic>? ?? [];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Comentarios de ${widget.project['nombre'] ?? 'Project'}'),
          content: comments.isEmpty
              ? Text('No comments available.')
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index] as Map<String, dynamic>;
                      final user = comment['usuario'] ?? 'Unknown User';
                      final text = comment['comentario'] ?? 'No comment';
                      final timestamp = comment['fecha'] as Timestamp?;
                      final date = timestamp != null
                          ? DateFormat('yyyy-MM-dd HH:mm')
                              .format(timestamp.toDate())
                          : 'Unknown Date';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ListTile(
                          title: Text(user, style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('$text\n$date'),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showActivitiesModal(BuildContext context) {
    final activityController = TextEditingController();
    final firestore = FirebaseFirestore.instance;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Actividades de ${widget.project['nombre'] ?? 'Project'}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mostrar las actividades existentes en el proyecto
                if (widget.project['actividades'] != null && (widget.project['actividades'] as List).isNotEmpty)
                  ...((widget.project['actividades'] as List).map((activity) {
                    if (activity is String) {
                    // Si la actividad es una cadena, mostrarla como texto
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        activity,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    );
                  } else if (activity is Map<String, dynamic>) {
                    // Si la actividad es un mapa, acceder al nombre y mostrarlo
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        activity['nombre'] ?? 'Actividad sin nombre',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    );
                  }
                  return SizedBox(); // Si no es ni String ni Map, no hacer nada
                  }).toList()),
                // Si no hay actividades, mostrar un mensaje
                if (widget.project['actividades'] == null || (widget.project['actividades'] as List).isEmpty)
                  Text('No activities yet', style: TextStyle(fontSize: 14, color: Colors.grey)),
                // Formulario para agregar nueva actividad
                TextField(
                  controller: activityController,
                  decoration: InputDecoration(hintText: 'Escribe una nueva actividad'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                String activity = activityController.text.trim();
                if (activity.isNotEmpty) {
                  await firestore.collection('proyectos').doc(widget.projectId).update({
                    'actividades': FieldValue.arrayUnion([activity]),
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Agregar'),
            ),
          ],
        );
      },
    );
  }
}
