import 'package:flutter/material.dart';
import 'projects_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pantalla Principal"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bienvenido Otra Vez!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text("User", style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Text(
              "Proyectos",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 3 / 4,
                ),
                itemCount: 6, // Número de tarjetas
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProjectScreen()),
                      );
                    },
                    child: Container(
                      color: Colors.grey[300],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
