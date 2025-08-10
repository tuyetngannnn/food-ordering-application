import 'package:demo_firebase/screens/register_phone.dart';
import 'package:demo_firebase/services/forgot_password.dart';
import 'package:demo_firebase/services/phone_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_firebase/services/auth_service.dart';
import 'package:demo_firebase/services/register.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main_screen.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  String _message = "";
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  // Hàm lưu member đã đăng nha
  void _saveRememberedUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('email', _emailController.text);
      await prefs.setString('password', _passwordController.text);
      await prefs.setBool('rememberMe', true);
    } else {
      await prefs.clear();
    }
  }

  // Check user đã đăng nhập trước đó hay chưa
  void _checkAutoLogin() async {
    if (_auth.currentUser != null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MainScreen()),
        (route) => false,
      );
    }
  }

  // Hàm đăng ký
  void _handleSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterScreen()),
    );
  }

  // Hàm đăng nhập
  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _message = '';
      });
      try {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        _saveRememberedUser();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      } catch (e) {
        setState(() {
          _message = e.toString();
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Hàm validate email
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Vui lòng nhập email";
    }
    String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    if (!RegExp(emailPattern).hasMatch(value)) {
      return "Email không đúng định dạng";
    }
    return null;
  }

  // Hàm validate mật khẩu
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Vui lòng nhập mật khẩu";
    }
    if (value.length < 6) {
      return "Mật khẩu phải có ít nhất 6 ký tự";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Background with curved shape
          Padding(
            padding: EdgeInsets.only(top: size.height * 0.05),
            child: SizedBox(
              width: double.infinity,
              height: double.maxFinite,
              child: Image.asset(
                'assets/bg_login.png', // Background image
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo positioned correctly at top left
                      Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Image.asset(
                            'assets/logo1.png',
                            width: 100, // Adjust size to match design
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.005),

                      // Login title - centered and bold
                      Center(
                        child: Text(
                          "ĐĂNG NHẬP",
                          style: TextStyle(
                            color: const Color(0xFFDD2F36),
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.04),

                      TextFormField(
                        controller: _emailController,
                        validator: _validateEmail,
                        style: TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Color(0xFFDD2F36)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Color(0xFFDD2F36)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: Color(0xFFDD2F36), width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),

                      SizedBox(height: size.height * 0.03),

                      // Password field - with red border only
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        validator: _validatePassword,
                        style: TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Mật khẩu',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Color(0xFFDD2F36)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Color(0xFFDD2F36)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: Color(0xFFDD2F36), width: 2),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      SizedBox(height: size.height * 0.001),

                      // Remember me checkbox và Forgot password chung hàng
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (value) =>
                                    setState(() => _rememberMe = value!),
                                activeColor: Color(0xFFE50001),
                              ),
                              Text(
                                'Ghi nhớ mật khẩu',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ForgotPassword(),
                                ),
                              );
                            },
                            child: Text(
                              "Quên mật khẩu",
                              style: TextStyle(
                                color: Color(0xFFDD2F36),
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: size.height * 0.015),

                      // Login button - full width red button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFD0000),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  "Đăng Nhập",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      SizedBox(height: 15),

                      // "Don't have account" text and sign up link
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Bạn chưa có tài khoản? ",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: _handleSignUp,
                              child: Text(
                                "Đăng ký ngay",
                                style: TextStyle(
                                  color: Color(0xFFFD0000),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  decoration:
                                      TextDecoration.underline, // Gạch chân
                                  decorationColor: Colors.red, // Màu gạch chân
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade400)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "hoặc",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade400)),
                        ],
                      ),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          minimumSize: Size(double.infinity, 45),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/phone.png',
                              height: 24,
                              width: 24,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Đăng nhập với số điện thoại",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),

                      OutlinedButton(
                        onPressed: () async {
                          try {
                            User? user = await AuthService().signInWithGoogle();
                            if (user != null) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MainScreen(),
                                ),
                              );
                            } else {
                              setState(() {
                                _message =
                                    "Đăng nhập với Google bị hủy. Thử lại!";
                              });
                            }
                          } catch (e) {
                            setState(() {
                              _message = "Lỗi đăng nhập: $e";
                            });
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          minimumSize: Size(double.infinity, 45),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/gg.png',
                              height: 24,
                              width: 24,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Đăng nhập với Google",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Error message display
                      if (_message.isNotEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              _message,
                              style: TextStyle(color: Colors.red, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
