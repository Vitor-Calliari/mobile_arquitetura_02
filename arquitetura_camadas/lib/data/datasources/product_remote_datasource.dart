import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../../core/network/api_client.dart';

/// DataSource responsável apenas por buscar produtos da API remota.
class ProductRemoteDataSource {
  static const _baseUrl = 'https://fakestoreapi.com/products';

  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await http
          .get(Uri.parse(_baseUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List jsonList = json.decode(response.body);
        return jsonList
            .map((product) => ProductModel.fromJson(product))
            .toList();
      } else {
        throw NetworkException(
          'Erro do servidor (código ${response.statusCode}).',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw const NetworkException(
        'Sem conexão com a internet.',
      );
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException('Erro inesperado: $e');
    }
  }
}