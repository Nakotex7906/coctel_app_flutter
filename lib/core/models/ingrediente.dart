class Ingrediente {
  final String nombre;
  final String cantidad;

  Ingrediente({required this.nombre, required this.cantidad});

  factory Ingrediente.fromJson(Map<String, dynamic> json) {
    return Ingrediente(
      nombre: json['nombre'] ?? '',
      cantidad: json['cantidad'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'cantidad': cantidad,
    };
  }
}
