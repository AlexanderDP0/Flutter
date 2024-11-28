import 'package:flutter/material.dart';
import 'package:namer_app/front/utils/android/basescaffold.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectScreen extends StatefulWidget {
  final String projectId; // Recibirás el ID del proyecto como argumento
  ProjectScreen({required this.projectId});

  @override
  _ProjectScreenState createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  bool _isEditing = false;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  // Variables para proyectos, materiales, herramientas y comentarios
  String projectName = "";
  String projectDescription = "";
  List<String> materials = [];
  List<Map<String, dynamic>> tools = [];
  List<Map<String, dynamic>> comments = [];
  List<bool> toolSelection = []; // Lista para el estado de los checkboxes

  @override
  void initState() {
    super.initState();
    _loadProjectData();
  }

  // Método para cargar los datos del proyecto desde Firestore
  Future<void> _loadProjectData() async {
    try {
      DocumentSnapshot projectSnapshot = await FirebaseFirestore.instance
          .collection('proyectos')
          .doc(widget.projectId)
          .get();

      if (projectSnapshot.exists) {
        setState(() {
          projectName = projectSnapshot['nombre'] ?? 'Nombre no disponible';
          projectDescription =
              projectSnapshot['descripcion'] ?? 'Descripción no disponible';
          _loadMaterials();
          _loadTools();
          comments = List<Map<String, dynamic>>.from(
              projectSnapshot['comentarios'] ?? []);
          _descriptionController.text = projectDescription;
        });
      }
    } catch (e) {
      print("Error al cargar el proyecto: $e");
    }
  }

  // Cargar materiales desde la colección de materiales
  Future<void> _loadMaterials() async {
    try {
      QuerySnapshot materialSnapshot = await FirebaseFirestore.instance
          .collection('materiales')
          //.where('proyectoId', isEqualTo: widget.projectId)
          .get();

      setState(() {
        materials = materialSnapshot.docs
            .map((doc) => doc['nombre'] as String)
            .toList();
      });
    } catch (e) {
      print("Error al cargar materiales: $e");
    }
  }

  // Cargar herramientas desde la colección de herramientas
  Future<void> _loadTools() async {
    try {
      QuerySnapshot toolSnapshot = await FirebaseFirestore.instance
          .collection('herramientas')
          //.where('proyectoId', isEqualTo: widget.projectId)
          .get();

      setState(() {
        tools = toolSnapshot.docs
            .map((doc) {
              return {
                'nombre': doc['nombre'],
                'estado': doc['estado'] ?? 'disponible', // Estado de la herramienta
                'id': doc.id,
              };
            })
            .toList();
        toolSelection = tools.map((tool) => tool['estado'] == 'en uso').toList();
      });
    } catch (e) {
      print("Error al cargar herramientas: $e");
    }
  }

  // Método para agregar un comentario
  Future<void> _addComment(String comment) async {
    try {
      final newComment = {
        'usuario': 'Usuario actual',
        'comentario': comment,
        'fecha': Timestamp.now(),
      };

      setState(() {
        comments.add(newComment);
      });

      await FirebaseFirestore.instance
          .collection('proyectos')
          .doc(widget.projectId)
          .update({
        'comentarios': FieldValue.arrayUnion([newComment]),
      });

      _commentController.clear();
    } catch (e) {
      print("Error al agregar comentario: $e");
    }
  }

  // Método para actualizar el estado de una herramienta
  // Método para actualizar el estado de una herramienta
Future<void> _updateToolStatus(int index, bool selected) async {
  final tool = tools[index];
  String newState = selected ? 'en uso' : 'disponible';


  if (tool['estado'] != newState) {
    setState(() {
      tools[index]['estado'] = newState;
      toolSelection[index] = selected; // Actualiza la selección
    });

     // Actualiza el estado en Firestore
    await FirebaseFirestore.instance
        .collection('herramientas')
        .doc(tool['id'])
        .update({'estado': newState});
  }
}

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: "Proyecto",
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Nombre",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(projectName, style: TextStyle(fontSize: 24)),
              SizedBox(height: 24),
              Text(
                "Descripción",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(projectDescription,  style: TextStyle(fontSize: 18)),
              SizedBox(height: 18),
              ExpansionTile(
                title: Text(
                  "Lista de materiales",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                children: materials.map((material) {
                  return ListTile(
                    title: Text(material),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              ExpansionTile(
                title: Text(
                  "Lista de herramientas",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                children: tools.map((tool) {
                  int index = tools.indexOf(tool);
                  return ListTile(
                    title: Text(tool['nombre']),
                    subtitle: Text("Estado: ${tool['estado']}"),
                    trailing: Checkbox(
                              value: toolSelection[index],
                              onChanged: (bool? value) {
                                    if (value != null) {
                                      setState(() {
                                      toolSelection[index] = value;
                              });
                              _updateToolStatus(index, value);
                                }
                            },

                        activeColor: tool['estado'] == 'en uso' ? Colors.red : Colors.green,
                        ),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              Text(
                "Comentarios",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ...comments.map(
                (comment) => ListTile(
                  title: Text(comment['usuario']),
                  subtitle: Text(comment['comentario']),
                  trailing: Text(
                    (comment['fecha'] as Timestamp).toDate().toString(),
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: "Escribe tu comentario",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_commentController.text.isNotEmpty) {
                    _addComment(_commentController.text);
                  }
                },
                child: Text("Agregar comentario"),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = !_isEditing;
                        });
                      },
                      child: Text(_isEditing ? "Guardar" : "Modificar"),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Terminar"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
