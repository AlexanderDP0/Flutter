import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/pc/header.dart'; // Importa el Header
import '../../utils/pc/sidenav.dart'; // Importa el SideNav

void main() {
  runApp(MaterialApp(home: ToolsAndMaterialsScreen()));
}

class ToolsAndMaterialsScreen extends StatelessWidget {
  final TextEditingController materialController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController toolController = TextEditingController();

  // Agregar Material a Firestore
  Future<void> addMaterial() async {
    String material = materialController.text.trim();
    int quantity = int.tryParse(quantityController.text.trim()) ?? 0;
    if (material.isNotEmpty && quantity > 0) {
      await FirebaseFirestore.instance.collection('materiales').add({
        'nombre': material,
        'cantidadDisponible': quantity,
      });
      materialController.clear();
      quantityController.clear();
    }
  }

  // Agregar Herramienta a Firestore
 // Agregar Herramienta a Firestore
Future<void> addTool() async {
  String tool = toolController.text.trim();
  if (tool.isNotEmpty) {
    await FirebaseFirestore.instance.collection('herramientas').add({
      'nombre': tool,
      'estado': 'disponible', // Campo predeterminado
      'fechaAsignacion': null, // Campo inicializado como null
    });
    toolController.clear();
  }
}

// Update Material Stock
  Future<void> updateMaterialStock(BuildContext context, String materialId, int currentStock) async {
    final TextEditingController newStockController = TextEditingController(text: currentStock.toString());

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Actualizar Stock'),
        content: TextField(
          controller: newStockController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Nueva cantidad disponible'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              int newStock = int.tryParse(newStockController.text.trim()) ?? currentStock;
              if (newStock >= 0) {
                await FirebaseFirestore.instance
                    .collection('materiales')
                    .doc(materialId)
                    .update({'cantidadDisponible': newStock});
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Stock actualizado')));
              }
            },
            child: Text('Actualizar'),
          ),
        ],
      ),
    );
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    drawer: MediaQuery.of(context).size.width < 600
        ? Drawer(child: SideNav())
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
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Add Materials
                            Text(
                              'Agregar Materiales',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: materialController,
                                    decoration: InputDecoration(
                                        labelText: 'Nombre del Material'),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: quantityController,
                                    decoration: InputDecoration(
                                        labelText: 'Cantidad Disponible'),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: addMaterial,
                                  child: Text('Agregar Material'),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            // Material List
                            Text(
                              'Lista de Materiales',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Container(
                              height: 200,
                              child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('materiales')
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }
                                  final materials = snapshot.data!.docs;
                                  return ListView.builder(
                                    itemCount: materials.length,
                                    itemBuilder: (context, index) {
                                      final material = materials[index];
                                      int quantity =
                                          material['cantidadDisponible'];
                                      return Card(
                                        color: quantity <= 10
                                            ? Colors.red[100]
                                            : Colors.white,
                                        child: ListTile(
                                          title: Text(material['nombre']),
                                          subtitle: Text('Cantidad: $quantity'),
                                          trailing: IconButton(
                                            icon: Icon(Icons.edit,
                                                color: Colors.blue),
                                            onPressed: () {
                                              updateMaterialStock(context,
                                                  material.id, quantity);
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 20),
                            // Add Tools
                            Text(
                              'Agregar Herramientas',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: toolController,
                                    decoration: InputDecoration(
                                        labelText: 'Nombre de la Herramienta'),
                                  ),
                                ),
                                SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: addTool,
                                  child: Text('Agregar Herramienta'),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            // Tool List
                            Text(
                              'Lista de Herramientas',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Container(
                              height: 200,
                              child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('herramientas')
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }
                                  final tools = snapshot.data!.docs;
                                  return ListView.builder(
                                    itemCount: tools.length,
                                    itemBuilder: (context, index) {
                                      final tool = tools[index];
                                      return Card(
                                        child: ListTile(
                                          title: Text(tool['nombre']),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
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