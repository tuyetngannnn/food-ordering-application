import 'package:flutter/material.dart';
import '../utils/utils.dart';

class OrderHistoryDetailCard extends StatelessWidget {
  final String orderId;
  final List<dynamic> items;

  const OrderHistoryDetailCard({
    Key? key,
    required this.orderId,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((item) => _buildOrderItemRow(item)).toList(),
    );
  }

  Widget _buildOrderItemRow(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Quantity indicator
          SizedBox(
            width: 36,
            height: 36,
            child: Center(
              child: Text(
                "${item['quantity']}x",
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF655E5E),
                ),
              ),
            ),
          ),
          const SizedBox(width: 5),

          SizedBox(
            width: 65,
            height: 65,
            child: Center(
              child: Image.network("${item['productImg']}"),
            ),
          ),
          const SizedBox(width: 16),

          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['productName'] ?? 'Sản phẩm',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['sizeName'] ?? 'Standard',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                // Price
                Text(
                  Utils().formatCurrency(
                      (item['price'] ?? 0) * (item['quantity'] ?? 1)),
                  style: const TextStyle(
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
