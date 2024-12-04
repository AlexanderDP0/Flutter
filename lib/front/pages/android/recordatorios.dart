import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:namer_app/front/utils/android/basescaffold.dart';

class RemindersScreen extends StatefulWidget {
  @override
  _RemindersScreenState createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final TextEditingController _reminderController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final String currentUser =
      FirebaseAuth.instance.currentUser?.displayName ?? "Nombre no disponible";

  List<Map<String, dynamic>> reminders = [];

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  // Cargar recordatorios del usuario actual desde Firestore
  Future<void> _loadReminders() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('recordatorios')
          .where('usuarioId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .get();

      setState(() {
        reminders = snapshot.docs
            .map((doc) => Map<String, dynamic>.from(doc.data() as Map))
            .toList();
      });
    } catch (e) {
      print("Error al cargar recordatorios: $e");
    }
  }

  // Método para agregar un recordatorio
  Future<void> _addReminder(String reminder) async {
    if (selectedDate != null && selectedTime != null) {
      try {
        final DateTime reminderDateTime = DateTime(
          selectedDate!.year,
          selectedDate!.month,
          selectedDate!.day,
          selectedTime!.hour,
          selectedTime!.minute,
        );

        final newReminder = {
          'usuarioId': FirebaseAuth.instance.currentUser?.uid,
          'usuario': currentUser,
          'recordatorio': reminder,
          'fecha': Timestamp.fromDate(reminderDateTime),
        };

        // Añadir a Firestore
        DocumentReference docRef = await FirebaseFirestore.instance
            .collection('recordatorios')
            .add(newReminder);

        setState(() {
          reminders.add({
            ...newReminder,
            'id': docRef.id,
          });
        });

        _reminderController.clear();
        selectedDate = null;
        selectedTime = null;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Recordatorio agregado correctamente.")),
        );
      } catch (e) {
        print("Error al agregar recordatorio: $e");
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor, selecciona fecha y hora.")),
      );
    }
  }

  // Selección de fecha
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

  // Selección de hora
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

  @override
  Widget build(BuildContext context) {
   return Scaffold(
      appBar: AppBar(title: Text("Recordatorios")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: reminders.isEmpty
                  ? Center(child: Text("No tienes recordatorios."))
                  : ListView.builder(
                      itemCount: reminders.length,
                      itemBuilder: (context, index) {
                        final reminder = reminders[index];
                        final reminderDate = (reminder['fecha'] as Timestamp)
                            .toDate()
                            .toLocal();
                        return Card(
                          child: ListTile(
                            leading: Icon(Icons.notifications),
                            title: Text(reminder['recordatorio']),
                            subtitle: Text(
                              "${reminderDate.day}/${reminderDate.month}/${reminderDate.year} ${reminderDate.hour}:${reminderDate.minute}",
                            ),
                          ),
                        );
                      },
                    ),
            ),
            TextField(
              controller: _reminderController,
              decoration: InputDecoration(
                labelText: "Nuevo Recordatorio",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: Text(
                      selectedDate == null
                          ? "Selecciona Fecha"
                          : "${selectedDate!.toLocal()}".split(' ')[0],
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selectTime(context),
                    child: Text(
                      selectedTime == null
                          ? "Selecciona Hora"
                          : "${selectedTime!.format(context)}",
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_reminderController.text.isNotEmpty) {
                  _addReminder(_reminderController.text);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Por favor, escribe un recordatorio.")),
                  );
                }
              },
              child: Text("Agregar Recordatorio"),
            ),
          ],
        ),
      ),
    );
  }
}
