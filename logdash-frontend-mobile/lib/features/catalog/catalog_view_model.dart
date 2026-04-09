import 'package:logdash_frontend_mobile/features/catalog/data/catalog_repository.dart';
import 'package:logdash_frontend_mobile/features/catalog/domain/category_model.dart';
import 'package:logdash_frontend_mobile/features/catalog/domain/product_model.dart';
import 'package:signals_flutter/signals_flutter.dart';

class CatalogViewModel {
  final CatalogRepository _repository;

  CatalogViewModel(this._repository);

  final Signal<bool> isLoading = signal(false);
  final Signal<String?> errorMessage = signal(null);
  final Signal<List<CategoryModel>> categories = signal([]);
  final Signal<List<ProductModel>> products = signal([]);
  final Signal<int?> selectedCategoryId = signal(null);

  Future<void> loadCategories() async {
    final result = await _repository.getCategories();
    result.fold(
      (list) => categories.set(list.where((c) => c.active).toList()),
      (err) => errorMessage.set(_parseError(err)),
    );
  }

  Future<void> loadProducts({int? categoryId, String? name}) async {
    isLoading.set(true);
    errorMessage.set(null);
    final result =
        await _repository.getProducts(categoryId: categoryId, name: name);
    isLoading.set(false);
    result.fold(
      (list) => products.set(list),
      (err) => errorMessage.set(_parseError(err)),
    );
  }

  void selectCategory(int? categoryId) {
    selectedCategoryId.set(categoryId);
    loadProducts(categoryId: categoryId);
  }

  String _parseError(Exception err) =>
      err.toString().replaceFirst('Exception: ', '');
}
