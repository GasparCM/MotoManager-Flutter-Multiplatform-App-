import 'package:flutter/material.dart';
import 'main.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  _ClientesScreenState createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  List<Map<String, dynamic>> _clientes = [];
  List<Map<String, dynamic>> _clientesFiltrados = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchClientes();
    _searchController.addListener(_filterClientes);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchClientes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await supabase.from('clientes').select('dni, nombre, apellido1, apellido2, telefono, email');

      setState(() {
        _clientes = List<Map<String, dynamic>>.from(response);
        _clientesFiltrados = _clientes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterClientes() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _clientesFiltrados = _clientes.where((cliente) {
        final nombreCompleto = "${cliente['nombre']} ${cliente['apellido1']} ${cliente['apellido2']}".toLowerCase();
        final dni = cliente['dni'].toLowerCase();

        return nombreCompleto.contains(query) || dni.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text('Error: $_error'));

    return Column(
      children: [
        // 🔍 BARRA DE BÚSQUEDA
        Padding(
          padding: const EdgeInsets.only(right: 10.0, left: 10, top: 50),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, color: Colors.white),
              hintText: "Buscar por nombre o DNI...",
              filled: true,
              fillColor: Colors.black54,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              hintStyle: const TextStyle(color: Colors.white70),
            ),
            style: const TextStyle(color: Colors.white),
          ),
        ),

        // 📋 LISTA DE CLIENTES
        Expanded(
          child: ListView.builder(
            itemCount: _clientesFiltrados.length,
            itemBuilder: (context, index) {
              final cliente = _clientesFiltrados[index];
              final nombreCompleto = "${cliente['nombre']} ${cliente['apellido1']} ${cliente['apellido2']}";
              final telefono = cliente['telefono'] ?? 'No disponible';

              return Card(
                margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                elevation: 5,
                child: ListTile(
                  title: Text(nombreCompleto, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  subtitle: Text('Teléfono: $telefono'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    _showClienteDetails(cliente['dni'], nombreCompleto);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showClienteDetails(String dniCliente, String nombreCliente) async {
    // Obtener detalles del cliente
    final response = await supabase
        .from('clientes')
        .select('dni, nombre, apellido1, apellido2, telefono, email')
        .eq('dni', dniCliente)
        .maybeSingle();

    if (response == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al obtener detalles del cliente')));
      return;
    }

    final String telefono = response['telefono'] ?? 'No disponible';
    final String email = response['email'] ?? 'No disponible';

    // Obtener facturas del cliente
    final facturasResponse = await supabase
        .from('facturas')
        .select('id_factura, fecha_emision, total, matricula_moto')
        .eq('dni_cliente', dniCliente);

    List<Map<String, dynamic>> facturas = List<Map<String, dynamic>>.from(facturasResponse);

    // Obtener motos registradas
    final motosResponse = await supabase
        .from('motos')
        .select('matricula, marca, modelo')
        .eq('dni_cliente', dniCliente);

    List<Map<String, dynamic>> motos = List<Map<String, dynamic>>.from(motosResponse);

    // Mostrar modal con los detalles
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nombreCliente, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 10),
                Text('📞 Teléfono: $telefono', style: const TextStyle(fontSize: 16, color: Colors.black)),
                Text('📧 Email: $email', style: const TextStyle(fontSize: 16, color: Colors.black)),
                const Divider(height: 20, thickness: 2),

                // 🔹 Tabla de Facturas con Scroll Horizontal
                const Text('🧾 Facturas:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                facturas.isEmpty
                    ? const Text('No hay facturas registradas.', style: TextStyle(color: Colors.red))
                    : SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // 🔹 Agregado Scroll Horizontal
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('ID', style: TextStyle(color: Colors.black))),
                      DataColumn(label: Text('Fecha', style: TextStyle(color: Colors.black))),
                      DataColumn(label: Text('Total', style: TextStyle(color: Colors.black))),
                      DataColumn(label: Text('Moto', style: TextStyle(color: Colors.black))),
                      DataColumn(label: Text('Acción', style: TextStyle(color: Colors.black))),
                    ],
                    rows: facturas.map((factura) {
                      return DataRow(cells: [
                        DataCell(Text(factura['id_factura'].toString(), style: TextStyle(color: Colors.black))),
                        DataCell(Text(factura['fecha_emision'].toString(), style: TextStyle(color: Colors.black))),
                        DataCell(Text('${factura['total']}€', style: TextStyle(color: Colors.black))),
                        DataCell(Text(factura['matricula_moto'] ?? 'Desconocida')),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.visibility, color: Colors.blue),
                            onPressed: () => _showFacturaDetails(factura['id_factura']),
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 10),
                const Text('🏍️ Motos Registradas:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                motos.isEmpty
                    ? const Text('No hay motos registradas.', style: TextStyle(color: Colors.red))
                    : Column(
                  children: motos.map((moto) {
                    return ListTile(
                      title: Text(moto['matricula'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                      subtitle: Text('${moto['marca']} - ${moto['modelo']}'),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cerrar'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  void _showFacturaDetails(int idFactura) async {
    // Obtener los detalles de la factura
    final facturaResponse = await supabase
        .from('facturas')
        .select('id_factura, fecha_emision, total, matricula_moto, mano_obra, dni_cliente')
        .eq('id_factura', idFactura)
        .maybeSingle();

    if (facturaResponse == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al obtener la factura')));
      return;
    }

    final String fechaEmision = facturaResponse['fecha_emision'].toString();
    final double total = facturaResponse['total'] ?? 0.0;
    final String matriculaMoto = facturaResponse['matricula_moto'] ?? 'Desconocida';
    final String manoObra = facturaResponse['mano_obra'] ?? 'No especificado';
    final String dniCliente = facturaResponse['dni_cliente'] ?? 'Desconocido';

    // Obtener los detalles de los productos/servicios de la factura
    final detallesResponse = await supabase
        .from('detallesfactura')
        .select('descripcion, cantidad, precio_unitario, subtotal')
        .eq('id_factura', idFactura);

    List<Map<String, dynamic>> detalles = List<Map<String, dynamic>>.from(detallesResponse);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detalles de la Factura',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 10),
                Text('📅 Fecha de emisión: $fechaEmision', style: const TextStyle(fontSize: 16,color: Colors.black)),
                Text('🏍️ Moto: $matriculaMoto', style: const TextStyle(fontSize: 16,color: Colors.black)),
                Text('🛠️ Mano de obra: $manoObra', style: const TextStyle(fontSize: 16,color: Colors.black)),
                const Divider(height: 20, thickness: 2),

                // 📜 Tabla de detalles de factura
                const Text('🧾 Productos/Servicios:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.black)),
                detalles.isEmpty
                    ? const Text('No hay detalles registrados.', style: TextStyle(color: Colors.red))
                    : DataTable(
                  columnSpacing: 20, // 🔹 Ajusta el espacio entre columnas
                  columns: const [
                    DataColumn(
                      label: Expanded(
                        child: Text('Descripción', style: TextStyle(color: Colors.black)),
                      ),
                    ),
                    DataColumn(label: Text('Cantidad', style: TextStyle(color: Colors.black))),
                    DataColumn(label: Text('Precio', style: TextStyle(color: Colors.black))),
                  ],
                  rows: detalles.map((detalle) {
                    return DataRow(cells: [
                      DataCell(
                        Container(
                          width: 150, // 🔹 Ajusta el ancho de la celda de descripción
                          child: Text(
                            detalle['descripcion'] ?? 'Desconocido',
                            style: const TextStyle(color: Colors.black),
                            softWrap: true, // 🔹 Permite que el texto se divida en varias líneas
                          ),
                        ),
                      ),
                      DataCell(Text(detalle['cantidad'].toString(), style: TextStyle(color: Colors.black))),
                      DataCell(Text('${detalle['precio_unitario']}€', style: TextStyle(color: Colors.black))),
                    ]);
                  }).toList(),
                ),


                const SizedBox(height: 10),
                Text(
                  '💰 Total: ${total.toStringAsFixed(2)}€',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                ),

                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cerrar'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


