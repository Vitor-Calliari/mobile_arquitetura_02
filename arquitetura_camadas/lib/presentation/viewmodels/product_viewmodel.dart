import 'package:arquitetura_camadas/domain/entities/product.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/product_repository.dart';
import 'product_state.dart';

class ProductViewModel extends ChangeNotifier {
  final ProductRepository _repository;

  ProductState _state = ProductLoading();

  ProductState get state => _state;

  ProductViewModel(this._repository);

  Future<void> loadProducts() async {
    _state = ProductLoading();
    notifyListeners();

    try {
      final products = await _repository.getProducts();
      _state = ProductSuccess(products: products);
    } catch (e) {
      final cached = await _tryGetCached();
      _state = ProductError(
        message: _humanReadableError(e),
        cachedProducts: cached,
      );
    }

    notifyListeners();
  }

  Future<List<Product>?> _tryGetCached() async {
    try {
      return await _repository.getCachedProducts();
    } catch (_) {
      return null;
    }
  }

  String _humanReadableError(Object e) {
    final msg = e.toString();
    if (msg.contains('SocketException') ||
        msg.contains('Connection refused') ||
        msg.contains('Failed host lookup')) {
      return 'Sem conexão com a internet.';
    }
    if (msg.contains('TimeoutException')) {
      return 'A requisição demorou muito. Tente novamente.';
    }
    if (msg.contains('statusCode')) {
      return 'Erro no servidor. Tente novamente mais tarde.';
    }
    return 'Não foi possível carregar os produtos. Tente novamente.';
  }
}