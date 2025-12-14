// models/product.dart
class Product {
  final String id;
  final String name;
  final String description;
  final String price;
  final String salePrice;
  // final String imageUrl;
  final List<String> imageUrl;
  final String videoUrl;
  final String videoType; // "drive" or "youtube"
  // final String category;
  final List<String> tags;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.salePrice,
    required this.imageUrl,
    required this.videoUrl,
    required this.videoType,
    // required this.category,
    required this.tags,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map["id"] ?? "",
      name: map["name"] ?? "",
      description: map["description"] ?? "",
      price: map["price"] ?? "",
      salePrice: map["salePrice"] ?? "",
      // imageUrl: map["imageUrl"] ?? "",
      imageUrl: map["imageUrl"] != null ? map["imageUrl"].toString().split(",").map((e) => e.trim()).toList() : [],
      videoUrl: map["videoUrl"] ?? "",
      videoType: map["videoType"] ?? "drive",
      // category: map["category"] ?? "General",
      tags: map["tags"] != null ? map["tags"].toString().split(",").map((e) => e.trim()).toList() : [],
    );
  }
}
