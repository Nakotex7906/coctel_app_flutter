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

    // Se asegura de que no haya duplicados por ID al agregar
    if (!_coctelesCreados.any((c) => c.id == coctel.id)) {
      _coctelesCreados.add(coctel);
      await _guardar();
      notifyListeners();
    } else {
      if (kDebugMode) {
        print("Intento de agregar cóctel con ID duplicado: ${coctel.id}");
      }
    }
  }

  // Eliminar un cóctel por su ID
  Future<void> eliminarCoctel(String coctelId) async {
    final originalLength = _coctelesCreados.length;
    _coctelesCreados.removeWhere((coctel) => coctel.id == coctelId);
    if (_coctelesCreados.length < originalLength) {

      // Solo guardar y notificar si algo cambió
      await _guardar();
      notifyListeners();
      if (kDebugMode) {
        print("Cóctel eliminado con ID: $coctelId");
      }
    } else {
      if (kDebugMode) {
        print("No se encontró cóctel para eliminar con ID: $coctelId");
      }
    }
  }

  // Actualizar un cóctel existente
  Future<void> actualizarCoctel(Coctel coctelActualizado) async {
    final index = _coctelesCreados.indexWhere((coctel) => coctel.id == coctelActualizado.id);
    if (index != -1) {
      _coctelesCreados[index] = coctelActualizado;
      await _guardar();
      notifyListeners();
      if (kDebugMode) {
        print("Cóctel actualizado con ID: ${coctelActualizado.id}");
      }
    } else {
      if (kDebugMode) {
        print("No se encontró cóctel para actualizar con ID: ${coctelActualizado.id}");
      }
    }
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
