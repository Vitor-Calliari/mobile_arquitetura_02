import 'package:flutter/material.dart';
import '../../data/datasources/product_local_datasource.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/entities/product.dart';
import '../viewmodels/product_state.dart';
import '../viewmodels/product_viewmodel.dart';
import '../widgets/product_tile.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late final ProductViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = ProductViewModel(
      ProductRepositoryImpl(
        remoteDataSource: ProductRemoteDataSource(),
        localDataSource: ProductLocalDataSource(),
      ),
    );

    _viewModel.addListener(_onStateChange);
    _viewModel.loadProducts();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onStateChange);
    _viewModel.dispose();
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recarregar',
            onPressed: _viewModel.loadProducts,
          ),
        ],
      ),
      body: _buildBody(_viewModel.state),
    );
  }

  Widget _buildBody(ProductState state) {
    return switch (state) {
      ProductLoading() => const Center(child: CircularProgressIndicator()),
      ProductSuccess(
        products: final products,
        fromCache: final fromCache,
      ) =>
        _buildProductList(
          products,
          banner: fromCache ? _cacheBanner() : null,
        ),
      ProductError(
        message: final message,
        cachedProducts: final cached,
      ) =>
        cached != null && cached.isNotEmpty
            ? _buildProductList(
                cached,
                banner: _errorBanner(message),
              )
            : _buildFullError(message),
    };
  }

  Widget _buildProductList(
    List<Product> products, {
    Widget? banner,
  }) {
    return Column(
      children: [
        if (banner != null) banner,
        Expanded(
          child: ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) =>
                ProductTile(product: products[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildFullError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _viewModel.loadProducts,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorBanner(String message) {
    return MaterialBanner(
      backgroundColor: Colors.red.shade50,
      leading: const Icon(Icons.warning_amber, color: Colors.red),
      content: Text(
        '$message Exibindo dados anteriores.',
        style: const TextStyle(color: Colors.red),
      ),
      actions: [
        TextButton(
          onPressed: _viewModel.loadProducts,
          child: const Text('Tentar novamente'),
        ),
      ],
    );
  }

  Widget _cacheBanner() {
    return MaterialBanner(
      backgroundColor: Colors.amber.shade50,
      leading: const Icon(Icons.cached, color: Colors.orange),
      content: const Text(
        'Exibindo dados do cache local.',
        style: TextStyle(color: Colors.orange),
      ),
      actions: [
        TextButton(
          onPressed: _viewModel.loadProducts,
          child: const Text('Atualizar'),
        ),
      ],
    );
  }
}
