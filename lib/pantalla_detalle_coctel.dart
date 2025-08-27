import 'package:flutter/material.dart';
import 'coctel.dart';

class PantallaDetalleCoctel extends StatelessWidget {
  final Coctel coctel;
  final Function(Coctel)? onFavorito;

  const PantallaDetalleCoctel({super.key, required this.coctel, this.onFavorito});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          coctel.nombre,
          style: const TextStyle(color: Colors.cyanAccent),
        ),
        iconTheme: const IconThemeData(color: Colors.cyanAccent),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del cóctel
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                coctel.imagenUrl,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),

            // Ingredientes
            const Text(
              "Ingredientes",
              style: TextStyle(
                color: Colors.cyanAccent,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...coctel.ingredientes.map(
                  (ing) => Text(
                "- ${ing.cantidad} ${ing.nombre}",
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),

            const SizedBox(height: 20),

            // Instrucciones
            const Text(
              "Preparación",
              style: TextStyle(
                color: Colors.cyanAccent,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              coctel.instrucciones,
              style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.4),
            ),

            const SizedBox(height: 30),

            // Botón de favoritos
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                ),
                onPressed: () {
                  if (onFavorito != null) {
                    onFavorito!(coctel);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Agregado a favoritos"),
                      backgroundColor: Colors.cyanAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.favorite),
                label: const Text(
                  "Agregar a Favoritos",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
