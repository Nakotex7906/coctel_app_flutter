// lib/api_servicio.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';
import 'coctel.dart';

class ApiServicio {
  static const String _baseUrl = 'https://www.thecocktaildb.com/api/json/v1/1';
  static final _translator = GoogleTranslator();

  // --- Lógica de Traducción --- //
  static Future<String> _traducir(String texto) async {
    if (texto.isEmpty) return '';
    try {
      var traduccion = await _translator.translate(texto, from: 'en', to: 'es');
      return traduccion.text;
    } catch (e) {
      if (kDebugMode) {
        print('Error de traducción: $e');
      }
      return texto; // Devuelve el original si falla
    }
  }

  // --- Lógica Central de Petición y Traducción --- //
  static Future<List<Coctel>> _fetchAndTranslate(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['drinks'] == null) {
        return []; // Devuelve lista vacía si no hay 'drinks'
      }

      final List drinks = json['drinks'];
      List<Coctel> cocteles = drinks.map((drink) => Coctel.fromJson(drink)).toList();

      // Proceso de traducción concurrente
      List<Coctel> coctelesTraducidos = await Future.wait(cocteles.map((coctel) async {
        String instruccionesTraducidas = await _traducir(coctel.instrucciones);
        List<Ingrediente> ingredientesTraducidos = await Future.wait(
          coctel.ingredientes.map((ing) async {
            String nombreTraducido = await _traducir(ing.nombre);
            return Ingrediente(nombre: nombreTraducido, cantidad: ing.cantidad);
          })
        );

        return Coctel(
          id: coctel.id,
          nombre: coctel.nombre, // Mantenemos el nombre original
          imagenUrl: coctel.imagenUrl,
          instrucciones: instruccionesTraducidas,
          ingredientes: ingredientesTraducidos,
        );
      }));

      return coctelesTraducidos;
    } else {
      throw Exception('Failed to load cocktails from the API');
    }
  }

  // --- Endpoints Públicos --- //
  static Future<List<Coctel>> buscarCoctelesPorLetra(String letra) async {
    return _fetchAndTranslate('$_baseUrl/search.php?f=$letra');
  }

  static Future<List<Coctel>> buscarCoctelesPorNombre(String nombre) async {
    return _fetchAndTranslate('$_baseUrl/search.php?s=$nombre');
  }
}