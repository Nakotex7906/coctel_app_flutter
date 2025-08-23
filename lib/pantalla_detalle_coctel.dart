import 'package:flutter/material.dart';
import 'coctel.dart';

class PantallaDetalleCoctel extends StatelessWidget {
  final Coctel coctel;

  const PantallaDetalleCoctel({super.key, required this.coctel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(coctel.nombre),
      ),
      body: SingleChildScrollView( // Permite hacer scroll si el contenido es muy largo
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Mostramos la imagen desde la URL
            if (coctel.imagenUrl.isNotEmpty)
              Center(
                child: Image.network(
                  coctel.imagenUrl,
                  loadingBuilder: (context, child, progress) {
                    return progress == null ? child : const CircularProgressIndicator();
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.local_bar, size: 100, color: Colors.grey); // Icono si falla la imagen
                  },
                ),
              ),
            const SizedBox(height: 16),
            Text(
              coctel.nombre,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Text(
              'Ingredientes:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            // Usamos un Widget más estructurado para los ingredientes
            for (var ingrediente in coctel.ingredientes)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text('• ${ingrediente.cantidad} ${ingrediente.nombre}'),
              ),
            const SizedBox(height: 24),
            Text(
              'Instrucciones:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            // La API devuelve las instrucciones como un solo texto
            Text(coctel.instrucciones),
          ],
        ),
      ),
    );
  }
}
