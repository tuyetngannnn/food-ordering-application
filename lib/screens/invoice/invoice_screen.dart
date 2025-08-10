import 'package:demo_firebase/screens/home_screen.dart';
import 'package:demo_firebase/screens/invoice/custom.dart';
import 'package:demo_firebase/screens/main_screen.dart';
import 'package:demo_firebase/services/product_service.dart';
import 'package:demo_firebase/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:demo_firebase/services/order_service.dart';
import 'package:demo_firebase/services/cart_service.dart';
import 'package:demo_firebase/utils/utils.dart'; // Import Utils class

class InvoiceScreen extends StatefulWidget {
  final String orderId;

  const InvoiceScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  late OrderService _orderService;
  final ProductService _productService = ProductService();
  final Utils _utils = Utils(); // Create an instance of Utils
  bool isLoading = true;
  Map<String, dynamic>? orderData;
  List<dynamic> orderItems = [];
  num totalPrice = 0;

  @override
  void initState() {
    super.initState();
    // Properly initialize the OrderService with CartService
    final cartService = CartService();
    _orderService = OrderService(cartService);
    fetchOrderDetails();
  }

  Future<void> fetchOrderDetails() async {
    try {
      // Use the OrderService to get order details
      final orderDetails = await _orderService.getOrderById(widget.orderId);
      List<dynamic> cartItems = orderDetails['listCartItem'] ?? [];
      List<Map<String, dynamic>> fullOrderItems = [];
      // Kiểm tra địa chỉ giao hàng
      String addressName = orderDetails['deliveryAddressName'] ?? '';
      if (addressName.isEmpty) {
        addressName = await _orderService
            .getAddressNameById(orderDetails['pickUpAddressId']);
      }
      for (var item in cartItems) {
        String productId = item['productId'].toString();

        final product = await _productService.getProductByProductId(productId);

        if (product != null) {
          fullOrderItems.add({
            'productId': productId,
            'productName': product.productName ?? 'Sản phẩm',
            'description': product.productDescription ?? 'Không có mô tả',
            'price': item['totalPrice'] ?? 0,
            'imagePath': product.productImg,
            'quantity': item['quantity'] ?? 1,
          });
        }
      }
      setState(() {
        orderData = orderDetails;
        orderItems = fullOrderItems;
        orderData!['deliveryAddressName'] = addressName;
        totalPrice = orderDetails['totalPrice'];
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching order details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double containerWidth = MediaQuery.of(context).size.width;

    if (isLoading) {
      return Scaffold(
        appBar: customAppBar(context, 'Chi tiết hóa đơn',
            showBack: false, showCart: false),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: customAppBar(context, 'Chi tiết hóa đơn',
          showBack: false, showCart: false),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            width: double.infinity,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'CẢM ƠN BẠN ĐÃ ĐẶT HÀNG!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Đơn hàng của bạn đã được xác nhận và sẽ được vận chuyển ngay lập tức.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mã đơn hàng: ${orderData?['orderId'] ?? widget.orderId}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Order Items Container
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 18),
                    padding: const EdgeInsets.all(8),
                    width: containerWidth,
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                    child: orderItems.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                'Không có sản phẩm nào trong đơn hàng',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: orderItems.length,
                            itemBuilder: (context, index) {
                              final item = orderItems[index];
                              return OrderItemWidget(
                                title: item['productName'] ?? 'Sản phẩm',
                                description:
                                    item['description'] ?? 'Mô tả sản phẩm',
                                price:
                                    _utils.formatCurrency(item['price'] ?? 0),
                                imagePath: item['imagePath'] ??
                                    'assets/default_food.png',
                                quantity: item['quantity'] ?? 1,
                              );
                            },
                          ),
                  ),

                  const SizedBox(height: 16),

                  // First OrderDetailsWidget with dashed border for recipient info
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 18),
                    width: containerWidth,
                    child: OrderDetailsWidget(
                      useDashedBorder: true,
                      dashedBorderColor: Colors.red,
                      backgroundColor: Color(0xFFFFE0E0),
                      orderId: orderData?['orderId'] ?? widget.orderId,
                      recipientName:
                          orderData?['nameCustomer'] ?? 'Chưa có thông tin',
                      phoneNumber:
                          orderData?['phoneCustomer'] ?? 'Chưa có thông tin',
                      address: orderData?['deliveryAddressName'] ??
                          'Chưa có thông tin',
                      // deliveryFee:
                      //     Utils().formatCurrency(orderData?['deliveryFee']),
                      // orderDiscount:
                      //     Utils().formatCurrency(orderData?['orderDiscount']),
                      // deliveryDiscount: Utils()
                      //     .formatCurrency(orderData?['deliveryDiscount']),
                      // rewardDiscount: orderData?['rewardDiscount'],
                      // paymentMethod: orderData?['paymentMethod'],
                      // note: orderData?['note'],
                      // status: orderData?['status'],
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Total and Button - fixed at bottom
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tổng tiền',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _utils.formatCurrency(totalPrice),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => MainScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Quay về trang chủ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
