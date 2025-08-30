import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/coctel.dart';
import '../../../core/services/favoritos_manager.dart';
import '../../../core/services/theme_provider.dart';

class PantallaDetalleCoctel extends StatefulWidget {
  final Coctel coctel;

  const PantallaDetalleCoctel({Key? key, required this.coctel}) : super(key: key);

  @override
  State<PantallaDetalleCoctel> createState() => _PantallaDetalleCoctelState();
}

class _PantallaDetalleCoctelState extends State<PantallaDetalleCoctel> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    final scaffoldColor = isDarkMode ? const Color(0xFF121212) : Colors.white;
    final appBarColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final hintColor = isDarkMode ? Colors.white60 : Colors.grey.shade600;
    final contentCardColor = isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFF2196F3);

    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          Consumer<FavoritosManager>(
            builder: (context, favoritosManager, child) {
              final esFavorito = favoritosManager.esFavorito(widget.coctel.id);
              return IconButton(
                icon: Icon(
                  esFavorito ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                ),
                onPressed: () {
                  if (esFavorito) {
                    favoritosManager.eliminarFavorito(widget.coctel);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Eliminado de favoritos")),
                    );
                  } else {
                    favoritosManager.agregarFavorito(widget.coctel);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Agregado a favoritos")),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag: widget.coctel.id,
                  child: Image.network(
                    widget.coctel.imagenUrl,
                    width: double.infinity,
                    height: 350,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: double.infinity,
                      height: 350,
                      color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                      child: Icon(Icons.broken_image, size: 80, color: hintColor),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    decoration: BoxDecoration(
                      color: contentCardColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode ? Colors.black54 : Colors.black26,
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.coctel.nombre,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.coctel.alcohol.isNotEmpty ? "Por ${widget.coctel.alcohol}" : "Cóctel",
                          style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode ? Colors.white70 : Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Container(
              color: scaffoldColor,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "Ingredientes",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...widget.coctel.ingredientes.map((ing) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      "• ${ing.cantidad.isNotEmpty ? "${ing.cantidad} " : ""}${ing.nombre}",
                      style: TextStyle(fontSize: 16, color: textColor, height: 1.5),
                    ),
                  )),
                  const SizedBox(height: 20),
                  Text(
                    "Instrucciones",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.coctel.instrucciones,
                    style: TextStyle(fontSize: 16, color: textColor, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}