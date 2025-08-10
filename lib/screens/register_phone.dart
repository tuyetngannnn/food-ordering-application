import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_firebase/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:demo_firebase/services/auth_service.dart';

import '../screens/main_screen.dart';

class RegisterPhoneScreen extends StatefulWidget {
  const RegisterPhoneScreen({super.key});

  @override
  _RegisterPhoneScreenState createState() => _RegisterPhoneScreenState();
}

class _RegisterPhoneScreenState extends State<RegisterPhoneScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _smsCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _verificationId;
  String _message = "";
  bool _isCodeSent = false;
  bool _isLoading = false;
  bool _showNameAndVerifyFields = false;

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  void _checkAutoLogin() {
    if (_auth.currentUser != null) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _checkPhoneNumber() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _message = "";
    });

    String phoneNumber =
        "+84${_phoneController.text.trim().replaceFirst(RegExp(r'^0'), '')}";
    print("PhoneNumber đã nhập: $phoneNumber");

    try {
      bool isRegistered =
          await _authService.isPhoneNumberRegistered(phoneNumber);

      if (isRegistered) {
        // Nếu đã có tài khoản => Gửi OTP và thực hiện đăng nhập
        await _sendVerificationCode(phoneNumber, isNewUser: false);
      } else {
        // Nếu chưa có tài khoản => Hiển thị form nhập tên
        setState(() {
          _showNameAndVerifyFields = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _message = "Đã xảy ra lỗi: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _sendVerificationCode(String phoneNumber,
      {bool isNewUser = true}) async {
    setState(() {
      _isLoading = true;
      _message = "";
    });

    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-sign in nếu có thể
          await _authService.signInWithPhoneNumber(
            verificationId: _verificationId ?? "",
            smsCode: credential.smsCode ?? "",
            name: isNewUser ? _nameController.text.trim() : null,
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _message = "Xác thực thất bại: ${e.message}";
            _isLoading = false;
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _isCodeSent = true;
            _isLoading = false;
            _message = "Mã xác thực đã được gửi";
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _verificationId = verificationId;
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _message = "Đã xảy ra lỗi: $e";
        _isLoading = false;
      });
    }
  }

  void _verifyCode() async {
    if (_verificationId == null) return;

    User? user = await _authService.signInWithPhoneNumber(
      verificationId: _verificationId!,
      smsCode: _smsCodeController.text.trim(),
      name: _showNameAndVerifyFields ? _nameController.text.trim() : null,
    );

    if (user != null) {
      setState(() {
        _message = "Đăng nhập thành công!";
      });
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MainScreen()),
        (route) => false,
      );
    } else {
      setState(() {
        _message = "Xác thực mã thất bại";
      });
    }
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Vui lòng nhập số điện thoại";
    }
    if (!RegExp(r'^[0-9]{9,10}$').hasMatch(value.trim())) {
      return "Số điện thoại không hợp lệ";
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Vui lòng nhập tên người dùng";
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
                          "ĐĂNG NHẬP",
                          style: TextStyle(
                            color: const Color(0xFFDD2F36),
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.04),

                      // Phone number field
                      TextFormField(
                        controller: _phoneController,
                        validator: _validatePhoneNumber,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Số điện thoại',
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

                      if (_showNameAndVerifyFields)
                        Column(
                          children: [
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
                                  borderSide:
                                      BorderSide(color: Color(0xFFDD2F36)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Color(0xFFDD2F36)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: Color(0xFFDD2F36), width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: size.height * 0.03),

                      // SMS Code field - only show if code is sent
                      if (_isCodeSent)
                        TextFormField(
                          controller: _smsCodeController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Mã xác thực',
                            border: OutlineInputBorder(),
                          ),
                        ),

                      SizedBox(height: size.height * 0.03),

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

                      ElevatedButton(
                        onPressed: () {
                          if (_isCodeSent) {
                            _verifyCode();
                          } else if (_showNameAndVerifyFields) {
                            // If name fields are shown, send verification code for new user
                            String phoneNumber =
                                "+84${_phoneController.text.trim().replaceFirst(RegExp(r'^0'), '')}";
                            _sendVerificationCode(phoneNumber, isNewUser: true);
                          } else {
                            _checkPhoneNumber();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFD0000),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                          minimumSize: Size(double.infinity, 50),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : Text(
                                _isCodeSent
                                    ? 'Xác nhận'
                                    : (_showNameAndVerifyFields
                                        ? 'Gửi mã xác thực'
                                        : 'Tiếp tục'),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),

                      SizedBox(height: size.height * 0.03),

                      SizedBox(height: size.height * 0.02),

                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AuthScreen(),
                            ),
                          );
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
                              'assets/email.png',
                              height: 24,
                              width: 24,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Đăng nhập với Email",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),

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
