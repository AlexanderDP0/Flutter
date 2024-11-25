import 'package:flutter/material.dart';
import '../../utils/pc/header.dart';
import '../../utils/pc/sidenav.dart';

class ProjectScreenPC extends StatelessWidget {
  const ProjectScreenPC({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MediaQuery.of(context).size.width < 600
          ? Drawer(child: const SideNav()) // Drawer en pantallas pequeñas
          : null, // Sin Drawer en pantallas grandes
      body: Column(
        children: [
          const Header(), // Header en la parte superior
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool isWideScreen = constraints.maxWidth > 600;
                return Row(
                  children: [
                    if (isWideScreen)
                      const SideNav(), // SideNav solo en pantallas anchas
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
                                    decoration: InputDecoration(
                                        labelText: 'Project Title'),
                                  ),
                                ),
                                if (isWideScreen) SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                        labelText: 'Project Type'),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      labelText: 'Start Date',
                                      hintText: 'DD/MM/YYYY',
                                    ),
                                  ),
                                ),
                                if (isWideScreen) SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      labelText: 'End Date',
                                      hintText: 'DD/MM/YYYY',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            TextField(
                              maxLines: 4,
                              decoration: InputDecoration(
                                  labelText: 'Project Description'),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Project Roles',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Expanded(
                              child: ListView.builder(
                                itemCount:
                                    5, // Cambia el número según los roles disponibles
                                itemBuilder: (context, index) {
                                  return CheckboxListTile(
                                    title: Text('Yash'),
                                    subtitle: Text('Team Lead'),
                                    value: false,
                                    onChanged: (bool? value) {},
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () {},
                                  child: Text('Create'),
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  child: Text('Delete'),
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
