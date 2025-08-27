import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';
import 'coctel.dart';

class ApiServicio {
  static const String _baseUrl = 'https://www.thecocktaildb.com/api/json/v1/1';
  static final _translator = GoogleTranslator();

  // 🔹 Traducción al español
  static Future<String> _traducir(String texto) async {
    if (texto.isEmpty) return '';
    try {
      var traduccion = await _translator.translate(texto, from: 'en', to: 'es');
      return traduccion.text;
    } catch (e) {
      if (kDebugMode) {
        print('Error de traducción: $e');
      }
      return texto;
    }
  }

  // 🔹 Fetch y traducción automática
  static Future<List<Coctel>> _fetchAndTranslate(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['drinks'] == null) return [];

      final List drinks = json['drinks'];
      List<Coctel> cocteles =
      drinks.map((drink) => Coctel.fromJson(drink)).toList();

      // Traducir cada cóctel
      List<Coctel> coctelesTraducidos = await Future.wait(cocteles.map((coctel) async {
        String instruccionesTraducidas =
        await _traducir(coctel.instrucciones);

        List<Ingrediente> ingredientesTraducidos = await Future.wait(
          coctel.ingredientes.map((ing) async {
            String nombreTraducido = await _traducir(ing.nombre);
            return Ingrediente(
              nombre: nombreTraducido,
              cantidad: ing.cantidad,
            );
          }),
        );

        return Coctel(
          id: coctel.id,
          nombre: coctel.nombre,
          imagenUrl: coctel.imagenUrl,
          instrucciones: instruccionesTraducidas,
          ingredientes: ingredientesTraducidos,
        );
      }));

      return coctelesTraducidos;
    } else {
      throw Exception('Error cargando cócteles de la API');
    }
  }

  // 🔹 Buscar por letra
  static Future<List<Coctel>> buscarCoctelesPorLetra(String letra) async {
    return _fetchAndTranslate('$_baseUrl/search.php?f=$letra');
  }

  // 🔹 Buscar por nombre
  static Future<List<Coctel>> buscarCoctelesPorNombre(String nombre) async {
    return _fetchAndTranslate('$_baseUrl/search.php?s=$nombre');
  }

  // 🔹 Cocteles fáciles (para principiantes)
  static Future<List<Coctel>> coctelesPrincipiantes() async {
    // Se filtra por ingredientes comunes y sencillos
    final url = '$_baseUrl/filter.php?i=vodka'; // Ejemplo: base vodka
    return _fetchAndTranslate(url);
  }

  // 🔹 Filtrar por tipo de alcohol
  static Future<List<Coctel>> buscarPorCategoria(String categoria) async {
    final url = '$_baseUrl/filter.php?i=$categoria';
    return _fetchAndTranslate(url);
  }

  // 🔹 Listado de categorías disponibles
  static Future<List<String>> obtenerCategorias() async {
    final response = await http.get(Uri.parse('$_baseUrl/list.php?i=list'));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List lista = json['drinks'];
      return lista.map((e) => e['strIngredient1'].toString()).toList();
    } else {
      throw Exception("Error cargando categorías");
    }
  }
}
