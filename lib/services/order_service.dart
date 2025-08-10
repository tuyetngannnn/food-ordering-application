import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_firebase/models/product.dart';
import 'package:demo_firebase/services/product_service.dart';
import 'package:demo_firebase/services/zalopayment.dart';
import 'package:demo_firebase/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:demo_firebase/services/cart_service.dart';
import 'package:demo_firebase/models/cart.dart';
import 'package:demo_firebase/models/cart_item.dart';
import 'package:flutter/material.dart';

import 'package:demo_firebase/models/order.dart';

import '../models/address.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CartService _cartService;

  // Reference to the orders collection
  CollectionReference get _ordersRef => _firestore.collection('orders');

  // Current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Constructor that takes a CartService instance
  OrderService(this._cartService);

  // Save an order from the current cart
  Future<String> saveOrderFromCart({
    required double totalPrice,
    required String paymentMethod,
    String pickUpAddress = "",
    String deliveryAddress = "",
    double deliveryFee = 0,
    dynamic coupon = null,
    int rewardedPoint = 0,
    String note = "",
  }) async {
    try {
      // Verify user is logged in
      if (currentUserId == null) {
        throw Exception('User not logged in');
      }

      // Get current cart
      Cart cart = await _cartService.getOrCreateCart();

      // Verify cart has items
      if (cart.cartItem.isEmpty) {
        throw Exception('Cart is empty');
      }

      // Create Order object from Cart data
      final order = {
        'userId': cart.userId,
        'pickUpAddress': pickUpAddress,
        'deliveryAddress': deliveryAddress,
        'listCartItem': cart.cartItem.map((item) => item.toJson()).toList(),
        'deliveryFee': deliveryFee,
        'coupon': coupon,
        'rewardedPoint': rewardedPoint,
        'paymentMethod': paymentMethod,
        'totalPrice': totalPrice,
        'note': note,
        'status': "processing",
        'ratedBar': 0,
        'feedback': "",
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      };

      // Save order to Firestore
      DocumentReference orderRef = await _ordersRef.add(order);

      print("Order saved with ID: ${orderRef.id}");
      return orderRef.id;
    } catch (e) {
      print("Error saving order: $e");
      throw Exception("Failed to save order: $e");
    }
  }

  /////////////////////////////////// Khai /////////////////////////////////////
  Future<String> processPaymentAndCreateOrder(
      String paymentMethod,
      BuildContext context,
      String? orderCouponId,
      String? shippingCouponId,
      String pickUpAddressId,
      String? deliveryAddressName,
      double? deliveryAddressLatitude,
      double? deliveryAddressLongitude,
      List<CartItem> listCartItem,
      double deliveryFee,
      double? orderDiscount,
      double? deliveryDiscount,
      bool rewardDiscount,
      double rewardedPoint,
      double totalPrice,
      String? note,
      int ratedBar,
      String? feedback,
      String nameCustomer,
      String phoneCustomer) async {
    bool isPaymentSuccess = false;
    if (paymentMethod == "Zalo Pay") {
      isPaymentSuccess = await ZaloPayment.processPayment(context, totalPrice);
    } else if (paymentMethod == "cash") {
      isPaymentSuccess = true;
    }

    if (isPaymentSuccess) {
      DocumentReference docRef =
          FirebaseFirestore.instance.collection('orders').doc();
      String orderId = docRef.id;

      final createdAt = DateTime.now();
      final updatedAt = DateTime.now();

      final orderProduct = OrderProduct(
          orderId,
          currentUserId ?? '',
          orderCouponId,
          shippingCouponId,
          pickUpAddressId,
          deliveryAddressName,
          deliveryAddressLatitude,
          deliveryAddressLongitude,
          listCartItem,
          deliveryFee,
          orderDiscount,
          deliveryDiscount,
          rewardDiscount,
          rewardedPoint,
          paymentMethod,
          totalPrice,
          note,
          'pending',
          ratedBar,
          feedback,
          createdAt,
          updatedAt,
          nameCustomer,
          phoneCustomer);

      await docRef.set(orderProduct.toJson());

      // 🔹 Remove used coupons from user's collection
      if (currentUserId != null && currentUserId!.isNotEmpty) {
        DocumentReference userRef =
            FirebaseFirestore.instance.collection('users').doc(currentUserId);

        // Use Firestore transaction to ensure data consistency
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          DocumentSnapshot userSnapshot = await transaction.get(userRef);

          if (userSnapshot.exists) {
            List<dynamic> userCoupons = userSnapshot.get('couponId') ?? [];

            // Create a copy of the list and remove the used coupons
            List<dynamic> updatedCoupons = List.from(userCoupons);

            if (orderCouponId != null && orderCouponId.isNotEmpty) {
              updatedCoupons.remove(orderCouponId);
            }
            if (shippingCouponId != null && shippingCouponId.isNotEmpty) {
              updatedCoupons.remove(shippingCouponId);
            }

            // If the coupon list is empty, remove the field; otherwise, update the list
            if (updatedCoupons.isEmpty) {
              transaction.update(userRef, {'couponId': FieldValue.delete()});
            } else {
              transaction.update(userRef, {'couponId': updatedCoupons});
            }
          }
        });
      }

      // Clear cart after successful order
      await _cartService.clearCart();

      return orderId;
    } else {
      throw Exception("Payment failed");
    }
  }

  /////////////////////////////////// Khai /////////////////////////////////////
  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Giao thành công';
      case 'cancelled':
        return 'Đơn hàng hủy';
      case 'preparing':
        return 'Đang chuẩn bị';
      case 'delivering':
        return 'Đang giao';
      case 'pending':
        return 'Chờ xác nhận';
      default:
        return 'Lỗi';
    }
  }

  // Get orders for current user
  Future<List<Map<String, dynamic>>> getUserOrders() async {
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    try {
      QuerySnapshot querySnapshot = await _ordersRef
          .where('userId', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => {
                'orderId': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      print('Error getting user orders: $e');
      throw Exception('Failed to get orders: $e');
    }
  }

  // Get specific order by ID
  Future<Map<String, dynamic>> getOrderById(String orderId) async {
    try {
      DocumentSnapshot orderDoc = await _ordersRef.doc(orderId).get();

      if (!orderDoc.exists) {
        throw Exception('Order not found');
      }

      return {
        'orderId': orderDoc.id,
        ...orderDoc.data() as Map<String, dynamic>,
      };
    } catch (e) {
      print('Error getting order details: $e');
      throw Exception('Failed to get order details: $e');
    }
  }

  Future<String> getAddressNameById(String? addressId) async {
    if (addressId == null || addressId.isEmpty) {
      return 'Chưa có thông tin';
    }

    try {
      DocumentSnapshot addressDoc = await FirebaseFirestore.instance
          .collection('addresses')
          .doc(addressId)
          .get();

      if (addressDoc.exists) {
        return addressDoc['addressName'] ?? 'Địa chỉ không xác định';
      } else {
        return 'Địa chỉ không xác định';
      }
    } catch (e) {
      print('Lỗi lấy địa chỉ: $e');
      return 'Lỗi khi lấy địa chỉ';
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _ordersRef.doc(orderId).update({
        'status': status,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error updating order status: $e');
      throw Exception('Failed to update order status: $e');
    }
  }

// Format order data for display
  Future<Map<String, dynamic>> formatOrderForDisplay(
      Map<String, dynamic> order) async {
    // Format date from Timestamp
    String formattedDate = '';
    if (order['createdAt'] != null) {
      final DateTime dateTime = (order['createdAt'] as Timestamp).toDate();
      formattedDate =
          '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}, ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
    String addressName = '';

    if (order['pickUpAddressId'] != null &&
        order['pickUpAddressId'].isNotEmpty) {
      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('addresses')
            .where('addressId', isEqualTo: order['pickUpAddressId'])
            .limit(1)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          addressName = querySnapshot.docs.first['addressName'] ??
              'Địa chỉ không xác định';
        }
      } catch (e) {
        print('Lỗi lấy địa chỉ: $e');
      }
    }
    // Lấy danh sách sản phẩm trong đơn hàng
    List<dynamic> cartItems = order['listCartItem'] ?? [];
    // Đếm tổng số lượng sản phẩm
    num totalQuantity =
        cartItems.fold(0, (sum, item) => sum + (item['quantity'] ?? 0));
    // Tính tổng tiền đơn hàng
    double totalPrice =
        cartItems.fold(0.0, (sum, item) => sum + (item['totalPrice'] ?? 0.0));

    return {
      'date': formattedDate,
      'name': addressName,
      'quantity': '$totalQuantity phần',
      'price': Utils().formatCurrency(totalPrice),
      'status': _getStatusText(order['status'] ?? ''),
      'orderId': order['orderId'],
      'ratedBar': order['ratedBar'] ?? 0
    };
  }

  // Add rating and feedback to order
  Future<void> addOrderRatingAndFeedback(
      String orderId, double rating, String feedback) async {
    try {
      await _ordersRef.doc(orderId).update({
        'ratedBar': rating,
        'feedback': feedback,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error adding rating and feedback: $e');
      throw Exception('Failed to add rating and feedback: $e');
    }
  }

  // New method to fetch complete order details with additional processing
  Future<Map<String, dynamic>> getFullOrderDetails(String orderId) async {
    try {
      // Get basic order details
      final orderDetails = await getOrderById(orderId);

      // Fetch pickup address if pickUpAddressId exists
      if (orderDetails['pickUpAddressId'] != null &&
          orderDetails['pickUpAddressId'].isNotEmpty) {
        try {
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection('addresses')
              .where('addressId', isEqualTo: orderDetails['pickUpAddressId'])
              .limit(1)
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            orderDetails['pickUpAddress'] =
                querySnapshot.docs.first['addressName'] ??
                    'Địa chỉ không xác định';
          } else {
            orderDetails['pickUpAddress'] = 'Địa chỉ không tìm thấy';
          }
        } catch (e) {
          orderDetails['pickUpAddress'] = 'Địa chỉ không xác định';
          print('Lỗi lấy địa chỉ: $e');
        }
      } else {
        orderDetails['pickUpAddress'] = '';
      }

      return orderDetails;
    } catch (e) {
      print('Error fetching full order details: $e');
      rethrow;
    }
  }

  // New method to process order items with product details
  Future<List<Map<String, dynamic>>> processOrderItems(
      List<dynamic> cartItems) async {
    final ProductService _productService = ProductService();
    List<Map<String, dynamic>> simplifiedOrderItems = [];

    for (var item in cartItems) {
      String productId = item['productId'].toString();

      // Get product details from service
      final product = await _productService.getProductByProductId(productId);

      if (product != null) {
        // Get the size information if available
        String sizeId = item['sizeId'] ?? '';
        String sizeName = 'Standard';

        // Find the matching size if it exists
        if (product.sizes != null && product.sizes.isNotEmpty) {
          final size = product.sizes.firstWhere(
            (s) => s.sizeId == sizeId,
            orElse: () =>
                ProductSize(sizeId: '', sizeName: 'Standard', extraPrice: 0),
          );
          sizeName = size.sizeName;
        }

        simplifiedOrderItems.add({
          'productName': product.productName ?? 'Sản phẩm',
          'productImg': product.productImg,
          'sizeName': sizeName,
          'price': item['unitPrice'] ?? product.productPrice ?? 0,
          'quantity': item['quantity'] ?? 1,
        });
      }
    }

    return simplifiedOrderItems;
  }
}
