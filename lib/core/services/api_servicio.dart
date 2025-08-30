import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';
import '../models/ingrediente.dart';
import '../../core/models/coctel.dart';
import 'translation_cache.dart';

class ApiServicio {
  static const String _baseUrl = 'https://www.thecocktaildb.com/api/json/v1/1';
  static final _translator = GoogleTranslator();
  static final _translationCache = TranslationCache();

  // Realiza una solicitud HTTP GET y decodifica la respuesta JSON.
  static Future<dynamic> _fetchJson(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error cargando datos de la API: $url');
    }
  }

  // Traduce un texto del inglés al español usando la API de Google Translator.
  static Future<String> _traducir(String texto) async {
    if (texto.isEmpty) return '';

    // Check cache first
    final cachedTranslation = await _translationCache.get(texto);
    if (cachedTranslation != null) {
      return cachedTranslation;
    }

    try {
      var traduccion = await _translator.translate(texto, from: 'en', to: 'es');
      // Save to cache
      await _translationCache.set(texto, traduccion.text);
      return traduccion.text;
    } catch (e) {
      if (kDebugMode) {
        print('Error de traducción: $e');
      }
      return texto;
    }
  }

  // Obtiene los detalles completos de una lista de cócteles a partir de sus IDs.
  static Future<List<Coctel>> _fetchCoctelesCompletos(List<String> ids) async {
    if (ids.isEmpty) return [];

    final List<Future<http.Response>> requests = ids
        .map((id) => http.get(Uri.parse('$_baseUrl/lookup.php?i=$id')))
        .toList();

    final List<http.Response> responses = await Future.wait(requests);

    List<Coctel> cocteles = [];
    for (var response in responses) {
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['drinks'] != null) {
          final detalle = json['drinks'][0];
          cocteles.add(Coctel.fromJson(detalle));
        }
      }
    }
    return cocteles;
  }


  static Future<List<Coctel>> _traducirCocteles(List<Coctel> cocteles) async {
    return Future.wait(cocteles.map((coctel) async {
      String instruccionesTraducidas = coctel.instrucciones.isNotEmpty
          ? await _traducir(coctel.instrucciones)
          : '';

      List<Ingrediente> ingredientesTraducidos = await Future.wait(
        coctel.ingredientes.map((ing) async {
          if (ing.nombre.isEmpty) return ing;
          String nombreTraducido = await _traducir(ing.nombre);
          return Ingrediente(nombre: nombreTraducido, cantidad: ing.cantidad);
        }),
      );

      return Coctel(
        id: coctel.id,
        nombre: coctel.nombre,
        imagenUrl: coctel.imagenUrl,
        instrucciones: instruccionesTraducidas,
        ingredientes: ingredientesTraducidos,
        alcohol: coctel.alcohol,
        categoria: coctel.categoria,
      );
    }));
  }

  static Future<List<Coctel>> coctelAleatorio() async {
    final json = await _fetchJson('$_baseUrl/random.php');
    if (json['drinks'] == null) return [];
    List<Coctel> cocteles = json['drinks'].map<Coctel>((drink) => Coctel.fromJson(drink)).toList();
    return _traducirCocteles(cocteles);
  }

  // Busca cócteles que comiencen con una letra específica.
  static Future<List<Coctel>> buscarCoctelesPorLetra(String letra) async {
    final json = await _fetchJson('$_baseUrl/search.php?f=$letra');
    if (json['drinks'] == null) return [];
    List<Coctel> cocteles = json['drinks'].map<Coctel>((drink) => Coctel.fromJson(drink)).toList();
    return _traducirCocteles(cocteles);
  }

  // Busca cócteles por nombre exacto o parcial.
  static Future<List<Coctel>> buscarCoctelesPorNombre(String nombre) async {
    final json = await _fetchJson('$_baseUrl/search.php?s=$nombre');
    if (json['drinks'] == null) return [];
    List<Coctel> cocteles = json['drinks'].map<Coctel>((drink) => Coctel.fromJson(drink)).toList();
    return _traducirCocteles(cocteles);
  }

  // Filtra y obtiene una lista de cócteles por categoría.
  static Future<List<Coctel>> buscarCoctelesPorCategoria(String categoria) async {
    final json = await _fetchJson('$_baseUrl/filter.php?c=$categoria');
    if (json['drinks'] == null) return [];
    List<String> ids = json['drinks'].map<String>((drink) => drink['idDrink'].toString()).toList();
    List<Coctel> cocteles = await _fetchCoctelesCompletos(ids);
    return _traducirCocteles(cocteles);
  }

  // Filtra y obtiene una lista de cócteles por un ingrediente específico.
  static Future<List<Coctel>> buscarCoctelesPorIngrediente(String ingrediente) async {
    final json = await _fetchJson('$_baseUrl/filter.php?i=$ingrediente');
    if (json['drinks'] == null) return [];
    List<String> ids = json['drinks'].map<String>((drink) => drink['idDrink'].toString()).toList();
    List<Coctel> cocteles = await _fetchCoctelesCompletos(ids);
    return _traducirCocteles(cocteles);
  }

  // Obtiene una lista de todas las categorías de cócteles disponibles.
  static Future<List<String>> obtenerCategorias() async {
    final json = await _fetchJson('$_baseUrl/list.php?c=list');
    if (json['drinks'] == null) return [];
    return List<String>.from(json['drinks'].map((c) => c['strCategory'].toString()));
  }

  // Filtra y obtiene una lista de cócteles por un tipo de alcohol.
  static Future<List<Coctel>> buscarCoctelesPorAlcohol(String alcohol) async {
    final json = await _fetchJson('$_baseUrl/filter.php?a=$alcohol');
    if (json['drinks'] == null) return [];
    List<String> ids = json['drinks'].map<String>((drink) => drink['idDrink'].toString()).toList();
    List<Coctel> cocteles = await _fetchCoctelesCompletos(ids);
    return _traducirCocteles(cocteles);
  }

  // Obtiene una lista de todos los tipos de alcohol disponibles en la API.
  static Future<List<String>> obtenerAlcoholes() async {
    final json = await _fetchJson('$_baseUrl/list.php?a=list');
    if (json['drinks'] == null) return [];
    return List<String>.from(json['drinks'].map((c) => c['strAlcoholic'].toString()));
  }
}
