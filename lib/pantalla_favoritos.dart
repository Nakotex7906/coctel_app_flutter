import 'package:flutter/material.dart';
import 'coctel.dart';
import 'pantalla_detalle_coctel.dart';

class PantallaFavoritos extends StatefulWidget {
  final List<Coctel> favoritos;

  const PantallaFavoritos({super.key, required this.favoritos});

  @override
  State<PantallaFavoritos> createState() => _PantallaFavoritosState();
}

class _PantallaFavoritosState extends State<PantallaFavoritos> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Mis Favoritos",
          style: TextStyle(color: Colors.cyanAccent),
        ),
        centerTitle: true,
      ),
      body: widget.favoritos.isEmpty
          ? const Center(
        child: Text(
          "No tienes cócteles favoritos aún",
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.favoritos.length,
        itemBuilder: (context, index) {
          final coctel = widget.favoritos[index];
          return Card(
            color: Colors.grey[900],
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  coctel.imagenUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                coctel.nombre,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.cyanAccent),
                onPressed: () {
                  setState(() {
                    widget.favoritos.removeAt(index);
                  });
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PantallaDetalleCoctel(coctel: coctel),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
