import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/utils.dart';
import '../models/cart.dart';
import '../models/cart_item.dart';
import '../services/product_service.dart';
import '../models/product.dart';

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final Product product;

  const CartItemCard({
    super.key,
    required this.item,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final size = product.sizes.firstWhere(
      (size) => size.sizeId == item.sizeId,
      orElse: () =>
          ProductSize(sizeId: '', sizeName: 'Standard', extraPrice: 0),
    );

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Quantity indicator
          SizedBox(
            width: 36,
            height: 36,
            child: Center(
              child: Text(
                "${item.quantity}x",
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF655E5E),
                ),
              ),
            ),
          ),
          const SizedBox(width: 5),

          // Product image
          Container(
            width: 100,
            height: 70,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(product.productImg),
                fit: BoxFit.fitWidth,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 16),

          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  size.sizeName,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(
                    height: 4), // Thêm khoảng cách giữa sizeName và giá
                Text(
                  Utils().formatCurrency(item.unitPrice * item.quantity),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFD0000),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Quantity indicator
          SizedBox(
            width: 36,
            height: 36,
            child: Center(
              child: Text(
                "${item.quantity}x",
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF655E5E),
                ),
              ),
            ),
          ),
          const SizedBox(width: 5),

          // Product image
          Container(
            width: 100,
            height: 70,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/chicken_bucket_1.png'),
                fit: BoxFit.fitWidth,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 16),

          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đang tải',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Đang tải',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(
                    height: 4), // Thêm khoảng cách giữa sizeName và giá
                Text(
                  Utils().formatCurrency(item.unitPrice * item.quantity),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFD0000),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
