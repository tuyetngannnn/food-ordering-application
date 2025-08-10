import 'package:flutter/material.dart';
import 'package:demo_firebase/repo/payment.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ZaloPayment {
  static const MethodChannel _channel = MethodChannel('channelPayOrder');

  // Process payment with ZaloPay
  static Future<bool> processPayment(
      BuildContext context, double subtotal) async {
    try {
      // _listenForPaymentResult(context); // Lắng nghe kết quả thanh toán

      int amount = subtotal.round();
      _showLoadingDialog(context);

      final orderResponse = await createOrder(amount);
      Navigator.pop(context);

      if (orderResponse == null) {
        _showErrorDialog(
            context, "Không thể tạo đơn hàng. Vui lòng thử lại sau.");
        return false;
      }
      print("ZaloPay Order URL: ${orderResponse.orderurl}");

      final paymentResult = await _channel.invokeMethod('payOrder', {
        'zptoken': orderResponse.zptranstoken,
      });
      print("ResultL: ${paymentResult}");

      if (paymentResult == "Payment Success") return true;
      return false;
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      _showErrorDialog(context, "Đã xảy ra lỗi: ${e.toString()}");
      return false;
    }
  }

  // Show loading dialog (keeping this method from original code)
  static void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              ),
              SizedBox(height: 16),
              Text("Đang xử lý thanh toán...")
            ],
          ),
        );
      },
    );
  }

  // static void _listenForPaymentResult(BuildContext context) {
  //   const MethodChannel channel = MethodChannel('channelPayOrder');
  //   channel.setMethodCallHandler((call) async {
  //     if (call.method == "paymentResult") {
  //       String result = call.arguments;
  //       print("Nhận kết quả từ Native: $result");
  //       if (result == "Payment Success") {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text("Thanh toán ZaloPay thành công!"),
  //             backgroundColor: Colors.green,
  //           ),
  //         );
  //       } else if (result == "User Canceled") {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text("Bạn đã hủy thanh toán."),
  //             backgroundColor: Colors.orange,
  //           ),
  //         );
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text("Thanh toán thất bại."),
  //             backgroundColor: Colors.red,
  //           ),
  //         );
  //       }
  //     }
  //   });
  // }

  // Show error dialog (keeping this method from original code)
  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Thông báo"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("Đóng"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
