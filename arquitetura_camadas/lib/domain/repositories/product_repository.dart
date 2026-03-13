import '../entities/product.dart';

abstract class ProductRepository {
  /// Retorna produtos — da API ou do cache, conforme disponibilidade.
  Future<List<Product>> getProducts();

  /// Retorna apenas os dados em cache local (pode lançar exceção se vazio).
  Future<List<Product>> getCachedProducts();
}