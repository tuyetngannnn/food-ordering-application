import 'package:demo_firebase/screens/menu_screen.dart';
import 'package:demo_firebase/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

import '../main_screen.dart';

class EmptyCartScreen extends StatelessWidget {
  const EmptyCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: customAppBar(context, 'Giỏ hàng', showCart: false),
      body: Padding(
        padding: EdgeInsets.all(width * 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'GIỎ HÀNG TRỐNG',
              style: TextStyle(
                  color: Color(0xFFFD0000),
                  fontSize: 26,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: height * 0.02),
            Text(
              'Chưa có món nào trong giỏ! Đặt ngay để thưởng thức thôi!',
              style: TextStyle(
                  color: Color(0xFF655E5E),
                  fontSize: 18,
                  fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: height * 0.03),
            Image.asset('assets/empty_card.png',
                height: height * 0.2, fit: BoxFit.fitWidth),
            SizedBox(height: height * 0.03),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MainScreen(initialIndex: 2)));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFD0000),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Khám phá thực đơn',
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
