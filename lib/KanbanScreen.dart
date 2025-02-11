import 'package:flutter/material.dart';
import 'main.dart';

class KanbanScreen extends StatefulWidget {
  const KanbanScreen({super.key});

  @override
  _KanbanScreenState createState() => _KanbanScreenState();
}

class _KanbanScreenState extends State<KanbanScreen> {
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
      final response = await supabase.from('tareas').select('*');
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

  Future<void> _updateTareaEstado(int id, String nuevoEstado) async {
    await supabase.from('tareas').update({'estado': nuevoEstado}).eq('id', id);
    _fetchTareas(); // Refrescar la vista
  }

  void _crearNuevaTarea() {
    showDialog(
      context: context,
      builder: (context) {
        return const AddTareaForm();
      },
    ).then((_) => _fetchTareas()); // Refresca las tareas después de crear una
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text('Error: $_error'));

    List<Map<String, dynamic>> pendientes = _tareas.where((t) => t['estado'] == 'Pendientes').toList();
    List<Map<String, dynamic>> enProceso = _tareas.where((t) => t['estado'] == 'En el Taller').toList();
    List<Map<String, dynamic>> finalizadas = _tareas.where((t) => t['estado'] == 'Completadas').toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Tareas')),
      floatingActionButton: FloatingActionButton(
        onPressed: _crearNuevaTarea,
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // 🔹 Activa el scroll horizontal
        child: Row(
          children: [
            _buildKanbanColumn('Pendientes', pendientes, Colors.redAccent),
            _buildKanbanColumn('En el Taller', enProceso, Colors.orangeAccent),
            _buildKanbanColumn('Completadas', finalizadas, Colors.greenAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildKanbanColumn(String estado, List<Map<String, dynamic>> tareas, Color color) {
    return DragTarget<Map<String, dynamic>>(
      onWillAccept: (data) => data!['estado'] != estado, // Solo aceptar si es diferente
      onAccept: (tarea) {
        _updateTareaEstado(tarea['id'], estado);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 320.0, // 🔹 Columnas más anchas
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(
                estado,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: tareas.length,
                  itemBuilder: (context, index) {
                    final tarea = tareas[index];
                    return Draggable<Map<String, dynamic>>(
                      data: tarea,
                      feedback: Material(
                        child: Card(
                          elevation: 5,
                          color: Colors.white70,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(tarea['descripcion'], style: const TextStyle(fontSize: 16)),
                          ),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: _buildTareaCard(tarea),
                      ),
                      child: _buildTareaCard(tarea),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTareaCard(Map<String, dynamic> tarea) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        title: Text(tarea['descripcion']),
        subtitle: Text('Mecánico: ${tarea['mecanico_asignado'] ?? 'Sin asignar'}'),
        onTap: () => _showTareaDetails(tarea),
      ),
    );
  }

  void _showTareaDetails(Map<String, dynamic> tarea) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Detalles de Tarea: ${tarea['descripcion']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🛠️ Estado: ${tarea['estado']}'),
              Text('📅 Creación: ${tarea['fecha_creacion']}'),
              Text('📆 Vencimiento: ${tarea['fecha_vencimiento']}'),
              Text('⚙️ Mecánico: ${tarea['mecanico_asignado']}'),
              Text('🔧 Reparación: ${tarea['detalles_reparacion']}'),
              Text('📜 Descripción: ${tarea['descripcion']}'),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        );
      },
    );
  }
}


class AddTareaForm extends StatefulWidget {
  const AddTareaForm({super.key});

  @override
  _AddTareaFormState createState() => _AddTareaFormState();
}

class _AddTareaFormState extends State<AddTareaForm> {
  final _descripcionController = TextEditingController();
  String? _mecanicoSeleccionado;
  List<String> _mecanicos = [];
  String _estadoSeleccionado = 'Pendientes';
  String _prioridadSeleccionada = 'Media';

  @override
  void initState() {
    super.initState();
    _fetchMecanicos();
  }

  Future<void> _fetchMecanicos() async {
    final response = await supabase.from('usuarios').select('usuario').eq('rol', 'Mecanico');
    setState(() {
      _mecanicos = response.map<String>((u) => u['usuario'].toString()).toList();
    });
  }

  void _guardarTarea() async {
    if (_descripcionController.text.isEmpty || _mecanicoSeleccionado == null) {
      return;
    }

    await supabase.from('tareas').insert({
      'descripcion': _descripcionController.text,
      'mecanico_asignado': _mecanicoSeleccionado,
      'estado': _estadoSeleccionado,
      'prioridad': _prioridadSeleccionada,
      'fecha_creacion': DateTime.now().toIso8601String(),
      'fecha_vencimiento': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva Tarea'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _descripcionController,
            decoration: const InputDecoration(labelText: 'Descripción'),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _mecanicoSeleccionado,
            hint: const Text('Seleccionar mecánico'),
            items: _mecanicos.map((mecanico) {
              return DropdownMenuItem(value: mecanico, child: Text(mecanico));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _mecanicoSeleccionado = value;
              });
            },
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _estadoSeleccionado,
            items: ['Pendientes', 'En el Taller', 'Completadas'].map((e) {
              return DropdownMenuItem(value: e, child: Text(e));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _estadoSeleccionado = value!;
              });
            },
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _guardarTarea,
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
