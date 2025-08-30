import 'package:coctel_app/features/cocteles/presentation/pantalla_ver_mas.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/coctel.dart';
import '../../../core/services/api_servicio.dart';
import '../../../core/services/theme_provider.dart';
import '../../mis_ingredientes/presentation/pantalla_mis_ingredientes.dart';
import 'pantalla_detalle_coctel.dart';

class PantallaBusqueda extends StatefulWidget {
  const PantallaBusqueda({super.key});

  @override
  PantallaBusquedaState createState() => PantallaBusquedaState();
}

class PantallaBusquedaState extends State<PantallaBusqueda> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<List<Coctel>> _searchResults;

  late Future<List<Coctel>> _sugerencias;
  late Future<List<Coctel>> _coctelesPrincipiantes;

  String _selectedCategory = 'Categoría';
  String _selectedIngredient = 'Ingrediente';
  String _selectedAlcohol = 'Alcohol';

  @override
  void initState() {
    super.initState();
    _searchResults = Future.value([]);
    _sugerencias = ApiServicio.buscarCoctelesPorLetra("m");
    _coctelesPrincipiantes = ApiServicio.buscarCoctelesPorIngrediente("vodka");
  }

  void _performSearch(String query) {
    final trimmedQuery = query.trim();

    if (trimmedQuery.isNotEmpty) {
      setState(() {
        _searchResults = ApiServicio.buscarCoctelesPorNombre(trimmedQuery);
      });
    } else {
      setState(() {
        _searchResults = Future.value([]);
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _searchController.text = " "; 
      _searchResults = _getFilteredResults();
    });
  }

  Future<List<Coctel>> _getFilteredResults() async {
    List<Future<List<Coctel>>> futures = [];

    if (_selectedCategory != 'Categoría') {
      futures.add(ApiServicio.buscarCoctelesPorCategoria(_selectedCategory));
    }
    if (_selectedIngredient != 'Ingrediente') {
      futures.add(ApiServicio.buscarCoctelesPorIngrediente(_selectedIngredient));
    }
    if (_selectedAlcohol != 'Alcohol') {
      futures.add(ApiServicio.buscarCoctelesPorAlcohol(_selectedAlcohol));
    }

    if (futures.isEmpty) {
      return Future.value([]);
    }

    // Wait for all API calls to complete
    List<List<Coctel>> results = await Future.wait(futures);

    // Intersect the results
    List<Coctel> finalResults = [];
    if (results.isNotEmpty) {
      // Start with the first list of results
      finalResults = results[0];
      
      // Intersect with the rest of the lists
      for (int i = 1; i < results.length; i++) {
        final Set<String> idsToKeep = results[i].map((c) => c.id).toSet();
        finalResults = finalResults.where((c) => idsToKeep.contains(c.id)).toList();
      }
    }

    return finalResults;
  }

  Widget _buildDropdownButton(String hint, String value, List<String> items, Function(String?) onChanged, Color textColor, Color hintColor) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: TextStyle(color: hintColor),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: hintColor),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: textColor),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      value: value,
      dropdownColor: Theme.of(context).cardColor,
      style: TextStyle(color: textColor),
      items: items.map<DropdownMenuItem<String>>((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item, style: TextStyle(color: textColor)),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    final textColor = isDarkMode ? Colors.white : const Color(0xFF010D00);
    final scaffoldColor = isDarkMode ? const Color(0xFF121212) : Colors.white;
    final searchBarColor = isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF2F2F2);
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final hintColor = isDarkMode ? Colors.white60 : Colors.grey;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: scaffoldColor,
      endDrawer: _buildFilterDrawer(textColor, hintColor, cardColor),
      appBar: AppBar(
        backgroundColor: scaffoldColor,
        elevation: 0,
        toolbarHeight: 80,
        flexibleSpace: Padding(
          padding: const EdgeInsets.only(top: 40.0, left: 16, right: 16, bottom: 8),
          child: Container(
            decoration: BoxDecoration(
              color: searchBarColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              onSubmitted: _performSearch,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: "Buscar cócteles...",
                hintStyle: TextStyle(color: hintColor),
                prefixIcon: IconButton(
                  icon: Icon(Icons.search, color: hintColor),
                  onPressed: () => _performSearch(_searchController.text),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              if (_searchController.text.isEmpty) ...[
                Text(
                  "Sugerencias",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 15),
                _buildCoctelList(_sugerencias, cardColor, textColor, hintColor, isGrid: false, limit: 3),
                const SizedBox(height: 25),
                _buildSectionTitle("Cócteles para principiantes", _coctelesPrincipiantes, textColor),
                const SizedBox(height: 15),
                _buildCoctelList(_coctelesPrincipiantes, cardColor, textColor, hintColor, isGrid: true, limit: 6),
                const SizedBox(height: 20),
              ] else ...[
                Text(
                  "Resultados de la búsqueda",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 15),
                _buildCoctelList(_searchResults, cardColor, textColor, hintColor, isGrid: true, limit: null),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PantallaMisIngredientes()),
          );
        },
        backgroundColor: const Color(0xFF05AFF2),
        child: const Icon(Icons.search, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildFilterDrawer(Color textColor, Color hintColor, Color cardColor) {
    return Drawer(
      backgroundColor: cardColor,
      child: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: Icon(Icons.close, color: hintColor),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Filtrar Búsqueda",
            style: TextStyle(
              color: textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          _buildDropdownButton(
            'Categoría',
            _selectedCategory,
            const ['Categoría', 'Ordinary Drink', 'Cocktail', 'Shake'],
                (newValue) => setState(() => _selectedCategory = newValue!),
            textColor,
            hintColor,
          ),
          const SizedBox(height: 20),
          _buildDropdownButton(
            'Ingrediente',
            _selectedIngredient,
            const ['Ingrediente', 'Vodka', 'Gin', 'Rum', 'Tequila'],
                (newValue) => setState(() => _selectedIngredient = newValue!),
            textColor,
            hintColor,
          ),
          const SizedBox(height: 20),
          _buildDropdownButton(
            'Alcohol',
            _selectedAlcohol,
            const ['Alcohol', 'Alcoholic', 'Non-Alcoholic'],
                (newValue) => setState(() => _selectedAlcohol = newValue!),
            textColor,
            hintColor,
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              _applyFilters();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF05AFF2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
            child: const Text(
              "Aplicar Filtros",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Future<List<Coctel>> futureCocteles, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PantallaVerTodos(
                  titulo: title,
                  coctelesFuture: futureCocteles,
                ),
              ),
            );
          },
          child: const Text(
            "Ver más",
            style: TextStyle(
              color: Color(0xFF05AFF2),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCoctelList(Future<List<Coctel>> coctelesFuture, Color cardColor, Color textColor, Color hintColor, {required bool isGrid, int? limit}) {
    return FutureBuilder<List<Coctel>>(
      future: coctelesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: textColor)));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No se encontraron cócteles.', style: TextStyle(color: textColor)));
        } else {
          final coctelesToShow = limit != null ? snapshot.data!.take(limit).toList() : snapshot.data!;

          if (isGrid) {
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.8,
              ),
              itemCount: coctelesToShow.length,
              itemBuilder: (context, index) {
                final coctel = coctelesToShow[index];
                return _buildCoctelGridItem(coctel, cardColor, textColor, hintColor);
              },
            );
          } else {
            return Column(
              children: coctelesToShow.map((coctel) => _buildCoctelListItem(coctel, cardColor, textColor, hintColor)).toList(),
            );
          }
        }
      },
    );
  }

  Widget _buildCoctelListItem(Coctel coctel, Color cardColor, Color textColor, Color hintColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PantallaDetalleCoctel(coctel: coctel)),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(25),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  coctel.imagenUrl,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 70,
                    height: 70,
                    color: Colors.grey.shade200,
                    child: Icon(Icons.broken_image, color: hintColor),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  coctel.nombre,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 18, color: hintColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoctelGridItem(Coctel coctel, Color cardColor, Color textColor, Color hintColor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PantallaDetalleCoctel(coctel: coctel)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(25),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  coctel.imagenUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade200,
                    child: Icon(Icons.broken_image, color: hintColor),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              coctel.nombre,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: textColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              "por ${coctel.categoria}",
              style: TextStyle(
                color: hintColor,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}