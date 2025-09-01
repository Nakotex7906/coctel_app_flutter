import 'package:coctel_app/core/services/cocteles_creados_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/theme_provider.dart';
import 'core/services/favoritos_manager.dart';
import 'features/ajustes/presentation/pantalla_ajustes.dart';
import 'features/cocteles/presentation/pantalla_busqueda.dart';
import 'features/cocteles/presentation/pantalla_inicio.dart';
import 'features/cocteles/presentation/pantalla_favoritos.dart';
import 'features/cocteles/presentation/pantalla_crear_coctel.dart';
import 'features/design/pantalla_carga.dart';
import 'features/design/pantalla_logo.dart'; // Importa la pantalla del logo

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FavoritosManager()),
        ChangeNotifierProvider(create: (_) => CoctelesCreadosManager()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'BlueMix',
          themeMode: themeProvider.themeMode,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            brightness: Brightness.light,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(color: Color(0xFF010D00)),
            ),
            scaffoldBackgroundColor: const Color(0xFFF2F2F2),
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.blue,
            brightness: Brightness.dark,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.white),
            ),
            scaffoldBackgroundColor: const Color(0xFF121212),
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: const InitialLoaderScreen(), // Pantalla que maneja la secuencia de carga
        );
      },
    );
  }
}

class InitialLoaderScreen extends StatefulWidget {
  const InitialLoaderScreen({super.key});

  @override
  InitialLoaderScreenState createState() => InitialLoaderScreenState();
}

class InitialLoaderScreenState extends State<InitialLoaderScreen> {
  Future<void> _initializeApp() async {
    // Simular un tiempo de carga inicial
    await Future.delayed(const Duration(seconds: 2));

    // Cargar datos asíncronos si es necesario
    if (!mounted) return;
    final favoritosManager = Provider.of<FavoritosManager>(context, listen: false);
    await favoritosManager.cargarFavoritos();
    final coctelesCreadosManager = Provider.of<CoctelesCreadosManager>(context, listen: false);
    await coctelesCreadosManager.cargarCoctelesCreados();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // Si la inicialización está completa, pasa a la pantalla del logo
          return const PantallaLogoWithDelay();
        } else {
          // Mientras se inicializa, muestra la pantalla de carga
          return const PantallaCarga();
        }
      },
    );
  }
}

class PantallaLogoWithDelay extends StatefulWidget {
  const PantallaLogoWithDelay({super.key});

  @override
  PantallaLogoWithDelayState createState() => PantallaLogoWithDelayState();
}

class PantallaLogoWithDelayState extends State<PantallaLogoWithDelay> {
  @override
  void initState() {
    super.initState();
    _navigateToMain();
  }

  void _navigateToMain() async {
    // Espera 3 segundos para mostrar el logo
    await Future.delayed(const Duration(seconds: 3));

    // Navega a la pantalla principal y la reemplaza
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const PantallaPrincipal(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PantallaLogo(); // Elimina el 'const'
  }
}

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => PantallaPrincipalState();
}

class PantallaPrincipalState extends State<PantallaPrincipal> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    const PantallaInicio(),
    const PantallaBusqueda(),
    const PantallaFavoritos(),
    const PantallaAjustes(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final bottomBarColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomAppBar(
        color: bottomBarColor,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildNavItem(Icons.home, 'Inicio', 0, isDarkMode),
              _buildNavItem(Icons.search, 'Buscar', 1, isDarkMode),
              const SizedBox(width: 48.0),
              _buildNavItem(Icons.favorite, 'Favoritos', 2, isDarkMode),
              _buildNavItem(Icons.settings, 'Ajustes', 3, isDarkMode),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PantallaCrearCoctel()),
          );
        },
        backgroundColor: const Color(0xFF05AFF2),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, bool isDarkMode) {
    final activeColor = isDarkMode ? const Color(0xFF05AFF2) : const Color(0xFF05AFF2);
    final inactiveColor = isDarkMode ? Colors.white70 : Colors.grey.shade600;

    bool isSelected = _selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              color: isSelected ? activeColor : inactiveColor,
              size: 24,
            ),
            AnimatedOpacity(
              opacity: isSelected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: activeColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
