import 'package:logdash_frontend_mobile/features/catalog/data/catalog_service.dart';
import 'package:logdash_frontend_mobile/features/catalog/domain/category_model.dart';
import 'package:logdash_frontend_mobile/features/catalog/domain/product_model.dart';
import 'package:result_dart/result_dart.dart';

class CatalogRepository {
  final CatalogService _service;

  CatalogRepository(this._service);

  AsyncResult<List<CategoryModel>> getCategories() => _service.getCategories();

  AsyncResult<List<ProductModel>> getProducts({
    int? categoryId,
    String? name,
    int page = 0,
  }) =>
      _service.getProducts(categoryId: categoryId, name: name, page: page);
}
