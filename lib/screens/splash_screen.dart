import 'package:demo_firebase/screens/screen_loading.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'login.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Chuyển sang màn hình đăng nhập sau 3 giây
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => ScreenLoading1()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color:
              Color.fromRGBO(253, 0, 0, 1), // Màu nền đỏ (rgba(253, 0, 0, 1))
        ),
        child: Center(
          child: Image.asset(
            'assets/logo2.png', // Logo
            // width: MediaQuery.of(context).size.width *
            //     0.7, // 70% chiều rộng màn hình
            fit: BoxFit.fitWidth,
          ),
        ),
      ),
    );
  }
}
