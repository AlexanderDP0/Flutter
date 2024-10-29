import 'package:flutter/material.dart';

class ProjectScreen extends StatefulWidget {
  @override
  _ProjectScreenState createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  bool _isEditing = false;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  List<String> materials = ["Material 1", "Material 2", "Material 3"];
  List<String> tools = ["Herramienta 1", "Herramienta 2", "Herramienta 3"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Proyecto"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Nombre",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text("ID_Proyecto"),
            SizedBox(height: 16),
            Text(
              "Descripción",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: "Descripción del proyecto",
              ),
              readOnly: !_isEditing,
              maxLines: 2,
            ),
            SizedBox(height: 16),
            Text(
              "Lista materiales (desplegable)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (_isEditing)
              Column(
                children: materials.map((material) {
                  int index = materials.indexOf(material);
                  return TextFormField(
                    initialValue: material,
                    onChanged: (value) {
                      materials[index] = value;
                    },
                  );
                }).toList(),
              )
            else
              ...materials.map((material) => ListTile(title: Text(material))),
            SizedBox(height: 16),
            Text(
              "Lista herramientas",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (_isEditing)
              Column(
                children: tools.map((tool) {
                  int index = tools.indexOf(tool);
                  return TextFormField(
                    initialValue: tool,
                    onChanged: (value) {
                      tools[index] = value;
                    },
                  );
                }).toList(),
              )
            else
              ...tools.map((tool) => ListTile(title: Text(tool))),
            SizedBox(height: 16),
            Text(
              "Comentarios",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: "Escribe tus comentarios",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            Spacer(),
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
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Confirmar"),
                          content:
                              Text("¿Deseas terminar y guardar los cambios?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text("Cancelar"),
                            ),
                            TextButton(
                              onPressed: () {
                                // Aquí se guardan las modificaciones y regresa a la pantalla principal
                                Navigator.of(context)
                                    .pop(); // Cierra el cuadro de diálogo
                                Navigator.of(context)
                                    .pop(); // Regresa a la pantalla principal
                              },
                              child: Text("Confirmar"),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text("Terminar"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
