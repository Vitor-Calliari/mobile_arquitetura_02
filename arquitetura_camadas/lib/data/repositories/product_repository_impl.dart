import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_datasource.dart';
import '../datasources/product_remote_datasource.dart';

/// Decide de onde os dados vêm: API remota (preferencial) ou cache local
/// (fallback quando a API não está disponível).
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;

  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<Product>> getProducts() async {
    try {
      final products = await remoteDataSource.getProducts();
      // Atualiza o cache sempre que a API responde com sucesso
      await localDataSource.saveProducts(products);
      return products;
    } catch (_) {
      // API falhou — tenta usar o cache local como fallback
      if (localDataSource.hasCache) {
        return localDataSource.getCachedProducts();
      }
      // Sem cache disponível, propaga o erro original
      rethrow;
    }
  }

  @override
  Future<List<Product>> getCachedProducts() {
    return localDataSource.getCachedProducts();
  }
}