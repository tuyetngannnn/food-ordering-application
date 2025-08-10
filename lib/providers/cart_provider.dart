import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/cart.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../services/product_service.dart';

class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService();
  final ProductService _productService = ProductService();
  Set<String> _loadingCartItemIds = {};
  bool isLoadingUpdate(String cartItemId) =>
      _loadingCartItemIds.contains(cartItemId);

  Cart? _cart;
  List<CartItem> _cartItems = [];
  List<Product> _products = [];
  Map<String, Product> _productMap = {};
  double _cartTotal = 0.0;
  bool _isLoading = true;
  String? _error;

  // Getters
  Cart? get cart => _cart;
  List<CartItem> get cartItems => _cartItems;
  List<Product> get products => _products;
  Map<String, Product> get productMap => _productMap;
  double get cartTotal => _cartTotal;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmpty => _cartItems.isEmpty;

  // Constructor - initialize the provider
  CartProvider() {
    _initCart();
  }

  // Initialize cart data
  Future<void> _initCart() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Listen to cart stream for real-time updates
      _cartService.getCartStream().listen((updatedCart) async {
        _cart = updatedCart;
        _cartItems = updatedCart?.cartItem ?? [];

        // Load products data for all cart items
        await _loadProductsForCartItems();

        // Calculate cart total
        await _calculateCartTotal();

        _isLoading = false;
        notifyListeners();
      }, onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      print('Error initializing cart: $e');
    }
  }

  int get totalItemCount {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  // Load product data for all cart items
  Future<void> _loadProductsForCartItems() async {
    _products = [];
    _productMap = {};

    for (var item in _cartItems) {
      try {
        // Only fetch product if we don't have it already
        if (!_productMap.containsKey(item.productId)) {
          final product =
              await _productService.getProductByProductId(item.productId);
          if (product != null) {
            _products.add(product);
            _productMap[item.productId] = product;
          }
        }
      } catch (e) {
        print('Error loading product ${item.productId}: $e');
      }
    }
  }

  // Calculate cart total
  Future<void> _calculateCartTotal() async {
    try {
      _cartTotal = await _cartService.getCartTotal();
    } catch (e) {
      print('Error calculating cart total: $e');
      _cartTotal = 0.0;
    }
  }

  // Get product for a cart item
  Product? getProductForCartItem(String productId) {
    return _productMap[productId];
  }

  // Get product size for a cart item
  ProductSize? getSizeForCartItem(CartItem item) {
    final product = _productMap[item.productId];
    if (product == null) return null;

    try {
      return product.sizes.firstWhere(
        (size) => size.sizeId == item.sizeId,
        orElse: () => ProductSize(
          sizeId: '',
          sizeName: 'Unknown Size',
          extraPrice: 0,
        ),
      );
    } catch (e) {
      return ProductSize(
        sizeId: '',
        sizeName: 'Unknown Size',
        extraPrice: 0,
      );
    }
  }

  // Add product to cart
  Future<void> addToCart({
    required Product product,
    required String selectedSizeId,
    required int quantity,
    required double totalPrice,
    required BuildContext context,
  }) async {
    try {
      await _cartService.addToCartWithFeedback(
        product: product,
        selectedSizeId: selectedSizeId,
        quantity: quantity,
        totalPrice: totalPrice,
        context: context,
      );
      // The cart stream will automatically update our state
    } catch (e) {
      print('Error adding to cart: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Có lỗi xảy ra: $e')),
        );
      }
    }
  }

  // Remove item from cart
  Future<CartItem?> removeFromCart(
      String cartItemId, BuildContext? context) async {
    try {
      final removedItem = await _cartService.removeFromCart(cartItemId);

      // Show undo option if context is provided
      if (removedItem != null && context != null && context.mounted) {
        final product = _productMap[removedItem.productId];
        final productName = product?.productName ?? 'Sản phẩm';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$productName đã bị xóa khỏi giỏ hàng'),
            action: SnackBarAction(
              label: 'HOÀN TÁC',
              onPressed: () async {
                await undoRemoveFromCart(removedItem);
              },
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }

      return removedItem;
    } catch (e) {
      print('Error removing from cart: $e');
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Có lỗi xảy ra: $e')),
        );
      }
      return null;
    }
  }

  // Undo remove from cart
  Future<void> undoRemoveFromCart(CartItem item) async {
    try {
      await _cartService.undoRemoveFromCart(item);
      // The cart stream will automatically update our state
    } catch (e) {
      print('Error undoing remove from cart: $e');
    }
  }

  // Update cart item quantity
  Future<void> updateQuantity(String cartItemId, int quantity) async {
    try {
      await _cartService.updateCartItemQuantity(cartItemId, quantity);
      notifyListeners(); // Cập nhật UI
    } catch (e) {
      print('Error updating quantity: $e');
    }
  }

  // Show confirmation dialog before removing item
  Future<bool> showRemoveItemDialog(
      BuildContext context, String cartItemId) async {
    final cartItem = _cartItems.firstWhere(
      (item) => item.cartItemId == cartItemId,
      // orElse: () => CartItem(
      //   cartItemId: '',
      //   productId: '',
      //   sizeId: '',
      //   quantity: 0,
      //   unitPrice: 0,
      // ),
    );

    if (cartItem.cartItemId.isEmpty) return false;

    final product = _productMap[cartItem.productId];
    if (product == null) return false;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa sản phẩm'),
        content:
            Text('Bạn có muốn xóa ${product.productName} khỏi giỏ hàng không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('HỦY'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('XÓA'),
          ),
        ],
      ),
    );

    if (result == true) {
      await removeFromCart(cartItemId, context);
      return true;
    }

    return false;
  }

  // Clear cart
  Future<void> clearCart() async {
    try {
      await _cartService.clearCart();
      // The cart stream will automatically update our state
    } catch (e) {
      print('Error clearing cart: $e');
    }
  }

  // Refresh cart data (useful when coming back to the screen)
  void refreshCart() {
    _initCart();
  }
}
