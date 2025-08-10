import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_firebase/models/coupon.dart';

class DiscountService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Coupon>> getCouponsByUserId(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        print("User not found");
        return [];
      }

      List<dynamic> couponIds = userDoc.get('couponId') ?? [];

      if (couponIds.isEmpty) {
        print("No coupons found for user.");
        return [];
      }

      QuerySnapshot couponDocs = await _firestore
          .collection('coupons')
          .where(FieldPath.documentId, whereIn: couponIds)
          .get();

      List<Coupon> coupons = couponDocs.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['couponId'] = doc.id;
        return Coupon.fromJson(data);
      }).toList();

      return coupons;
    } catch (e) {
      print("Error fetching coupons for user $userId: $e");
      return [];
    }
  }

  Future<bool> applyCouponToUser(String userId, String couponId) async {
    try {
      DocumentSnapshot couponDoc = await _firestore
          .collection('coupons')
          .doc(couponId)
          .get();

      if (!couponDoc.exists) {
        print("Coupon not found: $couponId");

        return false;
      }

      Map<String, dynamic> couponData = couponDoc.data() as Map<String, dynamic>;
      DateTime expiredDate = (couponData['expiredDate'] as Timestamp).toDate();

      if (DateTime.now().isAfter(expiredDate)) {
        print("Coupon expired: $couponId");
        return false;
      }

      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        print("User not found: $userId");
        return false;
      }

      List<dynamic> userCoupons = userDoc.get('couponId') ?? [];

      if (userCoupons.contains(couponId)) {
        print("User already has this coupon: $couponId");
        return false;
      }

      userCoupons.add(couponId);

      await _firestore
          .collection('users')
          .doc(userId)
          .update({'couponId': userCoupons});

      print("Coupon applied successfully: $couponId");
      return true;
    } catch (e) {
      print("Error applying coupon: $e");
      return false;
    }
  }

  bool isValid(DateTime expiredDate, num fee, double minPurchaseAmount) {
    final currentDate = DateTime.now();

    if (currentDate.isAfter(expiredDate)) return false;
    if (fee < minPurchaseAmount) return false;
    return true;
  }

  double getDiscountPrice(double subTotal, double deliveryFee, CouponType type,
      bool isPercentage, double discountValue, double? maxDiscountValue) {
    double discountAmount = 0.0;
    double applicableAmount =
    (type == CouponType.order) ? subTotal : deliveryFee;

    // Calculate discount
    discountAmount =
    isPercentage ? applicableAmount * (discountValue / 100) : discountValue;

    // Ensure discount does not exceed maxDiscountValue
    if (maxDiscountValue != null && discountAmount > maxDiscountValue) {
      discountAmount = maxDiscountValue;
    }

    // Ensure discount does not exceed actual price (subTotal or deliveryFee)
    if (discountAmount > applicableAmount) {
      discountAmount = applicableAmount;
    }

    return discountAmount;
  }
}