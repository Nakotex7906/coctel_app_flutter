import 'package:flutter/material.dart';

class PantallaBusqueda extends StatefulWidget {
  const PantallaBusqueda({super.key});

  @override
  State<PantallaBusqueda> createState() => _PantallaBusquedaState();
}

class _PantallaBusquedaState extends State<PantallaBusqueda> {
  final TextEditingController _controller = TextEditingController();
  String _query = "";
  String? _filtroAlcohol;

  // Lista de alcoholes disponibles
  final List<String> _tiposAlcohol = [
    "Ron",
    "Vodka",
    "Tequila",
    "Whiskey",
    "Gin",
    "Brandy",
    "Pisco",
    "Mezcal",
  ];

  @override
  Widget build(BuildContext context) {
    final bool mostrarSecciones = _query.isEmpty && _filtroAlcohol == null;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Buscar Cóctel",
          style: TextStyle(color: Colors.cyanAccent),
        ),
        iconTheme: const IconThemeData(color: Colors.cyanAccent),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔎 Buscador
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onChanged: (value) {
                      setState(() {
                        _query = value.trim();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Ejemplo: Mojito",
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon:
                      const Icon(Icons.search, color: Colors.cyanAccent),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.filter_alt, color: Colors.cyanAccent),
                  onPressed: () {
                    _mostrarFiltroAlcohol(context);
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 🔹 Mostrar solo si NO hay búsqueda ni filtro
            if (mostrarSecciones) ...[
              const Text(
                "Sugerencias",
                style: TextStyle(color: Colors.cyanAccent, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  sugerenciaChip("Mojito"),
                  sugerenciaChip("Margarita"),
                  sugerenciaChip("Caipirinha"),
                  sugerenciaChip("Piña Colada"),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Cócteles para principiantes",
                    style: TextStyle(color: Colors.cyanAccent, fontSize: 18),
                  ),
                  Icon(Icons.more_horiz, color: Colors.cyanAccent),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    principianteCard("Cuba Libre"),
                    principianteCard("Gin Tonic"),
                    principianteCard("Tequila Sunrise"),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 📌 Resultados
            Expanded(
              child: ListView(
                children: [
                  if (_query.isNotEmpty || _filtroAlcohol != null) ...[
                    resultadoCard("Negroni",
                        "https://www.thecocktaildb.com/images/media/drink/qgdu971561574065.jpg"),
                    resultadoCard("Limona Corona",
                        "https://www.thecocktaildb.com/images/media/drink/2x8thr1504816928.jpg"),
                    resultadoCard("French Negroni",
                        "https://www.thecocktaildb.com/images/media/drink/nzlyc81605946744.jpg"),
                  ] else
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          "Empieza a escribir o usa un filtro 🍹",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Modal para filtrar alcohol
  void _mostrarFiltroAlcohol(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        TextEditingController buscadorController = TextEditingController();
        List<String> listaFiltrada = List.from(_tiposAlcohol);

        return StatefulBuilder(
          builder: (context, setModalState) {
            void filtrar(String query) {
              setModalState(() {
                listaFiltrada = _tiposAlcohol
                    .where((alcohol) =>
                    alcohol.toLowerCase().contains(query.toLowerCase()))
                    .toList();
              });
            }

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: buscadorController,
                    onChanged: filtrar,
                    decoration: InputDecoration(
                      hintText: "Buscar tipo de alcohol...",
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon:
                      const Icon(Icons.search, color: Colors.cyanAccent),
                      filled: true,
                      fillColor: Colors.black,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: [
                        ListTile(
                          title: const Text("Todos",
                              style: TextStyle(color: Colors.white)),
                          onTap: () {
                            setState(() {
                              _filtroAlcohol = null;
                            });
                            Navigator.pop(context);
                          },
                        ),
                        ...listaFiltrada.map(
                              (alcohol) => ListTile(
                            title: Text(alcohol,
                                style: const TextStyle(color: Colors.white)),
                            onTap: () {
                              setState(() {
                                _filtroAlcohol = alcohol;
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 🔹 Widgets auxiliares
  Widget sugerenciaChip(String text) {
    return ActionChip(
      label: Text(text, style: const TextStyle(color: Colors.black)),
      backgroundColor: Colors.cyanAccent,
      onPressed: () {
        setState(() {
          _controller.text = text;
          _query = text;
        });
      },
    );
  }

  static Widget principianteCard(String titulo) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.cyanAccent),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          titulo,
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget resultadoCard(String titulo, String imgUrl) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(imgUrl, width: 50, height: 50, fit: BoxFit.cover),
        ),
        title: Text(
          titulo,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: _filtroAlcohol != null
            ? Text("Filtro: $_filtroAlcohol",
            style: const TextStyle(color: Colors.cyanAccent, fontSize: 12))
            : null,
      ),
    );
  }
}
