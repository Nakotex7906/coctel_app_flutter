import 'dart:convert';
import 'dart:math';
import '../models/drink_summary.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';
import '../models/ingrediente.dart';
import 'package:coctel_app/core/models/coctel.dart';
import 'package:coctel_app/core/services/translation_cache.dart';

class ApiServicio {
  static const String _baseUrl = 'https://www.thecocktaildb.com/api/json/v1/1';
  static final _translator = GoogleTranslator();
  static final _translationCache = TranslationCache();
  static final Random _random = Random();
  String _toToken(String s) => s.trim().replaceAll(' ', '_');

  // Realiza una solicitud HTTP GET y decodifica la respuesta JSON.
  static Future<dynamic> _fetchJson(String url, {int retries = 5}) async {
    for (int i = 0; i < retries; i++) {
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        } else if (response.statusCode == 429) {
          if (kDebugMode) {
            print('Error 429 (Too Many Requests) al cargar datos de la API desde: $url. Reintentando...');
          }
          // Exponential backoff with jitter for 429 errors
          final int delay = (pow(2, i) * 1000 + _random.nextInt(1000)).toInt(); // 1s, 2s, 4s, 8s, 16s + jitter
          await Future.delayed(Duration(milliseconds: delay));
        } else {
          if (kDebugMode) {
            print('Error HTTP ${response.statusCode} al cargar datos de la API desde: $url');
            print('Cuerpo de la respuesta: ${response.body}');
          }
          await Future.delayed(Duration(milliseconds: 500 * (i + 1)));
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error en la solicitud HTTP: $e para la URL: $url');
        }
        await Future.delayed(Duration(milliseconds: 500 * (i + 1)));
      }
    }
    throw Exception('Error cargando datos de la API: $url');
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

  // Obtiene una lista de todos los ingredientes disponibles.
  static Future<List<String>> listIngredients() async {
    try {
      final json = await ApiServicio._fetchJson('${ApiServicio._baseUrl}/list.php?i=list');
      if (json['drinks'] == null) return [];
      final items = (json['drinks'] as List?) ?? [];
      return items
          .map((e) => (e as Map<String, dynamic>)['strIngredient1'] as String?)
          .whereType<String>()
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error obteniendo ingredientes: $e');
      }
      return []; // Devuelve lista vacía en caso de error
    }
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

  // Busca cócteles por una lista de ingredientes y los une.
  static Future<List<Coctel>> _fetchCoctelesPorIngredientes(List<String> ingredientes) async {
    List<Future<List<Coctel>>> futures = ingredientes
        .map((ingrediente) => buscarCoctelesPorIngrediente(ingrediente))
        .toList();

    List<List<Coctel>> results = await Future.wait(futures);

    Map<String, Coctel> coctelesMap = {};
    for (var list in results) {
      for (var coctel in list) {
        coctelesMap[coctel.id] = coctel;
      }
    }
    return coctelesMap.values.toList();
  }

  // Busca cócteles considerados "fuertes" por su ingrediente principal.
  static Future<List<Coctel>> buscarCoctelesFuertes() async {
    return _fetchCoctelesPorIngredientes(["Vodka", "Gin", "Rum", "Tequila", "Whiskey"]);
  }
}

extension ApiServicioIngredientes on ApiServicio {
  
  // Devuelve tragos que contengan UN ingrediente.
  Future<List<DrinkSummary>> filterByIngredient(String ingredient) async {
    if (ingredient.trim().isEmpty) return [];
    final uri = Uri.parse('${ApiServicio._baseUrl}/filter.php?i=${_toToken(ingredient)}');
    final res = await http.get(uri);
    if (res.statusCode != 200) return [];
    final body = json.decode(res.body) as Map<String, dynamic>;
    final list = (body['drinks'] as List?) ?? [];
    return list.map((e) => DrinkSummary.fromJson(e as Map<String, dynamic>)).toList();
  }
  // Búsqueda por varios ingredientes combinados.
  Future<List<DrinkSummary>> filterByIngredients(List<String> ingredients) async {
    
    // Limpieza básica
    final cleaned = ingredients
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    if (cleaned.isEmpty) return [];

    // Llamadas en paralelo a filter.php?i=<ingrediente>
    final lists = await Future.wait(cleaned.map(filterByIngredient));

    if (lists.isEmpty) return [];
    // Índice global por id para reconstruir la intersección
    final index = <String, DrinkSummary>{
      for (final d in lists.expand((x) => x)) d.id: d
    };

    // Intersección progresiva de IDs
    Set<String> common = lists.first.map((d) => d.id).toSet();
    for (int i = 1; i < lists.length; i++) {
      final ids = lists[i].map((d) => d.id).toSet();
      common = common.intersection(ids);
      if (common.isEmpty) break;
    }
    return common.map((id) => index[id]).whereType<DrinkSummary>().toList();
  }
  // Detalle completo de un trago por ID 
  Future<Map<String, dynamic>?> lookupDrink(String idDrink) async {
    final uri = Uri.parse('${ApiServicio._baseUrl}/lookup.php?i=$idDrink');
    final res = await http.get(uri);
    if (res.statusCode != 200) return null;
    final data = json.decode(res.body) as Map<String, dynamic>;
    final drinks = data['drinks'] as List?;
    return (drinks == null || drinks.isEmpty) ? null : drinks.first as Map<String, dynamic>;
  }
  // Lista de ingredientes válidos para poblar tu UI (ESTA VERSIÓN DEBERÍA SER ELIMINADA O NO USADA)
  // Future<List<String>> listIngredients() async {
  //   final uri = Uri.parse('${ApiServicio._baseUrl}/list.php?i=list'); // URL Corregida aquí también
  //   final res = await http.get(uri);
  //   if (res.statusCode != 200) return [];
  //   final data = json.decode(res.body) as Map<String, dynamic>;
  //   final items = (data['drinks'] as List?) ?? [];
  //   return items
  //       .map((e) => (e as Map<String, dynamic>)['strIngredient1'] as String?)
  //       .whereType<String>()
  //       .toList();
  // }
}