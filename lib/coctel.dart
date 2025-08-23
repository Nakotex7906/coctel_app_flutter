
class Coctel {
  final String id;
  final String nombre;
  final String imagenUrl;
  final String instrucciones;
  final List<Ingrediente> ingredientes;

  Coctel({
    required this.id,
    required this.nombre,
    required this.imagenUrl,
    required this.instrucciones,
    required this.ingredientes,
  });

  // Factory constructor para crear un Coctel desde un mapa JSON
  factory Coctel.fromJson(Map<String, dynamic> json) {
    List<Ingrediente> ingredientesList = [];
    for (int i = 1; i <= 15; i++) {
      final ingredienteNombre = json['strIngredient$i'];
      final ingredienteCantidad = json['strMeasure$i'];

      // Si el ingrediente no es nulo o vacío, lo añadimos a la lista
      if (ingredienteNombre != null && ingredienteNombre.trim().isNotEmpty) {
        ingredientesList.add(Ingrediente(
          nombre: ingredienteNombre,
          cantidad: ingredienteCantidad ?? '', // Si la cantidad es nula, la dejamos vacía
        ));
      }
    }

    return Coctel(
      id: json['idDrink'],
      nombre: json['strDrink'],
      imagenUrl: json['strDrinkThumb'],
      instrucciones: json['strInstructions'] ?? 'No instructions available.',
      ingredientes: ingredientesList,
    );
  }
}

class Ingrediente {
  final String nombre;
  final String cantidad;

  Ingrediente({required this.nombre, required this.cantidad});
}
