import 'package:flutter/material.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: 24.0), // Reduce padding horizontal
        child: Center(
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // Ajusta la altura de la columna al contenido
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Iniciar sesión',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16), // Reduce el espacio vertical
              TextField(
                controller: _userController,
                decoration: InputDecoration(
                  labelText: 'Usuario',
                  hintText: 'ID',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 12.0), // Reduce padding interno
                ),
              ),
              SizedBox(height: 16), // Reduce el espacio vertical
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  hintText: 'Contraseña',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 12.0), // Reduce padding interno
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isPasswordVisible,
              ),
              SizedBox(height: 12), // Reduce el espacio vertical
              Row(
                children: [
                  Switch(
                    value: _rememberMe,
                    onChanged: (bool value) {
                      setState(() {
                        _rememberMe = value;
                      });
                    },
                  ),
                  Text('Recordar'),
                  Spacer(),
                  TextButton(
                    onPressed: () {
                      // Aquí podrías añadir la lógica de "Olvidaste tu contraseña"
                    },
                    child: Text('¿Olvidaste tu contraseña?'),
                  ),
                ],
              ),
              SizedBox(height: 12), // Reduce el espacio vertical
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(
                        vertical: 12.0), // Reduce padding del botón
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text('Iniciar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
