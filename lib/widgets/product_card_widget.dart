import 'package:demo_firebase/models/product.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/utils.dart';
import '../services/product_service.dart';

class ProductCardWidget extends StatelessWidget {
  final Product product;
  final bool isFavorite;
  final VoidCallback onFavoriteTapped;

  const ProductCardWidget(
      {super.key,
      required this.product,
      required this.isFavorite,
      required this.onFavoriteTapped});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image container
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.15,
            child: Center(
              child: Image.network(
                product.productImg,
                fit: BoxFit.cover,
                width: double.infinity,
                // height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  // Placeholder for when image fails to load
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.image, size: 50, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ),

          // Title and favorite button
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 2, 0),
            height: 50,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title text - constrained to a single line
                Expanded(
                  child: Text(
                    product.productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    overflow:
                        TextOverflow.visible, // Allow text to be fully visible
                    softWrap: true, // Enable text wrapping
                    maxLines: 2, // Limit to 2 lines maximum
                  ),
                ),
                // Heart icon with tight constraints
                SizedBox(
                  width: 30,
                  child: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: onFavoriteTapped,
                  ),
                ),
              ],
            ),
          ),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              product.productDescription,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Price
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Text(
              Utils().formatCurrency(product.productPrice),
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
