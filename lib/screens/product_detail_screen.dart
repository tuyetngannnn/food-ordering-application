import 'package:demo_firebase/models/product.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/product_service.dart';
import '../services/cart_service.dart';
import '../services/favourite_service.dart';
import '../utils/utils.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final Color color;
// New parameters for edit mode
  final bool isEditingCart;
  final String? cartItemId;
  final String? initialSizeId;
  final int? initialQuantity;
  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.color,
    this.isEditingCart = false,
    this.cartItemId,
    this.initialSizeId,
    this.initialQuantity,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? selectedSizeId;
  int quantity = 1;
  bool _isAddingToCart = false;
  final CartService _cartService = CartService();
  bool _isProcessing = false;
  final FavouriteService _favouriteService = FavouriteService();
  bool _isFavourite = false;
  bool _isLoadingFavourite = true;
  @override
  void initState() {
    super.initState();
    // Use initial values if editing cart item, otherwise use defaults
    if (widget.isEditingCart && widget.initialSizeId != null) {
      selectedSizeId = widget.initialSizeId;
      quantity = widget.initialQuantity ?? 1;
    } else {
      // Set the first size as default if available
      selectedSizeId = widget.product.sizes.first.sizeId;
    }
    // Check if product is in favorites
    _checkFavouriteStatus();
  }

// Check if this product is in favorites - just a simple UI state setter
  Future<void> _checkFavouriteStatus() async {
    setState(() {
      _isLoadingFavourite = true;
    });

    try {
      // Use the service to check if product is favorited
      bool isFav =
          await _favouriteService.isFavourite(widget.product.productId);
      setState(() {
        _isFavourite = isFav;
      });
    } catch (e) {
      print("Error checking favorite status: $e");
    } finally {
      setState(() {
        _isLoadingFavourite = false;
      });
    }
  }

  // Toggle favorite status - simplified to use the service
  Future<void> _toggleFavourite() async {
    setState(() {
      _isLoadingFavourite = true;
    });

    try {
      // Use the service to toggle favorite status and handle notifications
      bool newStatus = await _favouriteService.toggleFavourite(
          widget.product.productId, context, widget.product.productName);

      // Just update the UI state
      setState(() {
        _isFavourite = newStatus;
      });
    } catch (e) {
      print("Error toggling favorite: $e");
    } finally {
      setState(() {
        _isLoadingFavourite = false;
      });
    }
  }

  double get totalPrice {
    double basePrice = widget.product.productPrice.toDouble();
    double extraPrice = 0;

    final selectedSize = widget.product.sizes
        .firstWhere((size) => size.sizeId == selectedSizeId);

    extraPrice = selectedSize.extraPrice.toDouble();

    return (basePrice + extraPrice) * quantity;
  }

  // Add to cart function
  Future<void> _addToCart() async {
    if (selectedSizeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn kích thước')),
      );
      return;
    }

    setState(() {
      _isAddingToCart = true;
    });

    try {
      await _cartService.addToCart(
        product: widget.product,
        selectedSizeId: selectedSizeId!,
        quantity: quantity,
        totalPrice: totalPrice,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã thêm ${widget.product.productName} vào giỏ hàng'),
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
    } finally {
      setState(() {
        _isAddingToCart = false;
      });
    }
  }

// Update cart item function - new method
  Future<void> _updateCartItem() async {
    if (selectedSizeId == null || widget.cartItemId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Lỗi: Thiếu thông tin kích thước hoặc mã giỏ hàng')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Get the selected size information
      final selectedSize = widget.product.sizes
          .firstWhere((size) => size.sizeId == selectedSizeId);

      // Calculate unit price with the selected size
      final unitPrice =
          (widget.product.productPrice + selectedSize.extraPrice).toDouble();

      // Update cart item
      await _cartService.editCartItem(
        cartItemId: widget.cartItemId!,
        selectedSizeId: selectedSizeId!,
        unitPrice: unitPrice,
        quantity: quantity,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Đã cập nhật ${widget.product.productName} trong giỏ hàng'),
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
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: widget.color,
      appBar: AppBar(
        backgroundColor: widget.color,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: _isLoadingFavourite
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(_isFavourite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.white),
            onPressed: _isLoadingFavourite ? null : _toggleFavourite,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  // This Column contains the image and the white background
                  Column(
                    children: [
                      // Space for the product image
                      SizedBox(height: height * 0.2),

                      // White background container
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(30)),
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Add space for the overlapping image
                            SizedBox(height: height * 0.1),

                            // Product name
                            Text(
                              widget.product.productName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Preparation time and calories
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.timer,
                                    color: Colors.blue, size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  "${widget.product.productPreparationTime} phút",
                                  style: const TextStyle(color: Colors.blue),
                                ),
                                const SizedBox(width: 16),
                                const Icon(Icons.local_fire_department,
                                    color: Colors.red, size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  "${widget.product.productCalo} kcal",
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Size selection
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: widget.product.sizes
                                        .map<Widget>((size) {
                                      final bool isSelected =
                                          selectedSizeId == size.sizeId;
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              selectedSizeId = size.sizeId;
                                            });
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: isSelected
                                                    ? Colors.red
                                                    : Colors.grey[300]!,
                                                width: isSelected ? 2 : 2.5,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: Colors.white,
                                            ),
                                            child: Center(
                                              child: Text(
                                                size.sizeName,
                                                style: TextStyle(
                                                  color: isSelected
                                                      ? Colors.red
                                                      : Colors.grey[500],
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                SizedBox(height: 20),
                              ],
                            ),

                            // Description header
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Mô tả",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // Description
                                Text(
                                  widget.product.productDescription,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),

                            // Add extra space at the bottom for scrolling
                            SizedBox(height: height * 0.2),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Product image - positioned on top and will scroll with content
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Image.network(
                        widget.product.productImg,
                        height: height * 0.3,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Fixed bottom container - not scrollable
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Tổng tiền:",
                      style: TextStyle(
                        color: Color(0xFF655E5E),
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      Utils().formatCurrency(totalPrice),
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Quantity selection
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Decrease Button
                        InkWell(
                          onTap: () {
                            if (quantity > 1) {
                              setState(() {
                                quantity--;
                              });
                            }
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.red, width: 2),
                            ),
                            child: const Icon(Icons.remove, color: Colors.red),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Quantity Display
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                          child: Center(
                            child: Text(
                              quantity.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Increase Button
                        InkWell(
                          onTap: () {
                            setState(() {
                              quantity++;
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.red, width: 2),
                            ),
                            child: const Icon(Icons.add, color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      // Change function based on whether we're editing or adding
                      onPressed: widget.isEditingCart
                          ? (_isProcessing ? null : _updateCartItem)
                          : (_isAddingToCart ? null : _addToCart),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                          widget.isEditingCart
                              ? (_isProcessing
                                  ? "Đang cập nhật..."
                                  : "Cập nhật món")
                              : (_isAddingToCart
                                  ? "Đang thêm món..."
                                  : "Thêm vào giỏ"),
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
