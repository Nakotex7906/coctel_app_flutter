import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coctel_app/core/models/coctel.dart';
import 'pantalla_detalle_coctel.dart';
import '../../../core/services/favoritos_manager.dart';
import '../../../core/services/theme_provider.dart';

class PantallaFavoritos extends StatelessWidget {
  const PantallaFavoritos({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    final scaffoldColor = isDarkMode ? const Color(0xFF121212) : Colors.white;
    final appBarColor = isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFF2196F3);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final hintColor = isDarkMode ? Colors.white60 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        title: Text(
          "Mis Favoritos",
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.white),
        ),
        backgroundColor: appBarColor,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.white,
        ),
      ),
      body: Consumer<FavoritosManager>(
        builder: (context, favoritosManager, child) {
          final List<Coctel> favoritos = favoritosManager.favoritos;

          if (favoritos.isEmpty) {
            return Center(
              child: Text(
                "No tienes cócteles favoritos aún",
                style: TextStyle(color: hintColor, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favoritos.length,
            itemBuilder: (context, index) {
              final coctel = favoritos[index];
              return Dismissible(
                key: Key(coctel.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.redAccent,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  favoritosManager.eliminarFavorito(coctel);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("${coctel.nombre} eliminado de favoritos"),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PantallaDetalleCoctel(coctel: coctel),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode ? Colors.black54 : Colors.black12,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _buildCoctelImage(coctel, width: 100, height: 100, hintColor: hintColor, isDarkMode: isDarkMode),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                coctel.nombre,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: coctel.ingredientes
                                    .take(2)
                                    .map((e) => Text(
                                  e.nombre,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: hintColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 20,
                          color: hintColor,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCoctelImage(Coctel coctel, {required double width, required double height, required Color hintColor, required bool isDarkMode}) {
    if (coctel.isLocal && coctel.imagenUrl.isNotEmpty) {
      return Image.file(
        File(coctel.imagenUrl),
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: width,
          height: height,
          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
          child: Icon(Icons.broken_image, color: hintColor, size: 40),
        ),
      );
    } else if (coctel.imagenUrl.isNotEmpty) {
      return Image.network(
        coctel.imagenUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: width,
          height: height,
          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
          child: Icon(Icons.broken_image, color: hintColor, size: 40),
        ),
      );
    } else {
      return Container(
        width: width,
        height: height,
        color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
        child: Icon(Icons.no_photography, color: hintColor, size: 40),
      );
    }
  }
}
