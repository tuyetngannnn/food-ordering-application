import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../services/favourite_service.dart';
import '../widgets/cart_badge.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_loading.dart';
import '../widgets/product_card_widget.dart';
import 'package:demo_firebase/screens/product_detail_screen.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  _FavouriteScreenState createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  final FavouriteService _favouriteService = FavouriteService();
  final ProductService _productService = ProductService();
  late Future<List<Product>> _favouriteProductsFuture;
  Map<String, bool> _favouriteStatus = {};

  @override
  void initState() {
    super.initState();
    _loadFavouriteProducts();
  }

  Future<void> _loadFavouriteProducts() async {
    setState(() {
      _favouriteProductsFuture = _fetchFavouriteProducts();
    });
  }

  Future<List<Product>> _fetchFavouriteProducts() async {
    try {
      // Get all favorites for the current user
      final favourites = await _favouriteService.getFavourites();

      // Initialize favorite status map
      Map<String, bool> newStatus = {};
      List<Product> products = [];

      // Fetch each product by ID
      for (var favourite in favourites) {
        try {
          final product =
              await _productService.getProductByProductId(favourite.productId);
          if (product != null) {
            products.add(product);
            newStatus[favourite.productId] = true;
          }
        } catch (e) {
          print("Error fetching product ${favourite.productId}: $e");
        }
      }

      // Update favorite status
      if (mounted) {
        setState(() {
          _favouriteStatus = newStatus;
        });
      }

      return products;
    } catch (e) {
      print("Error loading favourite products: $e");
      return [];
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
      if (!newStatus) {
        // If product was removed from favorites, reload the list
        _loadFavouriteProducts();
      } else {
        setState(() {
          _favouriteStatus[product.productId] = newStatus;
        });
      }
    }
  }

  // Check if a product is favorite
  bool _isProductFavourite(String productId) {
    return _favouriteStatus[productId] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.only(top: 20.0),
          child: Text(
            "Yêu thích",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 100,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _favouriteProductsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CustomLoading();
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Lỗi khi tải danh sách yêu thích"));
                }
                final products = snapshot.data ?? [];
                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/fav_icon.png',
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Chưa có sản phẩm yêu thích nào",
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFFFD0000),
                          ),
                        ),
                        Text(
                          "Hãy thêm sản phẩm yêu thích để dễ dàng tìm kiếm",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF000000),
                          ),
                        ),
                      ],
                    ),
                  );
                }

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
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ).then((_) {
                            // Reload favorites when returning from product detail
                            _loadFavouriteProducts();
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
