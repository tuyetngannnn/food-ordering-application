import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:demo_firebase/models/cart.dart';
import 'package:demo_firebase/models/cart_item.dart';
import 'package:demo_firebase/models/product.dart';
import 'package:demo_firebase/providers/cart_provider.dart';
import 'package:demo_firebase/screens/cart/empty_cart_screen.dart';
import 'package:demo_firebase/screens/menu_screen.dart';
import 'package:demo_firebase/screens/order_screen.dart';
import 'package:demo_firebase/screens/product_detail_screen.dart';
import 'package:demo_firebase/widgets/custom_app_bar.dart';
import 'package:demo_firebase/widgets/custom_loading.dart';
import '../../utils/utils.dart';
import '../main_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Refresh cart data when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartProvider>(context, listen: false).refreshCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive layout
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 360;
    final bool isMediumScreen = screenWidth >= 360 && screenWidth < 600;
    final double imageSize = isSmallScreen ? 80 : 100;

    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        // Show loading indicator while data is being fetched
        if (cartProvider.isLoading) {
          return CustomLoading();
        }

        // Show error message if there's an error
        if (cartProvider.error != null) {
          return Scaffold(
            appBar: customAppBar(context, 'Giỏ hàng', showCart: false),
            body: Center(
              child: Text('Lỗi: ${cartProvider.error}'),
            ),
          );
        }
        // Show empty cart screen if cart is empty
        if (cartProvider.isEmpty) {
          return const EmptyCartScreen();
        }
        // Get cart items and products
        final cartItems = cartProvider.cartItems;

        return Scaffold(
          appBar: customAppBar(context, 'Giỏ hàng', showCart: false),
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final cartItem = cartItems[index];
                      final product = cartProvider
                          .getProductForCartItem(cartItem.productId);

                      if (product == null) {
                        return const SizedBox.shrink();
                      }

                      final productName = product.productName;
                      final productImg = product.productImg.isNotEmpty
                          ? product.productImg
                          : '';
                      final selectedSize =
                          cartProvider.getSizeForCartItem(cartItem);
                      final sizeName = selectedSize?.sizeName ?? '';

                      return Dismissible(
                        key: Key(cartItem.cartItemId),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) async {
                          await cartProvider.removeFromCart(
                              cartItem.cartItemId, context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 8 : 12,
                            horizontal: isSmallScreen ? 8 : 16,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  productImg,
                                  width: imageSize,
                                  height: imageSize,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, error, _) => Container(
                                    width: imageSize,
                                    height: imageSize,
                                    color: Colors.grey[300],
                                    child:
                                        const Icon(Icons.image_not_supported),
                                  ),
                                ),
                              ),
                              SizedBox(width: isSmallScreen ? 8 : 16),

                              // Product details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Product name and edit icon in same row
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            productName,
                                            style: TextStyle(
                                              fontSize: isSmallScreen ? 14 : 16,
                                              fontWeight: FontWeight.bold,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            maxLines: 2,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Color(0xFFFFC115),
                                            size: 22,
                                          ),
                                          onPressed: () {
                                            // Navigate to the product detail page in edit mode
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ProductDetailScreen(
                                                  product: product,
                                                  color: Colors.red,
                                                  isEditingCart: true,
                                                  cartItemId:
                                                      cartItem.cartItemId,
                                                  initialSizeId:
                                                      cartItem.sizeId,
                                                  initialQuantity:
                                                      cartItem.quantity,
                                                ),
                                              ),
                                            );
                                          },
                                          constraints: BoxConstraints.tight(
                                              const Size(24, 24)),
                                          padding: EdgeInsets.zero,
                                        ),
                                      ],
                                    ),
                                    Text(
                                      sizeName,
                                      style: TextStyle(
                                        color: const Color(0xFF655E5E),
                                        fontSize: isSmallScreen ? 10 : 12,
                                      ),
                                    ),
                                    SizedBox(height: isSmallScreen ? 4 : 8),
                                    // Price and quantity controls in same row
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            Utils().formatCurrency(
                                                cartItem.unitPrice.toDouble()),
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                              fontSize: isSmallScreen ? 14 : 16,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        // Quantity controls
                                        Row(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                if (cartItem.quantity > 1) {
                                                  cartProvider.updateQuantity(
                                                    cartItem.cartItemId,
                                                    cartItem.quantity - 1,
                                                  );
                                                } else {
                                                  cartProvider
                                                      .showRemoveItemDialog(
                                                    context,
                                                    cartItem.cartItemId,
                                                  );
                                                }
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(
                                                    isSmallScreen ? 1 : 2),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      color: Colors.red),
                                                ),
                                                child: Icon(
                                                  Icons.remove,
                                                  size: isSmallScreen ? 14 : 16,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.symmetric(
                                                horizontal:
                                                    isSmallScreen ? 4 : 8,
                                              ),
                                              width: isSmallScreen ? 20 : 24,
                                              height: isSmallScreen ? 20 : 24,
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '${cartItem.quantity}',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        isSmallScreen ? 12 : 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                cartProvider.updateQuantity(
                                                  cartItem.cartItemId,
                                                  cartItem.quantity + 1,
                                                );
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(
                                                    isSmallScreen ? 1 : 2),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      color: Colors.red),
                                                ),
                                                child: Icon(
                                                  Icons.add,
                                                  size: isSmallScreen ? 14 : 16,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Bottom summary and checkout section
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: isSmallScreen ? 4 : 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TỔNG TIỀN',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF655E5E),
                            ),
                          ),
                          Text(
                            Utils().formatCurrency(cartProvider.cartTotal),
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 18,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      // Two buttons row
                      LayoutBuilder(
                        builder: (context, constraints) {
                          // Use vertical arrangement for very small screens
                          if (constraints.maxWidth < 280) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildAddItemsButton(context),
                                const SizedBox(height: 8),
                                _buildCheckoutButton(context, cartProvider),
                              ],
                            );
                          } else {
                            // Use horizontal arrangement for larger screens
                            return Row(
                              children: [
                                // Add Items Button
                                Expanded(child: _buildAddItemsButton(context)),
                                SizedBox(width: isSmallScreen ? 8 : 12),
                                // Checkout Button
                                Expanded(
                                    child: _buildCheckoutButton(
                                        context, cartProvider)),
                              ],
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Extract button widgets for reusability
  Widget _buildAddItemsButton(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 360;

    return OutlinedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MainScreen(initialIndex: 2),
          ),
        );
      },
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.red),
        padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Text(
        'Thêm món',
        style: TextStyle(
          fontSize: isSmallScreen ? 14 : 16,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      ),
    );
  }

  Widget _buildCheckoutButton(BuildContext context, CartProvider cartProvider) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 360;

    return ElevatedButton(
      onPressed: _isProcessing
          ? null
          : () async {
              setState(() {
                _isProcessing = true;
              });

              try {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderScreen(
                      cartItems: cartProvider.cartItems,
                      products: cartProvider.products,
                      subTotal: cartProvider.cartTotal,
                    ),
                  ),
                );
              } finally {
                if (mounted) {
                  setState(() {
                    _isProcessing = false;
                  });
                }
              }
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Text(
        _isProcessing ? 'Đang xử lý...' : 'Đặt món',
        style: TextStyle(
          fontSize: isSmallScreen ? 14 : 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
