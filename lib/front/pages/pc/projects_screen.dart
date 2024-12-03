import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Para formatear la fecha
import '../../utils/pc/header.dart';
import '../../utils/pc/sidenav.dart';

class ProjectScreenPC extends StatefulWidget {
  const ProjectScreenPC({Key? key}) : super(key: key);

  @override
  _ProjectScreenPCState createState() => _ProjectScreenPCState();
}

class _ProjectScreenPCState extends State<ProjectScreenPC> with SingleTickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _typeController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _descriptionController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, bool> _selectedUsers = {};
  Map<String, int> _selectedMaterials = {}; // Almacena material ID y cantidad seleccionada
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchUsers();
    _fetchMaterials();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _typeController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _fetchUsers() async {
    QuerySnapshot snapshot = await _firestore.collection('users').get();
    setState(() {
      _selectedUsers = {
        for (var doc in snapshot.docs) doc.id: false,
      };
    });
  }

  void _fetchMaterials() async {
    QuerySnapshot snapshot = await _firestore.collection('materiales').get();
    setState(() {
      _selectedMaterials = {
        for (var doc in snapshot.docs) doc.id: 0, // Inicializa cantidad a 0
      };
    });
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime currentDate = DateTime.now();
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      controller.text = DateFormat('dd/MM/yyyy').format(selectedDate);
    }
  }

  void _createProject() async {
    if (_titleController.text.isEmpty || _typeController.text.isEmpty || _startDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, llena todos los campos obligatorios.')),
      );
      return;
    }

    try {
      await _firestore.collection('proyectos').add({
        'titulo': _titleController.text,
        'tipo': _typeController.text,
        'fechaInicio': _startDateController.text,
        'fechaFin': _endDateController.text,
        'descripcion': _descriptionController.text,
        'usuarios': _selectedUsers.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList(),
        'materiales': _selectedMaterials.entries
            .where((entry) => entry.value > 0)
            .map((entry) => {'id': entry.key, 'cantidad': entry.value})
            .toList(),
        'creadoEl': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Proyecto creado con éxito.')),
      );

      // Limpia los campos después de guardar
      _titleController.clear();
      _typeController.clear();
      _startDateController.clear();
      _endDateController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedUsers = {for (var key in _selectedUsers.keys) key: false};
        _selectedMaterials = {for (var key in _selectedMaterials.keys) key: 0};
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
                            TextField(
                              controller: _titleController,
                              decoration: InputDecoration(labelText: 'Título del Proyecto'),
                            ),
                            SizedBox(height: 10),
                            TextField(
                              controller: _typeController,
                              decoration: InputDecoration(labelText: 'Tipo de Proyecto'),
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
                                    readOnly: true,
                                    onTap: () => _selectDate(context, _startDateController),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: _endDateController,
                                    decoration: InputDecoration(
                                      labelText: 'Fecha de Fin',
                                      hintText: 'DD/MM/YYYY',
                                    ),
                                    readOnly: true,
                                    onTap: () => _selectDate(context, _endDateController),
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
                            TabBar(
                              controller: _tabController,
                              labelColor: Theme.of(context).primaryColor,
                              unselectedLabelColor: Colors.grey,
                              tabs: [
                                Tab(text: 'Usuarios'),
                                Tab(text: 'Materiales'),
                              ],
                            ),
                            Expanded(
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  _buildUserList(),
                                  _buildMaterialList(),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: Center(
                                child: ElevatedButton(
                                  onPressed: _createProject,
                                  child: Text('Crear Proyecto'),
                                ),
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

  Widget _buildUserList() {
    return ListView(
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
    );
  }

  Widget _buildMaterialList() {
    return ListView(
      children: _selectedMaterials.keys.map((materialId) {
        return FutureBuilder<DocumentSnapshot>(
          future: _firestore.collection('materiales').doc(materialId).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return SizedBox.shrink();
            }
            var material = snapshot.data!;
            return ListTile(
              title: Text(material['nombre'] ?? 'Sin Nombre'),
              subtitle: Text('Stock: ${material['cantidadDisponible'] ?? 0}'),
              trailing: SizedBox(
                width: 100,
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Cantidad'),
                  onChanged: (value) {
                    setState(() {
                      _selectedMaterials[materialId] = int.tryParse(value) ?? 0;
                    });
                  },
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
