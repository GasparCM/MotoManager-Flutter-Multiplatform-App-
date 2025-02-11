import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EstadisticasScreen extends StatefulWidget {
  const EstadisticasScreen({Key? key}) : super(key: key);

  @override
  _EstadisticasScreenState createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends State<EstadisticasScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchEstadisticas();
  }

  Future<void> _fetchEstadisticas() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final firstDayOfQuarter = DateTime(now.year, ((now.month - 1) ~/ 3) * 3 + 1, 1);

      final ingresosHoy = await supabase
          .from('facturas')
          .select('total')
          .gte('fecha_emision', now.toIso8601String());

      final ingresosMes = await supabase
          .from('facturas')
          .select('total')
          .gte('fecha_emision', firstDayOfMonth.toIso8601String());

      final ingresosTrimestre = await supabase
          .from('facturas')
          .select('total')
          .gte('fecha_emision', firstDayOfQuarter.toIso8601String());

      final clientesRegistrados = await supabase
          .from('clientes')
          .count();

      final motosEnTaller = await supabase
          .from('motos')
          .count();

      setState(() {
        _stats = {
          'ingresosHoy': _sumarTotales(ingresosHoy),
          'ingresosMes': _sumarTotales(ingresosMes),
          'ingresosTrimestre': _sumarTotales(ingresosTrimestre),
          'clientesRegistrados': clientesRegistrados,
          'motosEnTaller': motosEnTaller,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  double _sumarTotales(List<dynamic> facturas) {
    return facturas.fold(0.0, (sum, factura) => sum + (factura['total'] ?? 0.0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas del Taller')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error: $_error'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStatTile('Ingresos Hoy', '€${_stats['ingresosHoy'].toStringAsFixed(2)}', Icons.attach_money),
            _buildStatTile('Ingresos del Mes', '€${_stats['ingresosMes'].toStringAsFixed(2)}', Icons.calendar_month),
            _buildStatTile('Ingresos del Trimestre', '€${_stats['ingresosTrimestre'].toStringAsFixed(2)}', Icons.pie_chart),
            _buildStatTile('Clientes Registrados', _stats['clientesRegistrados'].toString(), Icons.people),
            _buildStatTile('Motos en el Taller', _stats['motosEnTaller'].toString(), Icons.motorcycle),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent, size: 30),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        trailing: SizedBox(
          width: 100,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
