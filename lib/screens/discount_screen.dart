import 'package:demo_firebase/utils/utils.dart';
import 'package:demo_firebase/widgets/custom_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/coupon.dart';
import '../services/discount_service.dart';

class DiscountScreen extends StatefulWidget {
  final double? subtotal;
  final double? deliveryFee;
  final bool? isDelivery;
  final Coupon? initialOrderCoupon;
  final Coupon? initialShippingCoupon;

  const DiscountScreen({
    super.key,
    this.subtotal,
    this.deliveryFee,
    this.isDelivery,
    this.initialOrderCoupon,
    this.initialShippingCoupon,
  });

  @override
  State<DiscountScreen> createState() => _DiscountScreenState();
}

class _DiscountScreenState extends State<DiscountScreen>
    with SingleTickerProviderStateMixin {
  final _discountService = DiscountService();
  late TabController _tabController;
  final TextEditingController _couponController = TextEditingController();

  List<Coupon> coupons = [];
  bool isLoading = true;
  bool isSubmitting = false;
  Coupon? selectedOrderCoupon;
  Coupon? selectedShippingCoupon;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    selectedOrderCoupon = widget.initialOrderCoupon;
    // Only set the shipping coupon if delivery is enabled
    selectedShippingCoupon =
        widget.isDelivery == false ? null : widget.initialShippingCoupon;
    loadCoupons();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  Future<void> loadCoupons() async {
    try {
      setState(() {
        isLoading = true;
      });

      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      List<Coupon> fetchedCoupons =
          await _discountService.getCouponsByUserId(userId);

      setState(() {
        coupons = fetchedCoupons;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải dữ liệu: $e')),
        );
      }
    }
  }

  Future<void> applyCouponCode(String couponId) async {
    if (couponId.isEmpty) {
      setState(() {
        errorMessage = 'Vui lòng nhập mã giảm giá';
      });
      return;
    }

    setState(() {
      isSubmitting = true;
      errorMessage = null;
    });

    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      bool success = await _discountService.applyCouponToUser(userId, couponId);

      if (success) {
        // Reload coupons after successful application
        await loadCoupons();
        setState(() {
          isSubmitting = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Mã giảm giá đã được áp dụng thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Clear text field
        _couponController.clear();
      } else {
        setState(() {
          isSubmitting = false;
          errorMessage =
              'Mã giảm giá không hợp lệ, đã được sử dụng hoặc hết hạn. Vui lòng kiểm tra lại!';
        });
      }
    } catch (e) {
      setState(() {
        isSubmitting = false;
        errorMessage = 'Lỗi khi áp dụng mã giảm giá: $e';
      });
    }
  }

  void selectCoupon(Coupon coupon) {
    setState(() {
      if (coupon.type == CouponType.order) {
        selectedOrderCoupon = (selectedOrderCoupon == coupon) ? null : coupon;
      } else if (coupon.type == CouponType.shipping) {
        // Only allow selecting shipping coupon if delivery is enabled
        if (widget.isDelivery == true) {
          selectedShippingCoupon =
              (selectedShippingCoupon == coupon) ? null : coupon;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Ưu Đãi', showCart: false),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.orangeAccent,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.orangeAccent,
              indicatorWeight: 3,
              tabs: [
                Tab(
                  icon: Icon(Icons.card_giftcard),
                  text: 'Ưu đãi',
                ),
                Tab(
                  icon: Icon(Icons.redeem),
                  text: 'E-Voucher',
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCouponsTab(),
                _buildEVoucherTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: widget.subtotal == null
          ? null
          : Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'orderCoupon': selectedOrderCoupon,
                    // Only return shipping coupon if delivery is enabled
                    'shippingCoupon': widget.isDelivery == true
                        ? selectedShippingCoupon
                        : null,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Xác nhận',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildCouponsTab() {
    return isLoading
        ? Center(child: CircularProgressIndicator(color: Colors.orangeAccent))
        : coupons.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.card_giftcard,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Không có phiếu giảm giá nào',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Hãy nhập mã giảm giá ở tab E-Voucher',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.only(top: 12, bottom: 12),
                itemCount: coupons.length,
                itemBuilder: (context, index) {
                  final coupon = coupons[index];
                  final fee = widget.subtotal;

                  // Check if coupon is valid based on the type and delivery status
                  bool isShippingCouponDisabled =
                      coupon.type == CouponType.shipping &&
                          widget.isDelivery == false;

                  bool isValid = fee != null &&
                      _discountService.isValid(
                          coupon.expiredDate, fee, coupon.minPurchaseAmount) &&
                      !isShippingCouponDisabled;

                  bool isSelected = (coupon.type == CouponType.order &&
                          coupon.couponId == selectedOrderCoupon?.couponId) ||
                      (coupon.type == CouponType.shipping &&
                          coupon.couponId == selectedShippingCoupon?.couponId);

                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.orange.shade50
                          : (isValid ? Colors.white : Colors.grey.shade100),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Colors.orangeAccent
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              )
                            ]
                          : [],
                    ),
                    child: InkWell(
                      onTap: () {
                        if (isValid) {
                          selectCoupon(coupon);
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                coupon.couponImageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey.shade200,
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      coupon.couponName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: isShippingCouponDisabled
                                            ? Colors.grey
                                            : Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isShippingCouponDisabled
                                                ? Colors.grey.shade200
                                                : Colors.green.shade50,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            border: Border.all(
                                              color: isShippingCouponDisabled
                                                  ? Colors.grey.shade300
                                                  : Colors.green.shade200,
                                            ),
                                          ),
                                          child: Text(
                                            'Giảm ${coupon.isPercentage ? "${coupon.discountValue.toInt()}%" : Utils().formatCurrency(coupon.discountValue)}',
                                            style: TextStyle(
                                              color: isShippingCouponDisabled
                                                  ? Colors.grey
                                                  : Colors.green.shade700,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    if (coupon.minPurchaseAmount > 0)
                                      Text(
                                        "Đơn tối thiểu: ${Utils().formatCurrency(coupon.minPurchaseAmount)}",
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    if (isShippingCouponDisabled)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          "Không khả dụng khi tự đến lấy",
                                          style: TextStyle(
                                            color: Colors.red.shade700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    if (coupon.type == CouponType.shipping &&
                                        widget.isDelivery == true)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 4.0),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            "Phiếu giảm giá vận chuyển",
                                            style: TextStyle(
                                              color: Colors.blue.shade700,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        "HSD: ${coupon.expiredDate.day}/${coupon.expiredDate.month}/${coupon.expiredDate.year}",
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            if (isSelected)
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.orangeAccent,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              )
                            else
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isValid
                                        ? Colors.grey.shade300
                                        : Colors.grey.shade200,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check,
                                  color: Colors.transparent,
                                  size: 20,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
  }

  Widget _buildEVoucherTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Nhập mã E-Voucher',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Nhập mã giảm giá vào ô bên dưới để thêm vào danh sách ưu đãi của bạn',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                color: Colors.grey.shade50,
              ),
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _couponController,
                decoration: InputDecoration(
                  hintText: 'Nhập mã giảm giá',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () => _couponController.clear(),
                    color: Colors.grey.shade400,
                  ),
                ),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textCapitalization: TextCapitalization.characters,
                onChanged: (value) {
                  if (errorMessage != null) {
                    setState(() {
                      errorMessage = null;
                    });
                  }
                },
              ),
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                child: Text(
                  errorMessage!,
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 13,
                  ),
                ),
              ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () => applyCouponCode(_couponController.text.trim()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                disabledBackgroundColor: Colors.grey.shade300,
              ),
              child: isSubmitting
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Áp dụng',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            SizedBox(height: 32),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Lưu ý',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Mã E-Voucher có thể là mã giảm giá đơn hàng hoặc mã giảm giá vận chuyển',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '• Mỗi mã chỉ có thể sử dụng một lần',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '• Đảm bảo nhập đúng mã, bao gồm cả viết hoa nếu có',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
