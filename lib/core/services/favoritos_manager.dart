import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/coctel.dart';

class FavoritosManager extends ChangeNotifier {
  List<Coctel> _favoritos = [];
  static const String _clave = "favoritos";

  List<Coctel> get favoritos => _favoritos;

  FavoritosManager() {
    cargarFavoritos();
  }

  /// Inicializa favoritos desde SharedPreferences
  Future<void> cargarFavoritos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getStringList(_clave) ?? [];

      if (kDebugMode) {
        print("📥 Datos cargados de SharedPreferences: $data");
      }

      _favoritos = data.map((jsonStr) => Coctel.fromJson(json.decode(jsonStr))).toList();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error cargando favoritos: $e");
      }
    }
  }

  /// Agrega un cóctel a favoritos
  Future<void> agregarFavorito(Coctel coctel) async {
    if (!_favoritos.any((c) => c.id == coctel.id)) {
      _favoritos.add(coctel);
      await _guardar();
      notifyListeners();
    }
  }

  /// Quita un cóctel de favoritos
  Future<void> eliminarFavorito(Coctel coctel) async {
    _favoritos.removeWhere((c) => c.id == coctel.id);
    await _guardar();
    notifyListeners();
  }

  /// Verifica si un cóctel ya está en favoritos
  bool esFavorito(String id) {
    return _favoritos.any((c) => c.id == id);
  }

  /// Alterna un cóctel (si está lo quita, si no lo agrega)
  Future<void> toggleFavorito(Coctel coctel) async {
    if (esFavorito(coctel.id)) {
      eliminarFavorito(coctel);
    } else {
      agregarFavorito(coctel);
    }
  }

  /// Guarda la lista de favoritos en SharedPreferences
  Future<void> _guardar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _favoritos.map((c) => json.encode(c.toJson())).toList();

      if (kDebugMode) {
        print("💾 Guardando en SharedPreferences: $data");
      }

      await prefs.setStringList(_clave, data);
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error guardando favoritos: $e");
      }
    }
  }
}