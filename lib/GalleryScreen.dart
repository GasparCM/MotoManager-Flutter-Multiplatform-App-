import 'package:flutter/material.dart';
import 'main.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<Map<String, dynamic>> _motos = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchMotos();
  }

  Future<void> _fetchMotos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // ✅ Consulta correcta con JOIN de motos y clientes para traer nombre y apellidos
      final response = await supabase
          .from('motos')
          .select('matricula, modelo, marca, año, image_url, dni_cliente, clientes(nombre, apellido1, apellido2)');

      if (response is List) {
        setState(() {
          _motos = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'No se pudieron cargar los datos.';
          _isLoading = false;
        });
      }
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
    if (_motos.isEmpty) return const Center(child: Text('No hay imágenes guardadas.'));

    return ListView.builder(
      itemCount: _motos.length,
      itemBuilder: (context, index) {
        final moto = _motos[index];
        final matricula = moto['matricula'] ?? 'Desconocida';
        final modelo = moto['modelo'] ?? 'Modelo desconocido';
        final marca = moto['marca'] ?? 'Marca desconocida';
        final anio = moto['año']?.toString() ?? 'Año desconocido';

        // ✅ Obtener nombre completo del cliente con apellidos
        final clienteData = moto['clientes'] ?? {};
        final nombre = clienteData['nombre'] ?? 'Cliente desconocido';
        final apellido1 = clienteData['apellido1'] ?? '';
        final apellido2 = clienteData['apellido2'] ?? '';
        final cliente = '$nombre $apellido1 $apellido2'.trim();

        final images = (moto['image_url'] as String?)?.split(',') ?? [];

        return Card(
          margin: const EdgeInsets.all(10),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Matrícula: $matricula',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text('Marca: $marca', style: const TextStyle(fontSize: 14)),
                Text('Modelo: $modelo', style: const TextStyle(fontSize: 14)),
                Text('Año: $anio', style: const TextStyle(fontSize: 14)),
                Text(
                  'Cliente: $cliente',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
                const SizedBox(height: 10),
                if (images.isNotEmpty)
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: images
                        .map((url) => Image.network(url, width: 100, height: 100, fit: BoxFit.cover))
                        .toList(),
                  )
                else
                  const Text("No hay imágenes disponibles."),
              ],
            ),
          ),
        );
      },
    );
  }
}
