import 'package:demo_firebase/screens/home_screen.dart';
import 'package:demo_firebase/screens/invoice/invoice_screen.dart';
import 'package:demo_firebase/screens/main_screen.dart';
import 'package:flutter/material.dart';

class HomeDeliveryScreen extends StatelessWidget {
  final String orderId;
  const HomeDeliveryScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    print("HomeDeliveryScreen - orderId: $orderId"); // Kiểm tra orderId

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(width * 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(width * 0.1),
              child:
                  Image.asset('assets/home_delivery.png', fit: BoxFit.fitWidth),
            ),
            SizedBox(height: height * 0.02),
            Text(
              'ĐẶT HÀNG THÀNH CÔNG!',
              style: TextStyle(
                  color: Color(0xFFD3212C),
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: height * 0.02),
            Text(
              'Đơn hàng sẽ sớm được giao đến bạn, vui lòng chú ý điện thoại',
              style: TextStyle(
                  color: Color(0xFF655E5E),
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: height * 0.02),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              InvoiceScreen(orderId: orderId)));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Theo Dõi Đơn Hàng',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => MainScreen()),
                  (route) => false,
                );
              },
              child: Text(
                'Quay về trang chủ',
                style: TextStyle(
                  color: Color(0xFFB9B9B9),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
