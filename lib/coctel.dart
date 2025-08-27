class Ingrediente {
  final String nombre;
  final String cantidad;

  Ingrediente({required this.nombre, required this.cantidad});
}

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

  factory Coctel.fromJson(Map<String, dynamic> json) {
    List<Ingrediente> ingredientes = [];

    for (int i = 1; i <= 15; i++) {
      final nombre = json['strIngredient$i'];
      final cantidad = json['strMeasure$i'];

      if (nombre != null && nombre.toString().trim().isNotEmpty) {
        ingredientes.add(
          Ingrediente(
            nombre: nombre.toString(),
            cantidad: cantidad?.toString() ?? "",
          ),
        );
      }
    }

    return Coctel(
      id: json['idDrink'] ?? '',
      nombre: json['strDrink'] ?? '',
      imagenUrl: json['strDrinkThumb'] ?? '',
      instrucciones: json['strInstructions'] ?? '',
      ingredientes: ingredientes,
    );
  }
}
