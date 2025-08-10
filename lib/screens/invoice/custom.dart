import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:math' as math;

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double radius;

  DashedBorderPainter({
    this.color = Colors.red,
    this.strokeWidth = 1.0,
    this.dashWidth = 10.0,
    this.dashSpace = 8.0,
    this.radius = 12.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path();

    // Create a rounded rectangle path
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    ));

    // Convert the path to a dashed path
    final Path dashedPath = dashPath(
      path,
      dashWidth: dashWidth,
      dashSpace: dashSpace,
    );

    // Draw the dashed path
    canvas.drawPath(dashedPath, paint);
  }

  Path dashPath(
    Path originalPath, {
    required double dashWidth,
    required double dashSpace,
  }) {
    final Path dashedPath = Path();
    for (final PathMetric pathMetric in originalPath.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;

      while (distance < pathMetric.length) {
        final double length = draw ? dashWidth : dashSpace;
        if (distance + length > pathMetric.length) {
          break;
        }
        final Path extractPath =
            pathMetric.extractPath(distance, distance + length);
        if (draw) {
          dashedPath.addPath(extractPath, Offset.zero);
        }
        distance += length;
        draw = !draw;
      }
    }
    return dashedPath;
  }

  double getPathLength(Path path) {
    final PathMetrics pathMetrics = path.computeMetrics();
    double totalLength = 0.0;

    for (PathMetric metric in pathMetrics) {
      totalLength += metric.length;
    }

    return totalLength;
  }

  Offset evalPath(Path path, double distance) {
    final PathMetrics pathMetrics = path.computeMetrics();
    Offset result = Offset.zero;

    for (PathMetric metric in pathMetrics) {
      if (distance <= metric.length) {
        final Tangent? tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          result = tangent.position;
        }
        break;
      }
      distance -= metric.length;
    }

    return result;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

// Keep the same OrderItemWidget class
class OrderItemWidget extends StatelessWidget {
  final String title;
  final String description;
  final String price;
  final String imagePath;
  final int quantity;

  const OrderItemWidget({
    Key? key,
    required this.title,
    required this.description,
    required this.price,
    required this.imagePath,
    this.quantity = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SL: $quantity',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
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

// Updated OrderDetailsWidget with combined functionality
class OrderDetailsWidget extends StatelessWidget {
  // final String deliveryFee;
  // final String orderDiscount;
  // final String deliveryDiscount;
  // final bool rewardDiscount;
  // final String paymentMethod;
  // final String note;
  // final String status;

  // Additional fields for recipient information
  final String? orderId;
  final String? recipientName;
  final String? phoneNumber;
  final String? address;

  // Styling options
  final bool useDashedBorder;
  final Color dashedBorderColor;
  final Color backgroundColor;

  const OrderDetailsWidget({
    Key? key,
    // required this.deliveryFee,
    // required this.orderDiscount,
    // required this.deliveryDiscount,
    // required this.rewardDiscount,
    // required this.paymentMethod,
    // required this.note,
    // required this.status,
    this.orderId,
    this.recipientName,
    this.phoneNumber,
    this.address,
    this.useDashedBorder = false,
    this.dashedBorderColor = Colors.red,
    this.backgroundColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget contentWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display recipient information if provided
        if (orderId != null) _buildDetailRow('Mã đơn', orderId!),
        if (recipientName != null)
          _buildDetailRow('Người nhận', recipientName!),
        if (phoneNumber != null) _buildDetailRow('Số điện thoại', phoneNumber!),
        if (address != null)
          _buildDetailRow('Địa chỉ nhận hàng', address!, multiLine: true),

        // Add spacing if any recipient info was shown
        if (orderId != null ||
            recipientName != null ||
            phoneNumber != null ||
            address != null)
          const SizedBox(height: 16),

        // // Payment and delivery details
        // _buildDetailRow('Phí vận chuyển', deliveryFee),
        // _buildDetailRow('Giảm giá đơn hàng', orderDiscount),
        // _buildDetailRow('Giảm giá vận chuyển', deliveryDiscount),
        // _buildDetailRow(
        //     'Giảm giá từ điểm thưởng', rewardDiscount ? '500 đ' : '0 đ'),
        // const Divider(height: 24),
        // _buildDetailRow('Phương thức thanh toán', paymentMethod),
        // if (note.isNotEmpty) _buildDetailRow('Ghi chú', note),
        // _buildDetailRow('Trạng thái đơn hàng', status, isHighlighted: true),
      ],
    );

    if (useDashedBorder) {
      return SizedBox(
        width: double.infinity,
        child: CustomPaint(
          painter: DashedBorderPainter(
            color: dashedBorderColor,
            strokeWidth: 2.0,
            dashWidth: 10.0,
            dashSpace: 8.0,
            radius: 12.0,
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: backgroundColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: contentWidget,
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFB9B9B9),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: contentWidget,
      );
    }
  }

  Widget _buildDetailRow(String label, String value,
      {bool isHighlighted = false, bool multiLine = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment:
            multiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
                color: isHighlighted ? Colors.green : Colors.black,
              ),
              textAlign: TextAlign.right,
              maxLines: multiLine ? 3 : 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
