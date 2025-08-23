import 'package:flutter/material.dart';
import 'api_servicio.dart';
import 'coctel.dart';
import 'pantalla_detalle_coctel.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Buscador de Cócteles'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _searchController = TextEditingController();
  Future<List<Coctel>>? _futureCocteles;
  bool _isLoading = false;

  void _buscarCocteles() {
    if (_searchController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
        _futureCocteles = ApiServicio.buscarCoctelesPorNombre(_searchController.text);
      });
      // Cuando el futuro se complete, paramos el indicador de carga
      _futureCocteles!.whenComplete(() => setState(() => _isLoading = false));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          // --- Barra de Búsqueda ---
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Nombre del cóctel',
                hintText: 'Ej: Margarita, Mojito...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _buscarCocteles,
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _buscarCocteles(), // Permite buscar con la tecla Enter
            ),
          ),
          // --- Indicador de Carga ---
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          // --- Resultados ---
          Expanded(
            child: _futureCocteles == null
                ? const Center(child: Text('Escribe en la barra para buscar un cóctel.'))
                : FutureBuilder<List<Coctel>>(
                    future: _futureCocteles,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting && !_isLoading) {
                        // No mostramos el loader aquí si ya lo mostramos arriba
                        return const SizedBox.shrink();
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No se encontraron cócteles con ese nombre.'));
                      } else {
                        final cocteles = snapshot.data!;
                        return ListView.builder(
                          itemCount: cocteles.length,
                          itemBuilder: (ctx, index) {
                            final coctel = cocteles[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                              child: ListTile(
                                leading: Image.network(
                                  coctel.imagenUrl + '/preview',
                                  width: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.local_bar, color: Colors.grey);
                                  },
                                ),
                                title: Text(coctel.nombre),
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
                        );
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
