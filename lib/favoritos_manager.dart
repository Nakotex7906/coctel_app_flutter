import 'coctel.dart';

class FavoritosManager {
  static final List<Coctel> _favoritos = [];

  static List<Coctel> obtenerFavoritos() {
    return _favoritos;
  }

  static void agregarFavorito(Coctel coctel) {
    if (!_favoritos.any((c) => c.id == coctel.id)) {
      _favoritos.add(coctel);
    }
  }

  static void removerFavorito(String id) {
    _favoritos.removeWhere((c) => c.id == id);
  }

  static bool esFavorito(String id) {
    return _favoritos.any((c) => c.id == id);
  }
}
