import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final auth = FirebaseAuth.instance;
  String _message = '';
  bool _isLoading = false;

  // Email validation
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    }
    String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    if (!RegExp(emailPattern).hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _message = '';
      });

      try {
        await auth.sendPasswordResetEmail(email: _emailController.text.trim());
        setState(() {
          _message =
              'Chúng tôi đã gửi liên kết đặt lại mật khẩu đến email của bạn';
        });
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          setState(() {
            _message = 'Email không tồn tại trong hệ thống';
          });
        } else {
          setState(() {
            _message = e.message ?? 'Đã xảy ra lỗi';
          });
        }
      } catch (e) {
        setState(() {
          _message = 'Đã xảy ra lỗi: $e';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
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

                      SizedBox(height: size.height * 0.05),

                      // Forgot Password title - centered and bold
                      Center(
                        child: Text(
                          "QUÊN MẬT KHẨU",
                          style: TextStyle(
                            color: const Color(0xFFDD2F36),
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.01),

                      // Instruction text
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "Vui lòng nhập email của bạn để nhận liên kết đặt lại mật khẩu nhanh chóng.",
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFFB9B9B9),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      SizedBox(height: size.height * 0.04),

                      // Email field - with red border only
                      TextFormField(
                        controller: _emailController,
                        validator: _validateEmail,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle: TextStyle(
                            fontSize: 19,
                            color: Color(0xFFB9B9B9),
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

                      // Reset password button - full width red button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _resetPassword,
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
                                  "Gửi",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      SizedBox(height: 15),

                      // Success/Error message display
                      if (_message.isNotEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              _message,
                              style: TextStyle(
                                color: _message.contains('gửi')
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),

                      SizedBox(height: 15),

                      // Back to login
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Quay lại đăng nhập",
                            style: TextStyle(
                              color: Color(0xFFDD2F36),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
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
