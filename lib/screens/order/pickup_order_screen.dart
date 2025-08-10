import 'package:flutter/material.dart';

class PickupOrderScreen extends StatelessWidget {
  const PickupOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

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
              child: Image.asset('assets/pickup_order.png', fit: BoxFit.fitWidth),
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
              'Cảm ơn bạn! Đơn hàng của bạn đã sẵn sàng, đừng quên ghé cửa hàng để nhận nhé!',
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
                  // Add your action here
                  print('Chi Tiết Đơn Hàng button pressed');
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
                  'Chi Tiết Đơn Hàng',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Add your action here
                  print('Tiếp Tục Đặt Món button pressed');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                  side: const BorderSide(color: Color(0xFFDC2626), width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Tiếp Tục Đặt Món',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
