class Product {
  final String productId;
  final String productName;
  final String productImg;
  final int productPreparationTime;
  final int productCalo;
  final num productPrice;
  final String productDescription;
  final bool productStatus;
  final String categoryId;
  List<ProductSize> sizes;  // Make it mutable since we update later

  Product({
    required this.productId,
    required this.productName,
    required this.productImg,
    required this.productPreparationTime,
    required this.productCalo,
    required this.productPrice,
    required this.productDescription,
    required this.productStatus,
    required this.categoryId,
    this.sizes = const [], // Default empty list
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json["productId"] ?? "",
      productName: json["productName"] ?? "Unknown",
      productImg: json["productImg"] ?? "",
      productPreparationTime: json["productPreparationTime"] ?? 0,
      productCalo: json["productCalo"] ?? 0,
      productPrice: json["productPrice"] ?? 0  ,
      productDescription: json["productDescription"] ?? "",
      productStatus: json["productStatus"] ?? false,
      categoryId: json["categoryId"] ?? "",
    );
  }
}

class ProductSize {
  final String sizeId;
  final String sizeName;
  final num extraPrice;

  ProductSize({
    required this.sizeId,
    required this.sizeName,
    required this.extraPrice,
  });

  factory ProductSize.fromJson(Map<String, dynamic> json) {
    return ProductSize(
      sizeId: json["sizeId"],
      sizeName: json["sizeName"],
      extraPrice: json["extraPrice"],
    );
  }
}