import 'package:flutter/material.dart';
import 'package:namer_app/front/utils/android/basescaffold.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProjectScreen extends StatefulWidget {
  final String projectId; 
  final String userName;
  ProjectScreen({required this.projectId, required  this.userName});

  @override
  _ProjectScreenState createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
 final TextEditingController _commentController = TextEditingController(); // Controlador solo para comentarios
  final TextEditingController _descriptionController = TextEditingController(); // Controlador para la descripción solo en modo edición
  
  String currentUser = " ";
  // Variables para proyectos, materiales, herramientas y comentarios
  String projectName = "";
  String projectDescription = "";
  List<String> materials = [];
  List<Map<String, dynamic>> tools = [];
  List<Map<String, dynamic>> comments = [];
  List<bool> toolSelection = []; // Lista para el estado de los checkboxes
  String commentPriority = "Normal"; // Prioridad del comentario
  List<String> actividades = []; // Lista de actividades del proyecto
  List<bool> actividadSelection = []; // Estado de selección de las actividades
  double progreso = 0.0; // Porcentaje de progreso del proyecto
  
  @override
  void initState() {
    super.initState();
    currentUser = widget.userName;
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
          _loadMaterials(widget.projectId);
          _loadTools();
          _loadActividades(widget.projectId);
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
Future<void> _loadMaterials(String projectId) async {
  try {
    // Primero, obtenemos los materiales asociados a un proyecto
    DocumentSnapshot projectSnapshot = await FirebaseFirestore.instance
        .collection('proyectos') // Accedemos a la colección de proyectos
        .doc(projectId) // Accedemos a un proyecto específico
        .get();

    // Obtenemos el campo 'materiales' (es un arreglo de mapas)
    List materiales = projectSnapshot['materiales'];

    // Ahora, buscamos la información de cada material usando su ID
    List<Map<String, dynamic>> materialList = [];
    for (var material in materiales) {
      String materialId = material['id']; // El ID del material
      int cantidad = material['cantidad']; // La cantidad de ese material

      // Consultamos el material completo usando su ID
      DocumentSnapshot materialSnapshot = await FirebaseFirestore.instance
          .collection('materiales') // Accedemos a la colección de materiales
          .doc(materialId) // Accedemos al material específico
          .get();

      // Añadimos la información completa del material y la cantidad
      materialList.add({
        'nombre': materialSnapshot['nombre'], // Nombre del material
        'stock': materialSnapshot['cantidadDisponible'],   // Stock actual del material
        'cantidad': cantidad,                 // Cantidad asociada al proyecto
      });
    }

    setState(() {
      // Actualizamos el estado con la lista de materiales
      materials = materialList.map((m) => m['nombre'] as String).toList();

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
          .get();

      setState(() {
        tools = toolSnapshot.docs
            .map((doc) {
              return {
                'nombre': doc['nombre'],
                'estado': doc['estado'] ?? 'disponible',
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

// Método para actualizar el estado de una herramienta
  Future<void> _updateToolStatus(int index, bool selected) async {
    final tool = tools[index];
    String newState = selected ? 'en uso' : 'disponible';

    if (tool['estado'] != newState) {
      setState(() {
        tools[index]['estado'] = newState;
        toolSelection[index] = selected;
      });

      await FirebaseFirestore.instance
          .collection('herramientas')
          .doc(tool['id'])
          .update({'estado': newState});
    }
  }
 
  // Método para agregar un comentario
  Future<void> _addComment(String comment) async {
    try {
      final newComment = {
        'usuario': currentUser,
        'comentario': comment,
        'prioridad': commentPriority,
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

Future<void> _loadActividades(String projectId) async {
  try {
    DocumentSnapshot projectSnapshot = await FirebaseFirestore.instance
        .collection('proyectos')
        .doc(projectId)
        .get();

    if (projectSnapshot.exists) {
      List<dynamic> actividadesData = projectSnapshot['actividades'] ?? [];
      bool needsUpdate = false;

      // Verificar y agregar el campo `completado` si no existe
       List<Map<String, dynamic>> actividadesActualizadas = actividadesData.map((actividad) {
        if (actividad is Map<String, dynamic> && !actividad.containsKey('completado')) {
          needsUpdate = true;
          return {...actividad, 'completado': false};
        } else if (actividad is String) {
          // Si la actividad es solo un nombre (String), convertirla en un mapa
          needsUpdate = true;
          return {'nombre': actividad, 'completado': false};
        }
        return actividad;
      }).toList().cast<Map<String, dynamic>>();

      if (needsUpdate) {
        // Actualizar Firebase con las actividades que ahora incluyen el campo `completado`
        await FirebaseFirestore.instance
            .collection('proyectos')
            .doc(projectId)
            .update({'actividades': actividadesData});
      }

      setState(() {
        // Extraer nombres y estados de las actividades actualizadas
        actividades = actividadesActualizadas.map((actividad) => actividad['nombre'] as String).toList();
        actividadSelection = actividadesActualizadas.map((actividad) => actividad['completado'] as bool).toList();
        _calcularProgreso();
      });
    }
  } catch (e) {
    print("Error al cargar actividades: $e");
  }
}

Future<void> _updateActividadEstado(int index, bool completado) async {
  try {
    List<Map<String, dynamic>> actividadesActualizadas = List.generate(
      actividades.length,
      (i) => {
        'nombre': actividades[i],
        'completado': actividadSelection[i],
      },
    );

    // Actualizar Firebase
    await FirebaseFirestore.instance
        .collection('proyectos')
        .doc(widget.projectId)
        .update({'actividades': actividadesActualizadas});

    print("Estado de la actividad actualizado en Firebase");
  } catch (e) {
    print("Error al actualizar estado de la actividad: $e");
  }
}
  
void _calcularProgreso() {
  int completadas = actividadSelection.where((completada) => completada).length;
  setState(() {
    progreso = (completadas / actividades.length) * 100;
  });
  _guardarProgreso(widget.projectId); // Guardar el progreso en Firebase
}

Future<void> _guardarProgreso(String projectId) async {
  try {
    await FirebaseFirestore.instance
        .collection('proyectos')
        .doc(projectId)
        .update({'progreso': progreso});
    print("Progreso actualizado en Firebase: $progreso%");
  } catch (e) {
    print("Error al guardar progreso en Firebase: $e");
  }
}

void _toggleActividad(int index, bool? value) {
  if (value != null) {
    setState(() {
      actividadSelection[index] = value;
      _calcularProgreso();
    });
    _updateActividadEstado(index, value);

  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Proyecto")),
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
              Text(projectDescription, style: TextStyle(fontSize: 18)),
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
              ExpansionTile(
                title: Text('Actividades',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                children: [
                  ...List.generate(
                    actividades.length,
                    (index) => CheckboxListTile(
                    title: Text(actividades[index]),
                    value: actividadSelection[index],
                    onChanged: (value) {
                      _toggleActividad(index, value);
                  },
                ),
              ),
            ],
          ),
              SizedBox(height: 16),
              Text(
                "Comentarios",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ...comments.map(
                (comment) => ListTile(
                  title: Text(comment['usuario']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(comment['comentario']),
                      Text("Prioridad: ${comment['prioridad']}"),
                    ],
                  ),
                  trailing: Text(
                    (comment['fecha'] as Timestamp).toDate().toLocal().toString(),
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
              SizedBox(height: 8),
              DropdownButton<String>(
                value: commentPriority,
                onChanged: (String? newValue) {
                  setState(() {
                    commentPriority = newValue ?? "Normal";
                  });
                },
                items: ["Normal", "Urgente"]
                    .map((priority) => DropdownMenuItem(
                          value: priority,
                          child: Text(priority),
                        ))
                    .toList(),
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
            ],
          ),
        ),
      ),
    );
  }
}