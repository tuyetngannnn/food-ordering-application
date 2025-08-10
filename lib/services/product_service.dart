import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Product>> getProducts() async {
    try {
      // Fetch products by categoryId
      QuerySnapshot productSnapshot = await _firestore
          .collection("products")
          .get();

      List<Product> products = productSnapshot.docs.map((doc) {
        return Product.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();

      // Fetch sizes for each product
      for (var product in products) {
        QuerySnapshot sizeSnapshot = await _firestore
            .collection("products")
            .doc(product.productId)
            .collection("size")
            .get();

        product.sizes = sizeSnapshot.docs
            .map((doc) => ProductSize.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
      }

      return products;
    } catch (e) {
      print("Error fetching products: $e");
      return [];
    }
  }

  Future<List<Product>> getProductsByCategory(String categoryId) async {
    try {
      // Fetch products by categoryId
      QuerySnapshot productSnapshot = await _firestore
          .collection("products")
          .where("categoryId", isEqualTo: categoryId)
          .get();

      List<Product> products = productSnapshot.docs.map((doc) {
        return Product.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();

      // Fetch sizes for each product
      for (var product in products) {
        QuerySnapshot sizeSnapshot = await _firestore
            .collection("products")
            .doc(product.productId)
            .collection("size") // Fetch from subcollection
            .get();

        product.sizes = sizeSnapshot.docs
            .map((doc) => ProductSize.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
      }

      return products;
    } catch (e) {
      print("Error fetching products: $e");
      return [];
    }
  }

  Future<Product?> getProductByProductId(String productId) async {
    try {
      // Fetch the product document directly using its ID
      DocumentSnapshot productDoc = await _firestore
          .collection("products")
          .doc(productId)
          .get();

      if (!productDoc.exists) {
        return null; // Return null if product doesn't exist
      }

      // Create the product from the document data
      Product product = Product.fromJson(productDoc.data() as Map<String, dynamic>);

      // Fetch sizes for the product
      QuerySnapshot sizeSnapshot = await _firestore
          .collection("products")
          .doc(productId)
          .collection("size")
          .get();

      product.sizes = sizeSnapshot.docs
          .map((doc) => ProductSize.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return product;
    } catch (e) {
      print("Error fetching product: $e");
      return null;
    }
  }
 
}

