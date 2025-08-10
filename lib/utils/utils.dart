import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:demo_firebase/repo/payment.dart';
import 'package:intl/intl.dart';
import 'package:sprintf/sprintf.dart';

class Utils {
  String formatCurrency(num amount) {
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return format.format(amount);
  }

// Hàm format số điện thoại từ +84xxx về 0xxx
  String formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.startsWith('+84')) {
      return phoneNumber.replaceFirst('+84', '0');
    }
    return phoneNumber;
  }

  /// Function Format DateTime to String with layout string
  String formatNumber(double value) {
    final f = new NumberFormat("#,###", "vi_VN");
    return f.format(value);
  }

  double calculateDeliveryFee(double distance) {
    double distanceInKilometers = distance / 1000;
    double fee;
    if (distanceInKilometers <= 5) {
      fee = 10000; // Phí cố định cho dưới 5 km
    } else if (distanceInKilometers <= 10) {
      fee = 10000 + (distanceInKilometers - 5) * 3000; // 3,000 đ/km từ 5-10 km
    } else {
      fee = 25000 +
          (distanceInKilometers - 10) * 2000; // 2,000 đ/km từ 10 km trở đi
    }
    // Round down the fee to the nearest 1000
    return (fee / 1000).floor() * 1000;
  }

  /// Function Format DateTime to String with layout string
  static String formatDateTime(DateTime dateTime, String layout) {
    return DateFormat(layout).format(dateTime).toString();
  }

  static int transIdDefault = 1; // Cũng phải để static

  static String getAppTransId() {
    if (transIdDefault >= 100000) {
      transIdDefault = 1;
    }

    transIdDefault += 1;
    var timeString = formatDateTime(DateTime.now(), "yyMMdd_hhmmss");
    return sprintf("%s%06d", [timeString, transIdDefault]);
  }

  static String getBankCode() => "zalopayapp";
  static String getDescription(String apptransid) =>
      "Merchant Demo thanh toán cho đơn hàng  #$apptransid";

  static String getMacCreateOrder(String data) {
    var hmac = new Hmac(sha256, utf8.encode(ZaloPayConfig.key1));
    return hmac.convert(utf8.encode(data)).toString();
  }
}
