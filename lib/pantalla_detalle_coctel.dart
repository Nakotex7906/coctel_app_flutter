import 'package:flutter/material.dart';
import 'coctel.dart'; // Asegúrate de que la ruta de importación sea correcta

class PantallaDetalleCoctel extends StatelessWidget {
  final Coctel coctel;

  const PantallaDetalleCoctel({super.key, required this.coctel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(coctel.nombre),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Image.network(coctel.imagenUrl), // Descomenta si tienes URLs de imágenes válidas
            const SizedBox(height: 8),
            Text(
              coctel.nombre,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Ingredientes:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (var ingrediente in coctel.ingredientes)
              Text('- ${ingrediente.nombre}: ${ingrediente.cantidad}'), // Modificado para mostrar nombre y cantidad del ingrediente
            const SizedBox(height: 16),
            Text(
              'Instrucciones:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(coctel.instrucciones.join('\n')), // Modificado para unir la lista de instrucciones
          ],
        ),
      ),
    );
  }
}