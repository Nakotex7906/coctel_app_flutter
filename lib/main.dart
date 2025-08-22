
import 'package:flutter/material.dart';
import 'datos_cocteles.dart';
import 'pantalla_detalle_coctel.dart'; // Importa la nueva pantalla

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recetas de Cócteles',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal), // Un color más temático
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Mis Cócteles'),
    );
  }
}

class MyHomePage extends StatelessWidget { // Cambiado a StatelessWidget por ahora
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: ListView.builder(
        itemCount: coctelesDeEjemplo.length,
        itemBuilder: (ctx, index) {
          final coctel = coctelesDeEjemplo[index];
          return Card( // Usamos Card para un mejor aspecto
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            child: ListTile(
              // leading: Image.network(coctel.imagenUrl), // Descomenta si tienes URLs de imágenes válidas
              title: Text(coctel.nombre),
              // subtitle: Text('${coctel.ingredientes.length} ingredientes'), // Opcional
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PantallaDetalleCoctel(coctel: coctel),
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
