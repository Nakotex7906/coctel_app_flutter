import 'package:coctel_app/pantalla_detalle_coctel.dart';
import 'package:flutter/material.dart';
import 'api_servicio.dart';
import 'coctel.dart';
import 'pantalla_busqueda.dart';

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  late Future<List<Coctel>> _principiantes;
  late Future<List<String>> _categorias;

  @override
  void initState() {
    super.initState();
    _principiantes = ApiServicio.coctelesPrincipiantes();
    _categorias = ApiServicio.obtenerCategorias();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Mixology App",
          style: TextStyle(
            color: Colors.cyanAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.cyanAccent),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PantallaBusqueda()),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Sección: Cocteles para principiantes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Cócteles para principiantes",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.cyanAccent,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Mostrar más de 8 cocteles
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ListaCoctelesScreen(
                          futureCocteles: ApiServicio.coctelesPrincipiantes(),
                          titulo: "Cócteles fáciles",
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Ver más",
                    style: TextStyle(color: Colors.cyanAccent),
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<Coctel>>(
              future: _principiantes,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text("No se encontraron cócteles", style: TextStyle(color: Colors.white));
                }

                final cocteles = snapshot.data!.take(4).toList();

                return SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: cocteles.length,
                    itemBuilder: (context, index) {
                      final coctel = cocteles[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PantallaDetalleCoctel(coctel: coctel),
                            ),
                          );
                        },
                        child: Container(
                          width: 140,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyanAccent.withOpacity(0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                child: Image.network(
                                  coctel.imagenUrl,
                                  height: 100,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  coctel.nombre,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // 🔹 Sección: Categorías
            const Text(
              "Explora por tipo de alcohol",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.cyanAccent,
              ),
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<String>>(
              future: _categorias,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text("No se encontraron categorías", style: TextStyle(color: Colors.white));
                }

                final categorias = snapshot.data!;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: categorias.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.8,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    final categoria = categorias[index];
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[850],
                        foregroundColor: Colors.cyanAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ListaCoctelesScreen(
                              futureCocteles: ApiServicio.buscarPorCategoria(categoria),
                              titulo: categoria,
                            ),
                          ),
                        );
                      },
                      child: Text(categoria, textAlign: TextAlign.center),
                    );
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class ListaCoctelesScreen extends StatelessWidget {
  final Future<List<Coctel>> futureCocteles;
  final String titulo;

  const ListaCoctelesScreen({
    super.key,
    required this.futureCocteles,
    required this.titulo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(titulo, style: const TextStyle(color: Colors.cyanAccent)),
      ),
      body: FutureBuilder<List<Coctel>>(
        future: futureCocteles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No se encontraron cócteles", style: TextStyle(color: Colors.white)));
          }

          final cocteles = snapshot.data!;
          return ListView.builder(
            itemCount: cocteles.length,
            itemBuilder: (context, index) {
              final coctel = cocteles[index];
              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
          );
        },
      ),
    );
  }
}
