import 'dart:io';
import 'package:coctel_app/features/cocteles/presentation/pantalla_ver_mas.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coctel_app/core/models/coctel.dart';
import 'package:flutter/foundation.dart'; // Añadido para kDebugMode
import '../../../core/services/api_servicio.dart';
import 'package:coctel_app/core/services/theme_provider.dart';
import 'package:coctel_app/core/services/cocteles_creados_manager.dart'; 
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

  List<Coctel> _searchResults = [];
  Future<List<Coctel>>? _sugerenciasFuture;
  Future<List<Coctel>>? _coctelesPrincipiantesFuture;
  
  String _selectedCategory = 'Categoría';
  String _selectedIngredient = 'Ingrediente';
  String _selectedAlcohol = 'Alcohol';

  // Para indicar carga de filtros/búsqueda
  bool _isLoading = false;

  // Controla la visibilidad de la sección de sugerencias
  bool _mostrarSugerencias = true;

  List<String> _categoryOptions = ['Categoría'];
  List<String> _ingredientOptions = ['Ingrediente'];
  final List<String> _alcoholOptions = ['Alcohol', 'Alcoholic', 'Non-Alcoholic', 'Optional alcohol'];


  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_searchController.text.trim().isEmpty && !_mostrarSugerencias) {
      setState(() {
        _mostrarSugerencias = true;

        // Limpia resultados cuando se borra el texto y se deben mostrar sugerencias
        _searchResults = [];
      });
    } else if (_searchController.text.trim().isNotEmpty && _mostrarSugerencias) {
      setState(() {

        // Oculta sugerencias cuando se empieza a escribir
        _mostrarSugerencias = false;
      });
    }

    // Recarga a estado inicial si se borra el texto
    if (_searchController.text.trim().isEmpty) {
       _performSearchAndFilter();
    }
  }

  Future<void> _fetchInitialData() async {
    setState(() => _isLoading = true);
    try {
      _sugerenciasFuture = ApiServicio.buscarCoctelesPorLetra("m");
      _coctelesPrincipiantesFuture = ApiServicio.buscarCoctelesPorIngrediente("vodka");

      final categories = await ApiServicio.obtenerCategorias();
      if (kDebugMode) { // Línea añadida para depuración
        print('Categorías obtenidas: $categories'); // Línea añadida para depuración
      }
      if (!mounted) return;

      // Llamada estática a listIngredients
      final ingredients = await ApiServicio.listIngredients(); 
      if (kDebugMode) { // Línea añadida para depuración
        print('Ingredientes obtenidos: $ingredients'); // Línea añadida para depuración
      }
      if (!mounted) return;
      
      // Asegurarse de que las listas de opciones siempre contengan el valor por defecto
      // y también los valores cargados, evitando duplicados si ya existen.
      final Set<String> uniqueCategories = {'Categoría'};
      uniqueCategories.addAll(categories.map((c) => c.replaceAll('_', ' ')));

      final Set<String> uniqueIngredients = {'Ingrediente'};
      uniqueIngredients.addAll(ingredients.map((i) => i.replaceAll('_', ' ')));
      
      setState(() {
        _categoryOptions = uniqueCategories.toList();
        _ingredientOptions = uniqueIngredients.toList();
      });
    } catch (e) {
      if (!mounted) return;
      debugPrint('Error fetching initial data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos iniciales: ${e.toString()}')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _applyFilters() async {
    setState(() {
      _isLoading = true;

      // Ocultar sugerencias al aplicar filtros
      _mostrarSugerencias = false;

      // Si el campo de búsqueda está vacío, ponemos un espacio para diferenciar de "mostrarSugerencias"
      /*
      if (_searchController.text.trim().isEmpty && (_selectedCategory != 'Categoría' || _selectedIngredient != 'Ingrediente' || _selectedAlcohol != 'Alcohol')) {
          _searchController.text = " "; 
      }
      */
    });
    
    final results = await _performSearchAndFilter();
    if (!mounted) return;
    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  Future<void> _clearFilters() async {
    _searchController.clear();
    setState(() {
      _selectedCategory = 'Categoría';
      _selectedIngredient = 'Ingrediente';
      _selectedAlcohol = 'Alcohol';
      _isLoading = true;

      // Asegurar que se muestren sugerencias
      _mostrarSugerencias = true;
    });

    // Recargar con filtros limpios
    final results = await _performSearchAndFilter();
    if (!mounted) return;
    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }


  Future<List<Coctel>> _performSearchAndFilter() async {
    final String searchText = _searchController.text.trim().toLowerCase();
    
    // Cocteles Locales
    final coctelesManager = Provider.of<CoctelesCreadosManager>(context, listen: false);
    List<Coctel> localesFiltrados = List.from(coctelesManager.coctelesCreados);

    // Filtrar locales por texto
    if (searchText.isNotEmpty && searchText != " ") {
      localesFiltrados = localesFiltrados.where((c) => c.nombre.toLowerCase().contains(searchText)).toList();
    }

    // Filtrar locales por dropdowns
    if (_selectedCategory != 'Categoría') {
      final categoryFilter = _selectedCategory.replaceAll(' ', '_').toLowerCase();
      localesFiltrados = localesFiltrados.where((c) => c.categoria.toLowerCase() == categoryFilter).toList();
    }
    if (_selectedIngredient != 'Ingrediente') {
      final ingredientFilter = _selectedIngredient.replaceAll(' ', '_').toLowerCase();
      localesFiltrados = localesFiltrados.where((c) => c.ingredientes.any((ing) => ing.nombre.toLowerCase() == ingredientFilter)).toList();
    }
    if (_selectedAlcohol != 'Alcohol') {
      final alcoholFilter = _selectedAlcohol.replaceAll('-', '_').toLowerCase();
      localesFiltrados = localesFiltrados.where((c) => c.alcohol.toLowerCase() == alcoholFilter).toList();
    }

    // Cocteles de la API
    List<Coctel> apiResults = [];
    List<Coctel> apiResultsByName = [];
    List<Coctel> apiResultsFromDropdowns = [];

    bool hasSearchText = searchText.isNotEmpty && searchText != " ";
    bool hasDropdownFilters = _selectedCategory != 'Categoría' || _selectedIngredient != 'Ingrediente' || _selectedAlcohol != 'Alcohol';

    if (!hasSearchText && !hasDropdownFilters) {
      return [];
    }
    
    try {
      if (hasSearchText) {
        apiResultsByName = await ApiServicio.buscarCoctelesPorNombre(searchText);
      }

      if (hasDropdownFilters) {
        List<Future<List<Coctel>>> futuresApiDropdowns = [];
        if (_selectedCategory != 'Categoría') {
          futuresApiDropdowns.add(ApiServicio.buscarCoctelesPorCategoria(_selectedCategory.replaceAll(' ', '_')));
        }
        if (_selectedIngredient != 'Ingrediente') {
          futuresApiDropdowns.add(ApiServicio.buscarCoctelesPorIngrediente(_selectedIngredient.replaceAll(' ', '_')));
        }
        if (_selectedAlcohol != 'Alcohol') {
          futuresApiDropdowns.add(ApiServicio.buscarCoctelesPorAlcohol(_selectedAlcohol.replaceAll('-', '_')));
        }
        
        if (futuresApiDropdowns.isNotEmpty) {
          final results = await Future.wait(futuresApiDropdowns);
          if (results.isNotEmpty) {
            apiResultsFromDropdowns = results.removeAt(0);
            for (var nextResultList in results) {
              final idsToKeep = nextResultList.map((c) => c.id).toSet();
              apiResultsFromDropdowns.retainWhere((c) => idsToKeep.contains(c.id));
            }
          }
        }
      }

      // Combinar resultados de API
      if (hasSearchText && hasDropdownFilters) {
        final idsFromDropdowns = apiResultsFromDropdowns.map((c) => c.id).toSet();
        apiResults = apiResultsByName.where((c) => idsFromDropdowns.contains(c.id)).toList();
      } else if (hasSearchText) {
        apiResults = apiResultsByName;
      } else if (hasDropdownFilters) {
        apiResults = apiResultsFromDropdowns;
      }

    } catch (e) {
      if (!mounted) return [];
      debugPrint('Error al buscar en API: $e');
    }
    
    // Combinar locales filtrados con API filtrados
    final List<Coctel> combinedResults = [...localesFiltrados];
    final Set<String> idsLocales = localesFiltrados.map((c) => c.id).toSet();
    for (var coctelApi in apiResults) {
      if (!idsLocales.contains(coctelApi.id)) {
        combinedResults.add(coctelApi);
      }
    }
    
    return combinedResults;
  }

  Widget _buildDropdownButton(String hint, String value, List<String> items, Function(String?) onChanged, Color textColor, Color hintColor) {
    final String currentValue = items.contains(value) ? value : items.first;

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
        filled: true,
        fillColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      value: currentValue, 
      dropdownColor: Theme.of(context).cardColor,
      style: TextStyle(color: textColor),
      items: items.map<DropdownMenuItem<String>>((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item, style: TextStyle(color: textColor), overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: onChanged,

      // Para que el texto largo no se corte
      isExpanded: true,
    );
  }
  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
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
    final hintColor = isDarkMode ? Colors.white60 : Colors.grey.shade600;


    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: scaffoldColor,
      endDrawer: _buildFilterDrawer(textColor, hintColor, cardColor, scaffoldColor),
      appBar: AppBar(
        backgroundColor: scaffoldColor,
        elevation: 0,
        toolbarHeight: 80,

        // Botón para abrir el drawer de Mis Ingredientes si lo tienes
        leading: IconButton(
          icon: Icon(Icons.inventory_2_outlined, color: hintColor),
          onPressed: () {
             Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PantallaMisIngredientes()),
              );
          },
        ),
        titleSpacing: 0,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: searchBarColor,
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextField(
              controller: _searchController,

              // Búsqueda al presionar Enter
              onSubmitted: (query) async {
                  setState(() { _isLoading = true; _mostrarSugerencias = false;});
                  final results = await _performSearchAndFilter();
                  if(!mounted) return;
                  setState(() { _searchResults = results; _isLoading = false;});
              },
              style: TextStyle(color: textColor, fontSize: 16),
              decoration: InputDecoration(
                hintText: "Buscar cócteles...",
                hintStyle: TextStyle(color: hintColor, fontSize: 16),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                  child: Icon(Icons.search, color: hintColor, size: 24),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list_rounded, color: hintColor, size: 28),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _mostrarSugerencias
              ? _buildSugerenciasView(cardColor, textColor, hintColor)
              : _searchResults.isEmpty
                  ? Center(child: Text('No se encontraron cócteles.', style: TextStyle(color: textColor, fontSize: 16)))
                  : _buildResultsList(cardColor, textColor, hintColor),
    );
  }

  Widget _buildFilterDrawer(Color textColor, Color hintColor, Color cardColor, Color drawerBackgroundColor) {
    return Drawer(
      backgroundColor: drawerBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Filtrar Búsqueda",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: hintColor, size: 28),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDropdownButton(
                    'Categoría',
                    _selectedCategory, 
                    _categoryOptions, 
                    (newValue) => setState(() => _selectedCategory = newValue!),
                    textColor,
                    hintColor,
                  ),
                  const SizedBox(height: 18),
                  _buildDropdownButton(
                    'Ingrediente',
                    _selectedIngredient, 
                    _ingredientOptions, 
                    (newValue) => setState(() => _selectedIngredient = newValue!),
                    textColor,
                    hintColor,
                  ),
                  const SizedBox(height: 18),
                  _buildDropdownButton(
                    'Alcohol',
                    _selectedAlcohol, 
                    _alcoholOptions, 
                    (newValue) => setState(() => _selectedAlcohol = newValue!),
                    textColor,
                    hintColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clearFilters,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: hintColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text("Limpiar", style: TextStyle(color: textColor, fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _applyFilters();

                      // Cerrar el drawer después de aplicar
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF05AFF2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "Aplicar",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildSugerenciasView(Color cardColor, Color textColor, Color hintColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Sugerencias",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 15),
          _buildCoctelList(_sugerenciasFuture, cardColor, textColor, hintColor, isGrid: false, limit: 3),
          const SizedBox(height: 25),
          _buildSectionTitle("Cócteles para principiantes", _coctelesPrincipiantesFuture, textColor),
          const SizedBox(height: 15),
          _buildCoctelList(_coctelesPrincipiantesFuture, cardColor, textColor, hintColor, isGrid: true, limit: 6),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildResultsList(Color cardColor, Color textColor, Color hintColor) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.8, 
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final coctel = _searchResults[index];
        return _buildCoctelGridItem(coctel, cardColor, textColor, hintColor);
      },
    );
  }


  Widget _buildSectionTitle(String title, Future<List<Coctel>>? futureCocteles, Color textColor) {
    if (futureCocteles == null) return const SizedBox.shrink();
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

Widget _buildCoctelList(Future<List<Coctel>>? coctelesFuture, Color cardColor, Color textColor, Color hintColor, {required bool isGrid, int? limit}) {
  if (coctelesFuture == null) {
    return const Center(child: Text('Cargando...', style: TextStyle(color: Colors.grey)));
  }
  return FutureBuilder<List<Coctel>>(
    future: coctelesFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting && !_isLoading) {
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
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: coctelesToShow.length,
            itemBuilder: (context, index) {
              final coctel = coctelesToShow[index];
              return _buildCoctelListItem(coctel, cardColor, textColor, hintColor);
            },
          );
        }
      }
    },
  );
}


  Widget _buildCoctelListItem(Coctel coctel, Color cardColor, Color textColor, Color hintColor) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
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
                color: Colors.grey.withAlpha(isDarkMode ? 10 : 25), 
                spreadRadius: 1, 
                blurRadius: 4,   
                offset: const Offset(0, 2), 
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: coctel.isLocal && coctel.imagenUrl.isNotEmpty && !coctel.imagenUrl.startsWith('http')
                  ? Image.file(
                      File(coctel.imagenUrl), 
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey.shade200,
                        child: Icon(Icons.broken_image, color: hintColor, size: 30),
                      ),
                    )
                  : Image.network(
                      coctel.imagenUrl,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey.shade200,
                        child: Icon(Icons.broken_image, color: hintColor, size: 30),
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
                  maxLines: 2, 
                  overflow: TextOverflow.ellipsis,
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
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PantallaDetalleCoctel(coctel: coctel)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : Colors.grey).withOpacity(isDark ? 0.3 : 0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3), 
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, 
          children: [
            Expanded(
              flex: 3, 
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)), 
                child: coctel.isLocal && coctel.imagenUrl.isNotEmpty && !coctel.imagenUrl.startsWith('http')
                  ? Image.file(
                      File(coctel.imagenUrl), 
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade200,
                        child: Icon(Icons.broken_image, color: hintColor, size: 40),
                      ),
                    )
                  : Image.network(
                      coctel.imagenUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade200,
                        child: Icon(Icons.broken_image, color: hintColor, size: 40),
                      ),
                    ),
              ),
            ),
            Padding( 
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coctel.nombre,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    coctel.isLocal ? "Creado por ti" : "Categoría: ${coctel.categoria.replaceAll('_', ' ')}", 
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
          ],
        ),
      ),
    );
  }
}
