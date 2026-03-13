import '../models/product_model.dart';

/// DataSource responsável apenas por operações de IO de cache local.
/// Por ora, o cache é mantido em memória durante a sessão.
/// Pode ser substituído por SharedPreferences ou SQLite sem afetar outras camadas.
class ProductLocalDataSource {
  List<ProductModel>? _cachedProducts;

  /// Retorna os produtos em cache, ou lança exceção se não houver cache.
  Future<List<ProductModel>> getCachedProducts() async {
    final cache = _cachedProducts;
    if (cache == null || cache.isEmpty) {
      throw Exception('Nenhum dado em cache disponível.');
    }
    return cache;
  }

  /// Persiste a lista de produtos no cache local.
  Future<void> saveProducts(List<ProductModel> products) async {
    _cachedProducts = List.unmodifiable(products);
  }

  /// Indica se existe algum dado em cache.
  bool get hasCache => _cachedProducts != null && _cachedProducts!.isNotEmpty;
}
