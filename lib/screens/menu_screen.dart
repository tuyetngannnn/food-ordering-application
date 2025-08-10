import 'package:demo_firebase/screens/product_detail_screen.dart';
import 'package:demo_firebase/widgets/custom_loading.dart';
import 'package:demo_firebase/widgets/product_card_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/custom_app_bar.dart';
import '../services/favourite_service.dart';

class MenuScreen extends StatefulWidget {
  final String? categoryId;
  final Color color;

  const MenuScreen({super.key, this.categoryId, required this.color});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final ProductService _productService = ProductService();
  late Future<List<Product>> _productsFuture;
  final FavouriteService _favouriteService = FavouriteService();
// Store favorite status for each product
  Map<String, bool> _favouriteStatus = {};
  bool _isFavouritesLoaded = false;
  @override
  void initState() {
    super.initState();

    if (widget.categoryId != null) {
      _productsFuture =
          _productService.getProductsByCategory(widget.categoryId ?? '');
    } else {
      _productsFuture = _productService.getProducts();
    }
    _loadFavouriteStatus();
  }

// Load favorite status for all products
  Future<void> _loadFavouriteStatus() async {
    try {
      // Get all favorites for the current user
      final favourites = await _favouriteService.getFavourites();

      // Create a map of productId to favorite status for quick lookup
      Map<String, bool> newStatus = {};
      for (var favourite in favourites) {
        newStatus[favourite.productId] = true;
      }

      if (mounted) {
        setState(() {
          _favouriteStatus = newStatus;
          _isFavouritesLoaded = true;
        });
      }
    } catch (e) {
      print("Error loading favourite status: $e");
    }
  }

  // Handle toggling favorite status
  Future<void> _toggleFavourite(Product product) async {
    final bool newStatus = await _favouriteService.toggleFavourite(
      product.productId,
      context,
      product.productName,
    );

    if (mounted) {
      setState(() {
        _favouriteStatus[product.productId] = newStatus;
      });
    }
  }

  // Check if a product is favorite
  bool _isProductFavourite(String productId) {
    return _favouriteStatus[productId] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: customAppBar(context, 'Thực đơn'),
      body: Column(
        children: [
          // Products List
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CustomLoading();
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error loading products"));
                }
                final products = snapshot.data ?? [];

                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.6,
                      crossAxisSpacing: 25,
                      mainAxisSpacing: 25,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final item = products[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(
                                product: item,
                                color: widget.color,
                              ),
                            ),
                          ).then((_) {
                            // Reload favorites when returning from product detail
                            _loadFavouriteStatus();
                          });
                        },
                        child: ProductCardWidget(
                          product: item,
                          isFavorite: _isProductFavourite(item.productId),
                          onFavoriteTapped: () {
                            _toggleFavourite(item);
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
