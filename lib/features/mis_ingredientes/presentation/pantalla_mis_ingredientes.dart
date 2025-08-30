import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/theme_provider.dart';
import 'package:coctel_app/features/cocteles/presentation/pantalla_busqueda.dart';

class PantallaMisIngredientes extends StatelessWidget {
  const PantallaMisIngredientes({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    final scaffoldColor = isDarkMode ? const Color(0xFF121212) : Colors.white;
    final appBarColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final hintColor = isDarkMode ? Colors.white60 : Colors.grey.shade600;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey.shade100;

    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        title: Text(
          "Mis Ingredientes",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: appBarColor,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          "Contenido de Mis Ingredientes",
          style: TextStyle(color: hintColor),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Lógica para buscar cócteles con los ingredientes seleccionados
          // Navegar a la pantalla de búsqueda de cócteles
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PantallaBusqueda()),
          );
        },
        label: const Text(
          "Buscar Cócteles",
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(Icons.search, color: Colors.white),
        backgroundColor: const Color(0xFF05AFF2),
      ),
    );
  }
}