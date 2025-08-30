import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/coctel.dart';
import '../../../core/services/api_servicio.dart';
import '../../../core/services/theme_provider.dart';
import 'pantalla_detalle_coctel.dart';

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  _PantallaInicioState createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  late Future<List<Coctel>> recomendados;
  late Future<List<Coctel>> populares;
  late Future<List<Coctel>> filtrados;
  String _nivelSeleccionado = "";

  @override
  void initState() {
    super.initState();
    recomendados = ApiServicio.coctelAleatorio();
    populares = ApiServicio.buscarCoctelesPorLetra("a");
    filtrados = populares;
  }

  void _filtrarPorNivel(String nivel) {
    if (_nivelSeleccionado == nivel) {
      setState(() {
        _nivelSeleccionado = "";
        filtrados = populares;
      });
    } else {
      setState(() {
        _nivelSeleccionado = nivel;
        switch (nivel) {
          case "Suave":
            filtrados = ApiServicio.buscarCoctelesPorAlcohol("Vodka");
            break;
          case "Medio":
            filtrados = ApiServicio.buscarCoctelesPorAlcohol("Gin");
            break;
          case "Fuerte":
            filtrados = ApiServicio.buscarCoctelesPorAlcohol("Rum");
            break;
          default:
            filtrados = populares;
        }
      });
    }
  }

  Color _colorNivel(String nivel) {
    if (_nivelSeleccionado == nivel) {
      return Colors.black;
    }
    switch (nivel) {
      case "Suave":
        return const Color(0xFF81C784); // Verde más suave
      case "Medio":
        return const Color(0xFFFFD54F); // Amarillo anaranjado más suave
      case "Fuerte":
        return const Color(0xFFE57373); // Rojo más suave
      default:
        return Colors.grey;
    }
  }

  Color _colorTexto(String nivel) {
    if (_nivelSeleccionado == nivel) {
      return Colors.white;
    }
    return Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF010D00);
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final backgroundColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFF2F2F2);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER - Se mantiene el color azul fijo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                decoration: const BoxDecoration(
                  color: Color(0xFF05AFF2), // Azul fijo de la marca
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("BlueMix",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 12),
                          Text(
                            "Explora, descubre y crea tus cócteles favoritos con los ingredientes que tienes a mano",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        "assets/images/LogoSinFondo.png",
                        width: 96,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Coctel Recomendado
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text("Recomendado",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor)),
              ),
              const SizedBox(height: 12),
              FutureBuilder<List<Coctel>>(
                future: recomendados,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No se pudo cargar el cóctel recomendado.', style: TextStyle(color: textColor)));
                  }
                  final coctel = snapshot.data!.first;
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => PantallaDetalleCoctel(coctel: coctel)),
                    ),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: isDarkMode ? Colors.black54 : Colors.black12,
                              blurRadius: 8,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              coctel.imagenUrl,
                              width: 130,
                              height: 130,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(coctel.nombre,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: textColor)),
                                const SizedBox(height: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: coctel.ingredientes
                                      .map((e) => Text(
                                    e.nombre,
                                    style: TextStyle(
                                        fontSize: 14, color: isDarkMode ? Colors.white70 : Colors.black54),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 25),

              // Nivel de alcohol
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text("Nivel de alcohol",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor)),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ["Suave", "Medio", "Fuerte"]
                    .map((nivel) => ElevatedButton(
                  onPressed: () => _filtrarPorNivel(nivel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _colorNivel(nivel),
                    foregroundColor: _colorTexto(nivel),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 14),
                  ),
                  child: Text(nivel,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ))
                    .toList(),
              ),

              const SizedBox(height: 25),
              const SizedBox(height: 25),

              // Populares
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text("Populares",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor)),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 190,
                child: FutureBuilder<List<Coctel>>(
                  future: filtrados,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No se encontraron cócteles.', style: TextStyle(color: textColor)));
                    }
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final coctel = snapshot.data![index];
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => PantallaDetalleCoctel(coctel: coctel)),
                          ),
                          child: Container(
                            width: 240,
                            margin: const EdgeInsets.only(left: 16),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                    color: isDarkMode ? Colors.black54 : Colors.black12,
                                    blurRadius: 8,
                                    offset: const Offset(0, 4))
                              ],
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.horizontal(
                                      left: Radius.circular(16)),
                                  child: Image.network(
                                    coctel.imagenUrl,
                                    width: 110,
                                    height: 190,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                coctel.nombre,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: textColor),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.star_border,
                                                  color: Colors.amber),
                                              onPressed: () {
                                                // TODO: favoritos
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: coctel.ingredientes
                                              .map((e) => Text(
                                            e.nombre,
                                            style: TextStyle(
                                                fontSize: 13, color: isDarkMode ? Colors.white70 : Colors.black54),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ))
                                              .toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}