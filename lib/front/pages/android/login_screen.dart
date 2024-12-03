import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isPasswordVisible = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;


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
                  onPressed: _login,
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



Future<void> _login() async {
  String email = _userController.text.trim();
  String password = _passwordController.text.trim();

  if (email.isEmpty || password.isEmpty) {
    _showError('Por favor ingresa todos los campos');
    return;
  }

  try {
    // Realiza la autenticación con Firebase
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

    // Obtén el UID del usuario autenticado
    String uid = userCredential.user?.uid ?? '';

    // Navega a la pantalla principal, pasando el UID
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen(userId: uid)),
    );
  } on FirebaseAuthException catch (e) {
    // Muestra un mensaje de error si la autenticación falla
    _showError(e.message ?? 'Ocurrió un error inesperado');
  }
}

void _showError(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
}