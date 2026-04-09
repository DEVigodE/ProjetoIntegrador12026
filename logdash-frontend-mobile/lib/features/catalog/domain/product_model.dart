class ProductModel {
  final int id;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final bool available;
  final int stockQuantity;
  final int? categoryId;
  final String? categoryName;

  const ProductModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    required this.available,
    required this.stockQuantity,
    this.categoryId,
    this.categoryName,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
      available: json['available'] as bool? ?? true,
      stockQuantity: json['stockQuantity'] as int? ?? 0,
      categoryId: json['categoryId'] as int?,
      categoryName: json['categoryName'] as String?,
    );
  }
}
