import 'package:flutter/material.dart';
import '../../../core/services/api_servicio.dart';
import '../../../core/data/ingredients_map.dart';
import '../../../core/models/drink_summary.dart';

class PantallaMisIngredientes extends StatefulWidget {
  const PantallaMisIngredientes({super.key});

  @override
  State<PantallaMisIngredientes> createState() => _PantallaMisIngredientesState();
}

class _PantallaMisIngredientesState extends State<PantallaMisIngredientes> {
  final ApiServicio _api = ApiServicio();

  // Orden visual de tus cards (ES). Deben existir en esToApi.
  final List<String> _uiOrder = const [
    'Hielo',
    'Limón',
    'Coca Cola',
    'Ron Blanco',
    'Pisco',
    'Tequila',
    'Whisky',
    'Red Vermouth',
  ];

  final Set<String> _seleccionadosEs = {};
  bool _loading = false;
  List<DrinkSummary> _resultados = [];

  String _ingredientImgUrl(String apiName) {

    // Imágenes públicas de ingredientes de TheCocktailDB.
    final token = Uri.encodeComponent(apiName);
    return 'https://www.thecocktaildb.com/images/ingredients/$token-Medium.png';
  }

  Future<void> _buscar() async {
    if (_seleccionadosEs.isEmpty) return;
    setState(() => _loading = true);

    // ES→EN para la API
    final tokens = _seleccionadosEs
        .map((es) => esToApi[es] ?? es)
        .toList();

    final lista = await _api.filterByIngredients(tokens);
    if (!mounted) return;
    setState(() {
      _resultados = lista;
      _loading = false;
    });
  }

  void _limpiar() {
    setState(() {
      _seleccionadosEs.clear();
      _resultados = [];
    });
  }

  Future<void> _mostrarDetalle(DrinkSummary d) async {
    final data = await _api.lookupDrink(d.id);
    if (!mounted) return;
    if (data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo cargar el detalle')),
      );
      return;
    }
    final instrucciones = (data['strInstructions'] as String?) ?? '—';
    final ingredientes = <String>[];
    for (int i = 1; i <= 15; i++) {
      final ing = data['strIngredient$i'];
      final qty = data['strMeasure$i'];
      if (ing == null || (ing is String && ing.trim().isEmpty)) continue;
      final linea = qty == null || (qty is String && qty.trim().isEmpty)
          ? '$ing'
          : '$qty  $ing';
      ingredientes.add(linea);
    }

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 8),
              Text(d.name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(d.thumb, height: 160, fit: BoxFit.cover),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Ingredientes',
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              const SizedBox(height: 8),
              ...ingredientes.map((e) => Align(
                alignment: Alignment.centerLeft,
                child: Text('• $e'),
              )),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Instrucciones',
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              const SizedBox(height: 8),
              Text(instrucciones),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canSearch = _seleccionadosEs.isNotEmpty && !_loading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Ingredientes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          TextButton(
            onPressed: _seleccionadosEs.isEmpty ? null : _limpiar,
            child: const Text('Limpiar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: canSearch ? _buscar : null,
        icon: _loading ? const CircularProgressIndicator() : const Icon(Icons.search),
        label: const Text('Buscar'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [

            // Sección: Ingredientes (selección)
            const Text('Selecciona tus ingredientes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _uiOrder.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: .78,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemBuilder: (_, i) {
                final es = _uiOrder[i];
                final api = esToApi[es] ?? es;
                final selected = _seleccionadosEs.contains(es);

                return InkWell(
                  onTap: () {
                    setState(() {
                      if (selected) {
                        _seleccionadosEs.remove(es);
                      } else {
                        _seleccionadosEs.add(es);
                      }
                    });
                  },
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade300,
                            width: selected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Image.network(
                                _ingredientImgUrl(api),
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Icon(Icons.image),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              es,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 6,
                        top: 6,
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: selected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.black26,
                          child: Icon(
                            selected ? Icons.check : Icons.add,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Sección: Resultados
            if (_resultados.isNotEmpty) ...[
              Text('Resultados (${_resultados.length})',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _resultados.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: .85,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (_, i) {
                  final d = _resultados[i];
                  return InkWell(
                    onTap: () => _mostrarDetalle(d),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: Image.network(
                                d.thumb,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.local_bar, size: 48),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              d.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ] else if (!_loading && _seleccionadosEs.isNotEmpty) ...[
              const SizedBox(height: 4),
              const Text('Sin coincidencias con esa combinación.'),
            ],
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
