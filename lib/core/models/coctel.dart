import 'ingrediente.dart';

class Coctel {
  final String id;
  final String nombre;
  final String instrucciones;
  final String imagenUrl;
  final String alcohol;
  final String categoria;
  final List<Ingrediente> ingredientes;

  Coctel({
    required this.id,
    required this.nombre,
    required this.instrucciones,
    required this.imagenUrl,
    required this.alcohol,
    required this.categoria,
    required this.ingredientes,
  });

  factory Coctel.fromJson(Map<String, dynamic> json) {
    return Coctel(
      id: json['idDrink'] ?? json['id'] ?? '',
      nombre: json['strDrink'] ?? json['nombre'] ?? '',
      instrucciones: json['strInstructions'] ?? json['instrucciones'] ?? '',
      imagenUrl: json['strDrinkThumb'] ?? json['imagenUrl'] ?? '',
      alcohol: json['strAlcoholic'] ?? '',
      categoria: json['strCategory'] ?? '',
      ingredientes: List.generate(15, (i) {
        final nombreIng = json['strIngredient${i + 1}'];
        final medida = json['strMeasure${i + 1}'];
        if (nombreIng != null && nombreIng.toString().isNotEmpty) {
          return Ingrediente(
            nombre: nombreIng,
            cantidad: medida ?? '',
          );
        }
        return null;
      }).whereType<Ingrediente>().toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'instrucciones': instrucciones,
      'imagenUrl': imagenUrl,
      'alcohol': alcohol,
      'categoria': categoria,
      'ingredientes': ingredientes.map((e) => e.toJson()).toList(),
    };
  }
}