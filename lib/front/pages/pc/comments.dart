import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../utils/pc/header.dart'; // Importa el Header
import '../../utils/pc/sidenav.dart'; // Importa el SideNav

class CommentsList extends StatelessWidget {
  const CommentsList({Key? key, required String projectId}) : super(key: key);

  // Función para marcar un comentario como resuelto
  Future<void> _markAsResolved(BuildContext context, String projectId, String commentId) async {
    try {
      final projectDoc = FirebaseFirestore.instance.collection('proyectos').doc(projectId);
      final projectSnapshot = await projectDoc.get();

      if (projectSnapshot.exists) {
        final comentarios = List<Map<String, dynamic>>.from(projectSnapshot['comentarios'] ?? []);

        final commentIndex = comentarios.indexWhere((comment) => comment['commentId'] == commentId);

        if (commentIndex != -1) {
          // Si el comentario no tiene el campo 'resuelto', lo agregamos
          if (comentarios[commentIndex]['resuelto'] == null) {
            comentarios[commentIndex]['resuelto'] = true;
          }

          // Actualizar la base de datos con el nuevo campo 'resuelto'
          await projectDoc.update({
            'comentarios': comentarios,
          });

          // Mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Comentario marcado como resuelto')));
        }
      }
    } catch (e) {
      // Mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al marcar el comentario')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MediaQuery.of(context).size.width < 600
          ? Drawer(child: const SideNav())
          : null,
      body: Column(
        children: [
          const Header(), // Header en la parte superior
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
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('proyectos')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                              return const Center(
                                child: Text(
                                  'No hay comentarios disponibles.',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              );
                            }

                            final projects = snapshot.data!.docs;

                            // Recopilar todos los comentarios de todos los proyectos
                            List<Map<String, dynamic>> allComments = [];
                            for (var project in projects) {
                              final projectId = project.id;
                              final comments = List<Map<String, dynamic>>.from(project['comentarios'] ?? []);
                              for (var comment in comments) {
                                allComments.add({
                                  'projectId': projectId,
                                  'commentId': comment['commentId'],
                                  'usuario': comment['usuario'],
                                  'comentario': comment['comentario'],
                                  'fecha': comment['fecha'],
                                  'prioridad': comment['prioridad'],
                                  'resuelto': comment['resuelto'],
                                });
                              }
                            }

                            // Filtrar comentarios no resueltos
                            final unresolvedComments = allComments.where((comment) => comment['resuelto'] != true).toList();
                            final urgentComments = unresolvedComments
                                .where((comment) => (comment['prioridad'] ?? 'Normal') == 'Urgente')
                                .toList();
                            final regularComments = unresolvedComments
                                .where((comment) => (comment['prioridad'] ?? 'Normal') != 'Urgente')
                                .toList();

                            final displayComments = [...urgentComments, ...regularComments];

                            return ListView.builder(
                              itemCount: displayComments.length,
                              itemBuilder: (context, index) {
                                final comment = displayComments[index];
                                final user = comment['usuario'];
                                final text = comment['comentario'];
                                final timestamp = comment['fecha'] as Timestamp?;
                                final date = timestamp != null
                                    ? DateFormat('yyyy-MM-dd HH:mm').format(timestamp.toDate())
                                    : 'Fecha desconocida';
                                final isUrgent = (comment['prioridad'] ?? 'Normal') == 'Urgente';
                                final isResolved = comment['resuelto'] == true;
                                final projectId = comment['projectId'];
                                final commentId = comment['commentId'];

                                return Card(
                                  margin: const EdgeInsets.all(8.0),
                                  elevation: 4,
                                  shape: isUrgent
                                      ? RoundedRectangleBorder(
                                          side: BorderSide(color: Colors.red, width: 2))
                                      : null,
                                  child: ListTile(
                                    title: Text(
                                      user,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isUrgent ? Colors.red : Colors.black),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Comentario: $text'),
                                        Text('Fecha: $date'),
                                        if (isResolved)
                                          Text(
                                            'Comentario Resuelto',
                                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                          ),
                                      ],
                                    ),
                                    trailing: isResolved
                                        ? null
                                        : IconButton(
                                            icon: Icon(Icons.check, color: Colors.green),
                                            onPressed: () => _markAsResolved(context, projectId, commentId),
                                          ),
                                  ),
                                );
                              },
                            );
                          },
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
