import 'package:coctel_app/core/models/coctel.dart';
import 'package:coctel_app/core/services/cocteles_creados_manager.dart';
import 'package:coctel_app/features/cocteles/presentation/pantalla_crear_coctel.dart';
import 'package:coctel_app/features/cocteles/presentation/pantalla_detalle_coctel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:coctel_app/core/services/theme_provider.dart';

class PantallaMisCoctelesCreados extends StatelessWidget {
  const PantallaMisCoctelesCreados({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF010D00);
    final scaffoldColor = isDarkMode ? const Color(0xFF121212) : Colors.white;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final hintColor = isDarkMode ? Colors.white60 : Colors.grey;

    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        title: Text('Mis Cócteles Creados', style: TextStyle(color: textColor)),
        backgroundColor: scaffoldColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Consumer<CoctelesCreadosManager>(
        builder: (context, manager, child) {
          if (manager.coctelesCreados.isEmpty) {
            return Center(
              child: Text(
                'Aún no has creado ningún cóctel.',
                style: TextStyle(color: textColor, fontSize: 16),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: manager.coctelesCreados.length,
            itemBuilder: (context, index) {
              final coctel = manager.coctelesCreados[index];
              return _buildCoctelCard(context, coctel, manager, cardColor, textColor, hintColor);
            },
          );
        },
      ),
    );
  }

  Widget _buildCoctelCard(
      BuildContext context,
      Coctel coctel,
      CoctelesCreadosManager manager,
      Color cardColor,
      Color textColor,
      Color hintColor,
      ) {
    return Card(
      color: cardColor,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PantallaDetalleCoctel(coctel: coctel),
                  ),
                );
              },
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: coctel.imagenUrl.isNotEmpty && coctel.imagenUrl.startsWith('/') 
                        ? Image.file(
                      File(coctel.imagenUrl),
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(width: 60, height: 60, color: Colors.grey.shade200, child: Icon(Icons.broken_image, color: hintColor)),
                    )
                        : Image.network( 
                      coctel.imagenUrl, 
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(width: 60, height: 60, color: Colors.grey.shade200, child: Icon(Icons.broken_image, color: hintColor)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      coctel.nombre,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: Icon(Icons.edit, color: Theme.of(context).primaryColor, size: 20),
                  label: Text('Editar', style: TextStyle(color: Theme.of(context).primaryColor)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PantallaCrearCoctel(coctelParaEditar: coctel),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  icon: Icon(Icons.delete, color: Colors.redAccent, size: 20),
                  label: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
                  onPressed: () => _confirmarEliminar(context, coctel, manager, textColor, cardColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarEliminar(BuildContext context, Coctel coctel, CoctelesCreadosManager manager, Color textColor, Color dialogBackgroundColor) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: dialogBackgroundColor,
          title: Text('Confirmar Eliminación', style: TextStyle(color: textColor)),
          content: Text('¿Estás seguro de que quieres eliminar "${coctel.nombre}"?', style: TextStyle(color: textColor)),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar', style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            TextButton(
              child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
              onPressed: () {
                manager.eliminarCoctel(coctel.id);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('"${coctel.nombre}" eliminado.', style: TextStyle(color: textColor)), backgroundColor: dialogBackgroundColor),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
