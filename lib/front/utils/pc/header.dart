import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo or Title
          Row(
            children: [
              Icon(Icons.group, color: Colors.blue, size: 32), // Logo
              SizedBox(width: 8),
              Text(
                "AProjectO",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          // Notification and Profile with Search Bar
          Row(
            children: [
              // Search Bar responsivo con ancho máximo de 500
              Container(
                constraints:
                    BoxConstraints(maxWidth: 500), // Ancho máximo de 500
                width: MediaQuery.of(context).size.width *
                    0.5, // Toma 50% del ancho de la pantalla
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search for anything...",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
              ),
              SizedBox(
                  width:
                      8), // Espacio entre el search bar y el icono de notificación
              IconButton(
                icon: Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
              SizedBox(width: 8),
              CircleAvatar(
                backgroundImage: NetworkImage(
                  'https://example.com/profile-image.jpg', // Replace with actual image URL or asset path
                ),
                radius: 16,
              ),
              SizedBox(width: 8),
              Text("Anima Agrawal", style: TextStyle(color: Colors.black)),
              SizedBox(width: 4),
              Text("UP, India", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
