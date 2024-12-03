import 'package:flutter/material.dart';
import 'package:namer_app/front/utils/android/basescaffold.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ProjectScreen extends StatefulWidget {
  final String projectId; 
  ProjectScreen({required this.projectId});

  @override
  _ProjectScreenState createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  bool _isEditing = false;
  final TextEditingController _textController = TextEditingController();
  String currentUser = FirebaseAuth.instance.currentUser?.displayName ?? "Nombre no disponible"; 
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  // Variables para proyectos, materiales, herramientas, comentarios y recordatorios
  String projectName = "";
  String projectDescription = "";
  List<String> materials = [];
  List<Map<String, dynamic>> tools = [];
  List<Map<String, dynamic>> comments = [];
  List<Map<String, dynamic>> reminders = [];
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
          reminders = List<Map<String, dynamic>>.from(
              projectSnapshot['recordatorios'] ?? []);
          _textController.text = projectDescription;
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
      'usuario': currentUser, // Usar el nombre del usuario actual
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

    _textController.clear();
  } catch (e) {
    print("Error al agregar comentario: $e");
  }
}

  // Método para seleccionar la fecha
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Método para seleccionar la hora
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  // Método para agregar un recordatorio
  Future<void> _addReminder(String reminder) async {
    if (selectedDate != null && selectedTime != null) {
      try {
        // Combina la fecha y hora seleccionadas en un solo objeto DateTime
        final DateTime reminderDateTime = DateTime(
          selectedDate!.year,
          selectedDate!.month,
          selectedDate!.day,
          selectedTime!.hour,
          selectedTime!.minute,
        );

        final newReminder = {
          'usuario': currentUser, // Usar el nombre del usuario actual
          'recordatorio': reminder,
          'fecha': Timestamp.fromDate(reminderDateTime), // Convertir DateTime a Timestamp
        };

        setState(() {
          reminders.add(newReminder);
        });

        await FirebaseFirestore.instance
            .collection('proyectos')
            .doc(widget.projectId)
            .update({
          'recordatorios': FieldValue.arrayUnion([newReminder]),
        });

        _textController.clear();
        setState(() {
          selectedDate = null; // Resetea la fecha
          selectedTime = null; // Resetea la hora
        });
      } catch (e) {
        print("Error al agregar recordatorio: $e");
      }
    } else {
      // Si no se ha seleccionado fecha u hora, muestra un mensaje de advertencia
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor, selecciona una fecha y hora para el recordatorio.")),
      );
    }
  }

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

   // Método para mostrar el modal de fecha y hora
  void _showDateTimeModal(BuildContext context, String reminder) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Seleccionar Fecha y Hora"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: Text(selectedDate == null
                        ? "Selecciona fecha"
                        : "${selectedDate!.toLocal()}".split(' ')[0]),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _selectTime(context),
                    child: Text(selectedTime == null
                        ? "Selecciona hora"
                        : "${selectedTime!.format(context)}"),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _addReminder(reminder);
              },
              child: Text("Agregar Recordatorio"),
            ),
          ],
        );
      },
    );
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
              SizedBox(height: 16),
              Text(
                "Comentarios y recordatorios",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ...comments.map(
                (comment) => ListTile(
                  title: Text(comment['usuario']),
                  subtitle: Text(comment['comentario']),
                  trailing: Text(
                    (comment['fecha'] as Timestamp).toDate().toLocal().toString(),
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ),
              ...reminders.map(
                (reminder) => ListTile(
                  leading: Icon(Icons.notifications),
                  title: Text(reminder['recordatorio']),
                  subtitle: Text(reminder['usuario']),
                  trailing: Text(
                    (reminder['fecha'] as Timestamp).toDate().toLocal().toString(),
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: "Escribe tu comentario o recordatorio",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_textController.text.isNotEmpty) {
                          _addComment(_textController.text);
                        }
                      },
                      child: Text("Agregar comentario"),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_textController.text.isNotEmpty) {
                          _showDateTimeModal(context, _textController.text);
                        }
                      },
                      child: Text("Agregar recordatorio"),
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