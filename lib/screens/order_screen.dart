import 'package:demo_firebase/screens/discount_screen.dart';
import 'package:demo_firebase/screens/order/home_delivery_screen.dart';
import 'package:demo_firebase/services/auth_service.dart';
import 'package:demo_firebase/utils/utils.dart';
import 'package:demo_firebase/models/cart_item.dart';
import 'package:demo_firebase/services/cart_service.dart';
import 'package:demo_firebase/widgets/order_product_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import '../models/cart.dart';
import '../models/coupon.dart';
import '../models/product.dart';
import '../services/discount_service.dart';
import '../services/map_service.dart';
import '../services/order_service.dart';
import '../services/share_pref_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/delivery_address_widget.dart';
import 'main_screen.dart';

class OrderScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final List<Product> products;
  final double subTotal;

  const OrderScreen(
      {super.key,
      required this.cartItems,
      required this.products,
      required this.subTotal});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final CartService _cartService = CartService();
  final _noteController = TextEditingController();
  double distance = 0;
  double subTotal = 0;
  double deliveryFee = 0;
  double subTotalDiscount = 0;
  double deliveryFeeDiscount = 0;
  bool rewardDiscount = false;
  int paymentMethod = 0;
  // double totalPrice = 0;

  bool isDelivery = true;

  String pickUpAddressId = '1';
  String? deliveryAddressName;
  double? deliveryAddressLatitude;
  double? deliveryAddressLongitude;

  Coupon? selectedOrderCoupon;
  Coupon? selectedShippingCoupon;

  String _selectedPaymentMethod = "cash";
  late OrderService _orderService;

  // Add subscription to listen for distance changes
  StreamSubscription? _prefSubscription;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  // Method to load user info
  Future<Map<String, dynamic>?> _loadUserInfo() async {
    final AuthService authService = AuthService();
    User? currentUser = authService.getCurrentUser();

    if (currentUser != null) {
      return await authService.fetchUserInfo(currentUser.uid);
    }

    return null;
  }

  void updateDistance(double dis) {
    setState(() {
      distance = dis;
      deliveryFee = Utils().calculateDeliveryFee(distance);
    });

    _updateDiscount();
  }

  void _updateAddresses(
      String pickup, String? name, double? latitude, double? longitude) {
    setState(() {
      pickUpAddressId = pickup;
      deliveryAddressName = name;
      deliveryAddressLatitude = latitude;
      deliveryAddressLongitude = longitude;
    });
  }

  // Method to update the selected payment method
  void _updatePaymentMethod(String methodId) {
    setState(() {
      _selectedPaymentMethod = methodId;
    });
  }

  void _updateDiscount() {
    setState(() {
      if (selectedOrderCoupon != null) {
        subTotalDiscount = DiscountService().getDiscountPrice(
          subTotal,
          deliveryFee,
          selectedOrderCoupon!.type,
          selectedOrderCoupon!.isPercentage,
          selectedOrderCoupon!.discountValue,
          selectedOrderCoupon!.maxDiscountValue,
        );
      }

      // Apply shipping coupon discount only if delivery is enabled
      if (selectedShippingCoupon != null && isDelivery) {
        deliveryFeeDiscount = DiscountService().getDiscountPrice(
          subTotal,
          deliveryFee,
          selectedShippingCoupon!.type,
          selectedShippingCoupon!.isPercentage,
          selectedShippingCoupon!.discountValue,
          selectedShippingCoupon!.maxDiscountValue,
        );
      } else {
        deliveryFeeDiscount = 0;
      }
    });
  }

  void _updateDeliveryStatus(bool status) {
    setState(() {
      isDelivery = status;
      // If delivery is turned off, set delivery fee to 0
      if (!isDelivery) {
        deliveryFee = 0;
        deliveryFeeDiscount = 0; // Also reset any delivery discounts
      } else {
        // Restore delivery fee calculation based on distance
        deliveryFee = Utils().calculateDeliveryFee(distance);
      }
    });
    _updateDiscount(); // Recalculate discounts after changing delivery status
  }

  @override
  void initState() {
    super.initState();

    // Listen for changes to the distance in SharedPreferences
    _prefSubscription = SharePrefService.preferencesStream.listen((data) {
      if (data.containsKey('distance') && mounted) {
        double newDistance = data['distance'];
        setState(() {
          distance = newDistance;
          deliveryFee = Utils().calculateDeliveryFee(newDistance);
        });
      }
    });

    initial();
  }

  @override
  void dispose() {
    // Cancel the subscription when the widget is disposed
    _prefSubscription?.cancel();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> initial() async {
    _orderService = OrderService(_cartService);
    subTotal = widget.subTotal;

    getInitialAddress();

    // Get initial distance from SharedPreferences
    double initialDistance = await SharePrefService.getSelectedDistance() ?? 0;

    if (mounted) {
      setState(() {
        distance = initialDistance;
        deliveryFee = Utils().calculateDeliveryFee(initialDistance);
      });
    }
  }

  Future<void> getInitialAddress() async {
    final initialAddress = await SharePrefService.getSelectedPickupAddress();
    final initialDeliveryAddressName =
        await SharePrefService.getSelectedAddress();
    final initialDeliveryAddressLocation =
        await SharePrefService.getSelectedLocation();

    setState(() {
      pickUpAddressId = initialAddress?.addressId ?? '';
      deliveryAddressName = initialDeliveryAddressName;
      deliveryAddressLatitude = initialDeliveryAddressLocation?.latitude;
      deliveryAddressLongitude = initialDeliveryAddressLocation?.longitude;
    });
  }

  double getTotalPrice() {
    double discount = rewardDiscount ? -1000 : 0;
    return subTotal +
        (isDelivery ? deliveryFee : 0) -
        subTotalDiscount -
        (isDelivery ? deliveryFeeDiscount : 0) -
        discount;
  }

  void openDiscountScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiscountScreen(
          subtotal: subTotal,
          deliveryFee: deliveryFee,
          isDelivery: isDelivery,
          initialOrderCoupon: selectedOrderCoupon,
          initialShippingCoupon: selectedShippingCoupon,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        selectedOrderCoupon = result['orderCoupon'];
        selectedShippingCoupon = result['shippingCoupon'];
      });

      _updateDiscount();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: customAppBar(context, 'Thông tin đặt hàng'),
      body: Column(
        children: [
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DeliveryAddressWidget(
                      onDistanceSelected: updateDistance,
                      onDeliveryStatusChanged: _updateDeliveryStatus,
                      onAddressesUpdated: _updateAddresses,
                    ),
                    _buildInfo(),
                    _buildOrderItemsSection(widget.cartItems),
                    _buildOrderNoteSection(),
                    _buildPaymentInfoSection(),
                    _buildPaymentMethodsSection(),
                  ],
                ),
              ),
            ),
          ),

          // Fixed bottom section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: Offset(0, -2), // Shadow above the bar
                ),
              ],
            ),
            child: _buildBottomOrderSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsSection(List<CartItem> cartItems) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Món ăn đã chọn",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MainScreen(initialIndex: 2)));
                },
                child: const Text(
                  "Thêm món",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: cartItems.length,
          itemBuilder: (context, index) {
            final item = cartItems[index];
            final product = widget.products
                .firstWhere((product) => product.productId == item.productId);
            return CartItemCard(
              item: item,
              product: product,
            );
          },
          separatorBuilder: (context, index) => Divider(
            color: Color(0xFFFFBFBF),
            thickness: 1,
            indent: 10,
            endIndent: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin nhận hàng',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          FutureBuilder<Map<String, dynamic>?>(
            future: _loadUserInfo(),
            builder: (context, snapshot) {
              // Set default values
              String defaultName = 'Họ và tên';
              String defaultPhone = 'Số điện thoại';

              // Update controllers if data is available
              if (snapshot.hasData && snapshot.data != null) {
                defaultName = snapshot.data?['name'] ?? defaultName;
                defaultPhone = snapshot.data?['phone'] ?? defaultPhone;
                String formatNumber = Utils().formatPhoneNumber(defaultPhone);
                // Set the controllers with the retrieved or default values
                _nameController.text = defaultName;
                _phoneController.text = formatNumber;
              }

              return Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: defaultName,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    onChanged: (_) => {},
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: defaultPhone,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    onChanged: (_) => {},
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderNoteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          "Ghi chú đơn hàng",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText:
                  "Ghi chú đặc biệt cho đơn hàng (VD: Thời gian giao hàng mong muốn, thêm sốt,...)",
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
              contentPadding: const EdgeInsets.all(16),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentInfoSection() {
    return StreamBuilder<Cart?>(
      stream: _cartService.getCartStream(),
      builder: (context, snapshot) {
        // Calculate subtotal from cart items
        double calculatedSubtotal = 0;
        if (snapshot.hasData) {
          for (var item in snapshot.data!.cartItem) {
            calculatedSubtotal += item.totalPrice;
          }

          // Update the state's subtotal variable
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && subTotal != calculatedSubtotal) {
              setState(() {
                subTotal = calculatedSubtotal;
              });
            }
          });
        }

        // Format the subtotal using your Utils class
        String formattedSubtotal = Utils().formatCurrency(calculatedSubtotal);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const Text(
              "Thông tin thanh toán",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Tạm tính",
                  style: TextStyle(fontSize: 15),
                ),
                Text(
                  formattedSubtotal,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (isDelivery)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Phí vận chuyển (${MapService.formatDistance(distance)})",
                    style: TextStyle(fontSize: 15),
                  ),
                  Text(
                    Utils().formatCurrency(deliveryFee),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                openDiscountScreen();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Chọn mã ưu đãi",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey[500],
                    size: 30,
                  ),
                ],
              ),
            ),
            if (selectedOrderCoupon != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      selectedOrderCoupon!.couponName,
                      style: TextStyle(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    Utils().formatCurrency(subTotalDiscount),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            if (selectedShippingCoupon != null && isDelivery)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      selectedShippingCoupon!.couponName,
                      style: TextStyle(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    Utils().formatCurrency(deliveryFeeDiscount),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _buildPaymentMethodsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Phí bảo vệ môi trường",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            CupertinoSwitch(
              value: rewardDiscount,
              onChanged: (value) {
                setState(() {
                  rewardDiscount = value;
                });
              },
              activeTrackColor: Color(0xFFFD0000),
            ),
          ],
        ),
        const Text(
          "Mỗi 1.000đ của bạn giúp môi trường tốt hơn",
          style: TextStyle(fontSize: 13, color: Color(0xFF797979)),
        ),
        const SizedBox(height: 16),

        const Text(
          "Phương thức thanh toán",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Payment method 1 - Cash
        _buildPaymentMethodItem(
          image: Image.asset(
            'assets/cash.png',
            width: 15,
            height: 15,
            fit: BoxFit.fitWidth,
          ),
          name: "Thanh toán tiền mặt",
          isSelected: _selectedPaymentMethod == "cash",
          paymentMethodId: "cash",
        ),

        // Payment method 2 - ZaloPay
        _buildPaymentMethodItem(
          image: Image.asset(
            'assets/zalo.png',
            width: 15,
            height: 15,
            fit: BoxFit.fitWidth,
          ),
          name: "Zalopay",
          isSelected: _selectedPaymentMethod == "Zalo Pay",
          paymentMethodId: "Zalo Pay",
        ),
      ],
    );
  }

  Widget _buildPaymentMethodItem({
    IconData? icon,
    Widget? image,
    Color? color,
    required String name,
    required bool isSelected,
    required String paymentMethodId,
  }) {
    return InkWell(
      onTap: () => _updatePaymentMethod(paymentMethodId),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: image ??
                  Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Add a radio button or checkmark to show selection
            isSelected
                ? Icon(Icons.radio_button_checked, color: Colors.red)
                : Icon(Icons.radio_button_unchecked, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomOrderSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Tổng thanh toán:",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              Utils().formatCurrency(getTotalPrice()),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFD0000),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () async {
              try {
                // Process payment and create order
                // String orderId =
                //     await _orderService.processPaymentAndCreateOrder(
                //   totalPrice: getTotalPrice(),
                //   paymentMethod: _selectedPaymentMethod,
                //   context: context,
                //   pickUpAddress: "828 Sư Vạn Hạnh",
                // );
                if (_nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Vui lòng nhập họ và tên"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (_phoneController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Vui lòng nhập số điện thoại"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                String orderId =
                    await _orderService.processPaymentAndCreateOrder(
                        _selectedPaymentMethod,
                        context,
                        selectedOrderCoupon?.couponId,
                        selectedShippingCoupon?.couponId,
                        pickUpAddressId,
                        isDelivery ? deliveryAddressName : null,
                        isDelivery ? deliveryAddressLatitude : null,
                        isDelivery ? deliveryAddressLongitude : null,
                        widget.cartItems,
                        deliveryFee,
                        subTotalDiscount,
                        deliveryFeeDiscount,
                        rewardDiscount,
                        getTotalPrice() * 0.001,
                        getTotalPrice(),
                        _noteController.text,
                        0,
                        null,
                        _nameController.text.trim(),
                        _phoneController.text.trim());

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text("Thanh toán $_selectedPaymentMethod thành công!"),
                    backgroundColor: Colors.green,
                  ),
                );
                // Navigate to confirmation page
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            HomeDeliveryScreen(orderId: orderId)));
              } catch (e) {
                print(e);
                // Handle error
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Đã xảy ra lỗi: ${e.toString()}"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFD0000),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Đặt món",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
