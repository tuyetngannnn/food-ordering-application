import 'package:demo_firebase/screens/menu_screen.dart';
import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/category_service.dart';
import '../widgets/custom_loading.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final CategoryService _categoryService = CategoryService();
  late Future<List<Category>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _categoryService.getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Category>>(
                future: _categoriesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CustomLoading();
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error loading categories"));
                  }
                  final categories = snapshot.data ?? [];

                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return Padding(
                        padding: const EdgeInsets.all(0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MenuScreen(
                                  categoryId: category.categoryId,
                                  color: Color(int.parse(
                                      '0xFF${category.categoryColor}')),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            height: 300,
                            decoration: BoxDecoration(
                              color: Color(
                                  int.parse('0xFF${category.categoryColor}')),
                              borderRadius: BorderRadius.circular(0),
                              image: DecorationImage(
                                image: NetworkImage(category.categoryImg),
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
