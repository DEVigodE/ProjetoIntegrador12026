import 'package:dio/dio.dart';
import 'package:logdash_frontend_mobile/features/catalog/domain/category_model.dart';
import 'package:logdash_frontend_mobile/features/catalog/domain/product_model.dart';
import 'package:result_dart/result_dart.dart';

class CatalogService {
  final Dio _dio;

  CatalogService(this._dio);

  AsyncResult<List<CategoryModel>> getCategories() async {
    try {
      final response = await _dio.get('/api/categories');
      final list = (response.data as List<dynamic>)
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Success(list);
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = (data is Map) ? (data['message']?.toString() ?? 'Erro ao carregar categorias') : 'Erro ao carregar categorias';
      return Failure(Exception(msg));
    }
  }

  AsyncResult<List<ProductModel>> getProducts({
    int? categoryId,
    String? name,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final params = <String, dynamic>{
        'page': page,
        'size': size,
        'available': true,
      };
      if (categoryId != null) params['categoryId'] = categoryId;
      if (name != null && name.isNotEmpty) params['name'] = name;

      final response = await _dio.get('/api/products', queryParameters: params);
      final content = response.data['content'] as List<dynamic>;
      final list = content
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Success(list);
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = (data is Map) ? (data['message']?.toString() ?? 'Erro ao carregar produtos') : 'Erro ao carregar produtos';
      return Failure(Exception(msg));
    }
  }
}
