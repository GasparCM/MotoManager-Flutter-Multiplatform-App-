import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'main.dart';

class TareasScreen extends StatefulWidget {
  const TareasScreen({super.key});

  @override
  _TareasScreenState createState() => _TareasScreenState();
}

class _TareasScreenState extends State<TareasScreen> {
  List<Map<String, dynamic>> _tareas = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTareas();
  }

  Future<void> _fetchTareas() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await supabase.from('tareas').select('descripcion, estado, prioridad, mecanico_asignado');

      setState(() {
        _tareas = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text('Error: $_error'));

    return ListView.builder(
      itemCount: _tareas.length,
      itemBuilder: (context, index) {
        final tarea = _tareas[index];
        final descripcion = tarea['descripcion'];
        final estado = tarea['estado'];
        final prioridad = tarea['prioridad'];

        return Card(
          margin: const EdgeInsets.all(10),
          elevation: 5,
          child: ListTile(
            title: Text(descripcion, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            subtitle: Text('Estado: $estado - Prioridad: $prioridad'),
            trailing: const Icon(Icons.build),
          ),
        );
      },
    );
  }
}
