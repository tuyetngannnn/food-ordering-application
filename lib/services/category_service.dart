import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart';
import '../models/product.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Category>> getCategories() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection("categories").get();
      return snapshot.docs.map((doc) => Category.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print("Error fetching categories: $e");
      return [];
    }
  }
}