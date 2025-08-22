// lib/coctel.dart

class Coctel {
  final String id;
  final String nombre;
  final String imagenUrl; // Puedes usar URLs de imágenes de internet para empezar
  final List<Ingrediente> ingredientes;
  final List<String> instrucciones;
  // Opcional: puedes añadir más propiedades como dificultad, tipo de vaso, etc.

  Coctel({
    required this.id,
    required this.nombre,
    required this.imagenUrl,
    required this.ingredientes,
    required this.instrucciones,
  });
}

class Ingrediente {
  final String nombre;
  final String cantidad;

  Ingrediente({required this.nombre, required this.cantidad});
}