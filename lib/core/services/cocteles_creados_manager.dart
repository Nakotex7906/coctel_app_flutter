import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coctel_app/core/models/coctel.dart';

class CoctelesCreadosManager extends ChangeNotifier {
  List<Coctel> _coctelesCreados = [];
  static const String _clave = "cocteles_creados";

  List<Coctel> get coctelesCreados => _coctelesCreados;

  CoctelesCreadosManager() {
    cargarCoctelesCreados();
  }

  Future<void> cargarCoctelesCreados() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getStringList(_clave) ?? [];

      if (kDebugMode) {
        print("Datos cargados de SharedPreferences (creados): $data");
      }

      _coctelesCreados = data.map((jsonStr) => Coctel.fromJson(json.decode(jsonStr))).toList();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print("Error cargando cócteles creados: $e");
      }
    }
  }

  Future<void> agregarCoctel(Coctel coctel) async {
    _coctelesCreados.add(coctel);
    await _guardar();
    notifyListeners();
  }

  Future<void> _guardar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _coctelesCreados.map((c) => json.encode(c.toJson())).toList();

      if (kDebugMode) {
        print("Guardando en SharedPreferences (creados): $data");
      }

      await prefs.setStringList(_clave, data);
    } catch (e) {
      if (kDebugMode) {
        print("Error guardando cócteles creados: $e");
      }
    }
  }
}
