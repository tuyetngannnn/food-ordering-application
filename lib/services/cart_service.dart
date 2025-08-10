import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_firebase/models/cart_item.dart';
import 'package:demo_firebase/models/cart.dart'; // Make sure to import your Cart model
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get carts collection reference
  CollectionReference get _cartsRef => _firestore.collection('carts');

  // Get a reference to the cart items subcollection
  CollectionReference _getCartItemsRef(String cartId) {
    return _cartsRef.doc(cartId).collection('items');
  }

// Add this method to your cart service class
  Future<Cart> getCurrentCart() async {
    return await getOrCreateCart();
  }

  // Check if user has a cart already
  Future<Cart?> getUserCart() async {
    if (currentUserId == null) return null;

    try {
      final querySnapshot = await _cartsRef
          .where('userId', isEqualTo: currentUserId)
          .limit(1)
          .get();
      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final doc = querySnapshot.docs.first;
      // Create Cart object from document
      final cart = Cart.fromJson(doc.id, doc.data() as Map<String, dynamic>);

      // Get cart items from subcollection
      final itemsSnapshot =
          await _cartsRef.doc(cart.cartId).collection('items').get();
      // Convert cart items from documents to CartItem objects
      final cartItems = itemsSnapshot.docs.map((itemDoc) {
        return CartItem.fromJson(
            itemDoc.id, itemDoc.data() as Map<String, dynamic>);
      }).toList();

      // Update the cart with the fetched items
      return Cart(
        cartId: cart.cartId,
        cartItem: cartItems,
        userId: cart.userId,
        createdAt: cart.createdAt,
        updatedAt: cart.updatedAt,
      );
    } catch (e) {
      print('Error getting user cart: $e');
      return null;
    }
  }

  // Create a new cart for the user
  Future<Cart> createUserCart() async {
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    final now = DateTime.now();

    // Create a new cart with empty cart items
    final newCart = Cart(
      cartId: '', // Will be assigned by Firestore
      cartItem: [], // Empty cart items list
      userId: currentUserId!,
      createdAt: now,
      updatedAt: now,
    );

    // Save to Firestore
    final docRef = await _cartsRef.add({
      'userId': newCart.userId,
      'createdAt': newCart.createdAt,
      'updatedAt': newCart.updatedAt,
    });

    // Update the cart with the Firestore generated ID
    await docRef.update({'cartId': docRef.id});

    // Create and return cart with the assigned ID
    return Cart(
      cartId: docRef.id,
      cartItem: [],
      userId: currentUserId!,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Get or create cart
  Future<Cart> getOrCreateCart() async {
    final existingCart = await getUserCart();

    if (existingCart != null) {
      return existingCart;
    }

    return await createUserCart();
  }

  // Calculate total price based on product, size, and quantity
  double calculateTotalPrice({
    required Product product,
    required String selectedSizeId,
    required int quantity,
  }) {
    double basePrice = product.productPrice.toDouble();
    final selectedSize = getSelectedSize(
      product: product,
      selectedSizeId: selectedSizeId,
    );
    double extraPrice = selectedSize.extraPrice.toDouble();

    return (basePrice + extraPrice) * quantity;
  }

  // Get selected size information
  ProductSize getSelectedSize({
    required Product product,
    required String selectedSizeId,
  }) {
    return product.sizes.firstWhere((size) => size.sizeId == selectedSizeId);
  }

  // Add product to cart with UI feedback
  Future<void> addToCartWithFeedback({
    required Product product,
    required String selectedSizeId,
    required int quantity,
    required double totalPrice,
    required BuildContext context,
  }) async {
    if (currentUserId == null) {
      _showLoginRequiredDialog(context);
      return;
    }

    if (selectedSizeId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn kích thước')),
      );
      return;
    }

    try {
      await addToCart(
        product: product,
        selectedSizeId: selectedSizeId,
        quantity: quantity,
        totalPrice: totalPrice,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã thêm ${product.productName} vào giỏ hàng'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Show login required dialog
  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Đăng nhập yêu cầu'),
          content: const Text('Vui lòng đăng nhập để sử dụng giỏ hàng'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Huỷ'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to login screen
                Navigator.of(context).pushNamed('/login');
              },
              child: const Text('Đăng nhập'),
            ),
          ],
        );
      },
    );
  }

  // Add product to cart
  Future<void> addToCart({
    required Product product,
    required String selectedSizeId,
    required int quantity,
    required double totalPrice,
  }) async {
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    // Get or create a cart for this user
    Cart cart = await getOrCreateCart();

    // Find the selected size from the product
    final selectedSize = getSelectedSize(
      product: product,
      selectedSizeId: selectedSizeId,
    );

    // Get cart items subcollection reference
    final cartItemsRef = _getCartItemsRef(cart.cartId);

    // Check if the item already exists in the cart
    final querySnapshot = await cartItemsRef
        .where('productId', isEqualTo: product.productId)
        .where('sizeId', isEqualTo: selectedSizeId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Update existing cart item
      final doc = querySnapshot.docs.first;
      final existingItem =
          CartItem.fromJson(doc.id, doc.data() as Map<String, dynamic>);

      final unitPrice = existingItem.unitPrice;
      final newQuantity = existingItem.quantity + quantity;
      final updatedTotalPrice = unitPrice * newQuantity;

      // Update the cart item document
      await cartItemsRef.doc(existingItem.cartItemId).update({
        'quantity': newQuantity,
        'totalPrice': updatedTotalPrice,
        'updatedAt': DateTime.now(),
      });
    } else {
      // Create new cart item
      final unitPrice =
          (product.productPrice + selectedSize.extraPrice).toDouble();
      final now = DateTime.now();

      // Generate a unique ID for the cart item
      final String cartItemId =
          DateTime.now().millisecondsSinceEpoch.toString();
      // Create a new cart item
      final newCartItem = CartItem(
        cartItemId: cartItemId,
        productId: product.productId,
        sizeId: selectedSizeId,
        unitPrice: unitPrice,
        quantity: quantity,
        totalPrice: totalPrice,
        userId: currentUserId!,
        createdAt: now,
        updatedAt: now,
      );

      // Add the new item to the cart items subcollection
      await cartItemsRef.doc(cartItemId).set(newCartItem.toJson());
    }

    // Update the cart's updatedAt timestamp
    await _cartsRef.doc(cart.cartId).update({
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Get cart as stream
  Stream<Cart?> getCartStream() {
    if (currentUserId == null) {
      // Return empty stream if user is not logged in
      return Stream.value(null);
    }

    // Get the cart document stream
    return _cartsRef
        .where('userId', isEqualTo: currentUserId)
        .limit(1)
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) {
        return null;
      }

      final doc = snapshot.docs.first;
      final cartId = doc.id;

      // Create cart without items first
      final cart = Cart.fromJson(cartId, doc.data() as Map<String, dynamic>);

      // Get the cart items from subcollection
      final itemsSnapshot = await _getCartItemsRef(cartId).get();

      // Convert to CartItem objects
      final cartItems = itemsSnapshot.docs.map((itemDoc) {
        return CartItem.fromJson(
            itemDoc.id, itemDoc.data() as Map<String, dynamic>);
      }).toList();

      // Return the complete cart with items
      return Cart(
        cartId: cart.cartId,
        cartItem: cartItems,
        userId: cart.userId,
        createdAt: cart.createdAt,
        updatedAt: cart.updatedAt,
      );
    });
  }

// Get cart total
  Future<double> getCartTotal() async {
    if (currentUserId == null) {
      return 0.0;
    }

    final cart = await getUserCart();
    if (cart == null) {
      return 0.0;
    }

    double total = 0;
    for (var item in cart.cartItem) {
      total += item.totalPrice.toDouble();
    }
    return total;
  }

  // Remove item from cart
  Future<CartItem?> removeFromCart(String cartItemId) async {
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    // Get the current cart
    final cart = await getUserCart();
    if (cart == null) {
      throw Exception('Cart not found');
    }

    // Find the item to remove
    int itemIndex =
        cart.cartItem.indexWhere((item) => item.cartItemId == cartItemId);
    if (itemIndex < 0) {
      throw Exception('Cart item not found');
    }

    // Get the item to be removed (for undo functionality)
    final removedItem = cart.cartItem[itemIndex];

    // Remove the item from the subcollection
    await _getCartItemsRef(cart.cartId).doc(cartItemId).delete();

    // Update the cart's updatedAt timestamp
    await _cartsRef.doc(cart.cartId).update({
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return removedItem;
  }

  // Undo remove from cart
  Future<void> undoRemoveFromCart(CartItem removedItem) async {
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    // Get the current cart
    final cart = await getUserCart();
    if (cart == null) {
      throw Exception('Cart not found');
    }

    // Add the item back to the subcollection
    await _getCartItemsRef(cart.cartId)
        .doc(removedItem.cartItemId)
        .set(removedItem.toJson());

    // Update the cart's updatedAt timestamp
    await _cartsRef.doc(cart.cartId).update({
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Update cart item quantity
  Future<void> updateCartItemQuantity(String cartItemId, int quantity) async {
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    // Get the current cart
    final cart = await getUserCart();
    if (cart == null) {
      throw Exception('Cart not found');
    }

    // Find the item to update
    int itemIndex =
        cart.cartItem.indexWhere((item) => item.cartItemId == cartItemId);
    if (itemIndex < 0) {
      throw Exception('Cart item not found');
    }

    // Get the current item
    final currentItem = cart.cartItem[itemIndex];

    // Calculate new total price
    final newTotalPrice = currentItem.unitPrice * quantity;

    // Update the item in the subcollection
    await _getCartItemsRef(cart.cartId).doc(cartItemId).update({
      'quantity': quantity,
      'totalPrice': newTotalPrice,
      'updatedAt': DateTime.now(),
    });

    // Update the cart's updatedAt timestamp
    await _cartsRef.doc(cart.cartId).update({
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Clear cart
  Future<void> clearCart() async {
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    // Get the current cart
    final cart = await getUserCart();
    if (cart == null) return;

    // Get all cart items
    final itemsSnapshot = await _getCartItemsRef(cart.cartId).get();

    // Delete each item in a batch
    final batch = _firestore.batch();
    for (var doc in itemsSnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    // Update the cart's updatedAt timestamp
    await _cartsRef.doc(cart.cartId).update({
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Update cart item with UI feedback
  Future<void> updateCartItemWithFeedback({
    required Product product,
    required String cartItemId,
    required String selectedSizeId,
    required int quantity,
    required BuildContext context,
  }) async {
    if (currentUserId == null) {
      _showLoginRequiredDialog(context);
      return;
    }

    if (selectedSizeId.isEmpty || cartItemId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Lỗi: Thiếu thông tin kích thước hoặc mã giỏ hàng')),
      );
      return;
    }

    try {
      // Get the current cart
      final cart = await getUserCart();
      if (cart == null) {
        throw Exception('Cart not found');
      }

      // Find the item to update in the local cart object
      int itemIndex =
          cart.cartItem.indexWhere((item) => item.cartItemId == cartItemId);
      if (itemIndex < 0) {
        throw Exception('Cart item not found');
      }

      // Get the selected size information
      final selectedSize = getSelectedSize(
        product: product,
        selectedSizeId: selectedSizeId,
      );

      // Calculate unit price and total price
      final unitPrice =
          (product.productPrice + selectedSize.extraPrice).toDouble();
      final totalPrice = unitPrice * quantity;

      // Get the creation date from the existing item
      final createdAt = cart.cartItem[itemIndex].createdAt;

      // Update the cart item directly in the subcollection
      await _cartsRef
          .doc(cart.cartId)
          .collection('items')
          .doc(cartItemId)
          .update({
        'productId': product.productId,
        'sizeId': selectedSizeId,
        'unitPrice': unitPrice,
        'quantity': quantity,
        'totalPrice': totalPrice,
        'userId': currentUserId,
        'updatedAt': DateTime.now(),
      });

      // Update the cart's updatedAt timestamp
      await _cartsRef.doc(cart.cartId).update({
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã cập nhật ${product.productName} trong giỏ hàng'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Return to the cart page
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Edit cart item - change size and/or quantity
  Future<void> editCartItem({
    required String cartItemId,
    required String selectedSizeId,
    required double unitPrice,
    required int quantity,
  }) async {
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    // Get the current cart
    final cart = await getUserCart();
    if (cart == null) {
      throw Exception('Cart not found');
    }

    // Find the item to update in the local cart object
    int itemIndex =
        cart.cartItem.indexWhere((item) => item.cartItemId == cartItemId);
    if (itemIndex < 0) {
      throw Exception('Cart item not found');
    }

    // Get the current item
    final currentItem = cart.cartItem[itemIndex];

    // Calculate total price
    final totalPrice = unitPrice * quantity;

    // Update the item in the subcollection
    await _cartsRef
        .doc(cart.cartId)
        .collection('items')
        .doc(cartItemId)
        .update({
      'sizeId': selectedSizeId,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'updatedAt': DateTime.now(),
    });

    // Update the cart's updatedAt timestamp
    await _cartsRef.doc(cart.cartId).update({
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
