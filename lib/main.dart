import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'GalleryScreen.dart';
import 'ClientesScreen.dart';
import 'InventarioScreen.dart';
import 'KanbanScreen.dart';
import 'EstadisticasScreen.dart';
import 'UploadScreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'xxx',//remplazar con la url de vuestro proyecto de supabase
    anonKey: 'xxxx',//remplazar con a anonkey de supabase de vuestro proyecto
  );

  final prefs = await SharedPreferences.getInstance();
  final bool isDarkMode = prefs.getBool('isDarkMode') ?? true;

  runApp(MyApp(isDarkMode: isDarkMode));
}

final supabase = Supabase.instance.client;

class MyApp extends StatefulWidget {
  final bool isDarkMode;
  const MyApp({super.key, required this.isDarkMode});

  static _MyAppState? of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<MyAppState>()?.data;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  // 🔹 Toggle Theme and Save Preference
  void toggleTheme() async {
    final newTheme = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setState(() {
      _themeMode = newTheme;
    });

    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', newTheme == ThemeMode.dark);
  }

  @override
  Widget build(BuildContext context) {
    return MyAppState(
      data: this,
      child: MaterialApp(
        title: 'Gaspar Motos',
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: _themeMode,
        home: const MainScreen(),
      ),
    );
  }
}

// 🔹 Provides access to `toggleTheme`
class MyAppState extends InheritedWidget {
  final _MyAppState data;
  const MyAppState({super.key, required this.data, required Widget child}) : super(child: child);

  @override
  bool updateShouldNotify(MyAppState oldWidget) => true;
}

// ✅ Main Screen with Bottom Navigation Bar
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const GalleryScreen(),
    const ClientesScreen(),
    const KanbanScreen(),
    const InventarioScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: isDarkMode ? Colors.black : Colors.white, // 🔹 Cambia el fondo
        selectedItemColor: isDarkMode ? Colors.white : Colors.black, // 🔹 Cambia el color de iconos seleccionados
        unselectedItemColor: isDarkMode ? Colors.white70 : Colors.black54, // 🔹 Cambia los no seleccionados
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.image), label: "Galería"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Clientes"),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: "Tareas"),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: "Inventario"),
        ],
      ),
    );
  }
}
// ✅ Home Screen with Recent Clients & Theme Toggle
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _recentClients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecentClients();
  }

  // 🔹 Fetch recent clients (Last 5)
  Future<void> _fetchRecentClients() async {
    final response = await supabase
        .from('clientes')
        .select('nombre, telefono')
        .order('dni', ascending: false)
        .limit(5);

    setState(() {
      _recentClients = List<Map<String, dynamic>>.from(response);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gaspar Motos App"),
        centerTitle: true,
        actions: [
          // 🔹 Theme Toggle Button
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark ? Icons.wb_sunny : Icons.nightlight_round,
            ),
            onPressed: () => MyApp.of(context)?.toggleTheme(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ✅ Logo
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Image.asset('assets/logo.png', height: 100),
            ),
            const SizedBox(height: 30),

            // ✅ Statistics Button
            _buildUtilityButton(
              context,
              icon: Icons.bar_chart,
              label: "Ver Estadísticas",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EstadisticasScreen()),
                );
              },
            ),

            const SizedBox(height: 20),

            // ✅ Upload Photos Button
            _buildUtilityButton(
              context,
              icon: Icons.camera_alt,
              label: "Subir Fotos",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UploadScreen()),
                );
              },
            ),

            const SizedBox(height: 30),

            // 🔹 Recent Clients Section
            const Text(
              "📋 Últimos clientes:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _recentClients.isNotEmpty
                ? Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _recentClients.length,
                itemBuilder: (context, index) {
                  final client = _recentClients[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      leading: const Icon(Icons.person, color: Colors.green),
                      title: Text(client['nombre']),
                      subtitle: Text("📞 ${client['telefono']}"),
                    ),
                  );
                },
              ),
            )
                : const Text("No hay clientes recientes."),
          ],
        ),
      ),
    );
  }

  // 🔹 Button Widget
  Widget _buildUtilityButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return SizedBox(
      width: 250,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
        label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}
