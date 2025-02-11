import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'main.dart';

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({super.key});

  @override
  _InventarioScreenState createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  List<Map<String, dynamic>> _inventario = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInventario();
  }

  Future<void> _fetchInventario() async {
    setState(() {
      _isLoading = true;
    });

    final response = await supabase.from('inventario').select('nombre, cantidad, precio, stock_minimo');
    setState(() {
      _inventario = List<Map<String, dynamic>>.from(response);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return ListView.builder(
      itemCount: _inventario.length,
      itemBuilder: (context, index) {
        final item = _inventario[index];
        return ListTile(
          title: Text(item['nombre']),
          subtitle: Text('Cantidad: ${item['cantidad']} - Precio: ${item['precio']}€'),
          trailing: (item['cantidad'] < item['stock_minimo'])
              ? const Icon(Icons.warning, color: Colors.red)
              : null,
        );
      },
    );
  }
}
