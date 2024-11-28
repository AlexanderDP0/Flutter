import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/pc/header.dart';
import '../../utils/pc/sidenav.dart';

class ProjectScreenPC extends StatefulWidget {
  const ProjectScreenPC({Key? key}) : super(key: key);

  @override
  _ProjectScreenPCState createState() => _ProjectScreenPCState();
}

class _ProjectScreenPCState extends State<ProjectScreenPC> {
  final _titleController = TextEditingController();
  final _typeController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _descriptionController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mapa para mantener el estado de los usuarios seleccionados
  Map<String, bool> _selectedUsers = {};

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  void _fetchUsers() async {
    // Cargar usuarios desde Firebase
    QuerySnapshot snapshot = await _firestore.collection('users').get();
    setState(() {
      _selectedUsers = {
        for (var doc in snapshot.docs) doc.id: false,
      };
    });
  }

  void _createProject() async {
    if (_titleController.text.isEmpty ||
        _typeController.text.isEmpty ||
        _startDateController.text.isEmpty ||
        _endDateController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor llena todos los campos')),
      );
      return;
    }

    try {
      // Crear proyecto en Firestore
      DocumentReference projectRef = await _firestore.collection('proyectos').add({
        'nombre': _titleController.text,
        'tipo': _typeController.text,
        'fechaInicio': _startDateController.text,
        'fechaFin': _endDateController.text,
        'descripcion': _descriptionController.text,
        'created_at': FieldValue.serverTimestamp(),
      });

      // Asignar proyecto a usuarios seleccionados
      for (String userId in _selectedUsers.keys.where((key) => _selectedUsers[key]!)) {
        await _firestore.collection('users').doc(userId).update({
          'proyectos': FieldValue.arrayUnion([projectRef.id]),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Proyecto creado y asignado exitosamente')),
      );

      // Limpiar campos y selección
      _titleController.clear();
      _typeController.clear();
      _startDateController.clear();
      _endDateController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedUsers.updateAll((key, value) => false);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear el proyecto: $e')),
      );
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
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _titleController,
                                    decoration: InputDecoration(labelText: 'Título del Proyecto'),
                                  ),
                                ),
                                if (isWideScreen) SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: _typeController,
                                    decoration: InputDecoration(labelText: 'Tipo de Proyecto'),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _startDateController,
                                    decoration: InputDecoration(
                                      labelText: 'Fecha de Inicio',
                                      hintText: 'DD/MM/YYYY',
                                    ),
                                  ),
                                ),
                                if (isWideScreen) SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: _endDateController,
                                    decoration: InputDecoration(
                                      labelText: 'Fecha de Fin',
                                      hintText: 'DD/MM/YYYY',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            TextField(
                              controller: _descriptionController,
                              maxLines: 4,
                              decoration: InputDecoration(labelText: 'Descripción del Proyecto'),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Seleccionar Usuarios',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Expanded(
                              child: ListView(
                                children: _selectedUsers.keys.map((userId) {
                                  return FutureBuilder<DocumentSnapshot>(
                                    future: _firestore.collection('users').doc(userId).get(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return CircularProgressIndicator();
                                      }
                                      if (snapshot.hasError || !snapshot.hasData) {
                                        return SizedBox.shrink();
                                      }
                                      var user = snapshot.data!;
                                      return CheckboxListTile(
                                        title: Text(user['name'] ?? 'Sin Nombre'),
                                        subtitle: Text(user['email'] ?? 'Sin Email'),
                                        value: _selectedUsers[userId],
                                        onChanged: (bool? value) {
                                          setState(() {
                                            _selectedUsers[userId] = value ?? false;
                                          });
                                        },
                                      );
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: _createProject,
                                  child: Text('Crear'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    _titleController.clear();
                                    _typeController.clear();
                                    _startDateController.clear();
                                    _endDateController.clear();
                                    _descriptionController.clear();
                                    setState(() {
                                      _selectedUsers.updateAll((key, value) => false);
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  child: Text('Limpiar'),
                                ),
                              ],
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
