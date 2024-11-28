import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Asegúrate de instalar firebase_firestore y configurarlo
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
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
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
                                      return ProjectCard(project: project);
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

class ProjectCard extends StatelessWidget {
  final Map<String, dynamic> project;

  const ProjectCard({Key? key, required this.project}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                    project['nombre'] ?? 'Unnamed Project',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.open_in_new),
                ],
              ),
              SizedBox(height: 10),
              Text(
                project['descripcion'] ?? 'No description available.',
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
                    '${project['fechaInicio'] ?? 'No start date'} - ${project['fechaFin'] ?? 'No end date'}',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCommentsModal(BuildContext context) {
    final comments = project['comentarios'] as List<dynamic>? ?? [];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Comentarios de ${project['nombre'] ?? 'Project'}'),
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
}