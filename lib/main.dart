import 'package:flutter/material.dart';
import 'pantalla_inicio.dart';
import 'pantalla_busqueda.dart';
import 'pantalla_favoritos.dart';
import 'pantalla_carga.dart';

void main() {
  runApp(const MyApp());
}
  class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
  return MaterialApp(
  title: 'App de Cócteles',
  debugShowCheckedModeBanner: false,
  theme: ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.black,
  primaryColor: const Color(0xFF00BCD4), // Celeste
  appBarTheme: const AppBarTheme(
  backgroundColor: Colors.black,
  foregroundColor: Color(0xFF00BCD4),
  elevation: 0,
  ),
  textTheme: const TextTheme(
  bodyMedium: TextStyle(color: Colors.white),
  bodyLarge: TextStyle(color: Colors.white),
  ),
  ),
  home: const PantallaCarga(), // 👈 Pantalla de carga inicial
  );
  }
  }

  class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
  }

  class _PantallaPrincipalState extends State<PantallaPrincipal> {
  int _paginaActual = 0;

  final List<Widget> _pantallas = const [
  PantallaInicio(),
  PantallaBusqueda(),
  PantallaFavoritos(favoritos: [],),
  ];

  @override
  Widget build(BuildContext context) {
  return Scaffold(
  body: _pantallas[_paginaActual],
  bottomNavigationBar: BottomNavigationBar(
  currentIndex: _paginaActual,
  onTap: (index) {
  setState(() {
  _paginaActual = index;
  });
  },
  backgroundColor: Colors.black,
  selectedItemColor: const Color(0xFF00BCD4), // Celeste
  unselectedItemColor: Colors.white70,
  showUnselectedLabels: true,
  items: const [
  BottomNavigationBarItem(
  icon: Icon(Icons.home),
  label: "Inicio",
  ),
  BottomNavigationBarItem(
  icon: Icon(Icons.search),
  label: "Buscar",
  ),
  BottomNavigationBarItem(
  icon: Icon(Icons.favorite),
  label: "Favoritos",
  ),
  ],
  ),
  );
  }
  }
