import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:demo_firebase/services/auth_service.dart';

import '../screens/main_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _message = "";

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    User? user = await _authService.signUp(
      _emailController.text,
      _passwordController.text,
      _nameController.text,
      isManager: false,
    );

    if (user != null) {
      await _firestore.collection("users").doc(user.uid).set({
        "email": user.email,
        "name": _nameController.text,
        "phone": "",
        "diachi": "",
        "role": "customer",
        "createdAt": FieldValue.serverTimestamp(),
      });

      setState(() {
        _message = "Đăng ký thành công!";
      });

      DocumentSnapshot userDoc =
          await _firestore.collection("users").doc(user.uid).get();
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } else {
      setState(() {
        _message = "Đăng ký thất bại! Vui lòng thử lại.";
      });
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Vui lòng nhập tên người dùng";
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Vui lòng nhập email";
    }
    // Kiểm tra định dạng email
    String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    if (!RegExp(emailPattern).hasMatch(value)) {
      return "Email không đúng định dạng";
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Vui lòng nhập mật khẩu";
    }
    if (value.length < 6) {
      return "Mật khẩu phải có ít nhất 6 ký tự";
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Vui lòng nhập lại mật khẩu";
    }
    if (value != _passwordController.text) {
      return "Mật khẩu xác nhận không khớp";
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
          // Background with curved shape - same approach as login page
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
                      // Logo positioned correctly at top left - same as login
                      Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Image.asset(
                            'assets/logo1.png',
                            width: 100,
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.005),

                      // Register title - using same styling as login page
                      Center(
                        child: Text(
                          "ĐĂNG KÝ",
                          style: TextStyle(
                            color: const Color(0xFFDD2F36),
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.04),

                      // Name field - using same styling as login page text fields
                      TextFormField(
                        controller: _nameController,
                        validator: _validateName,
                        style: TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Tên đăng nhập',
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

                      // Email field - using same styling as login page
                      TextFormField(
                        controller: _emailController,
                        validator: _validateEmail,
                        keyboardType: TextInputType.emailAddress,
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

                      // Password field - using same styling as login page
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

                      SizedBox(height: size.height * 0.03),

                      // Confirm Password field - using same styling as login page
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        validator: _validateConfirmPassword,
                        style: TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Nhập lại mật khẩu',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Color(0xFFC82027)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Color(0xFFC82027)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: Color(0xFFC82027), width: 2),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),

                      SizedBox(height: size.height * 0.02),

                      // Error message display - using same styling as login page
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

                      SizedBox(height: size.height * 0.03),

                      // Register button - using same styling as login page
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFD0000),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            "Đăng Ký",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 15),

                      // Already have account text and sign in link - using same styling
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Bạn đã có tài khoản? ",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Đăng nhập",
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
