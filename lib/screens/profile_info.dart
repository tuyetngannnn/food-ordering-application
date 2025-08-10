import 'package:demo_firebase/services/auth_service.dart';
import 'package:demo_firebase/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileInfoPage extends StatefulWidget {
  @override
  _ProfileInfoPageState createState() => _ProfileInfoPageState();
}

class _ProfileInfoPageState extends State<ProfileInfoPage> {
  final AuthService _authService = AuthService();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController birthdateController = TextEditingController();

  String userName = '';
  String userEmail = '';
  bool showSuccessMessage = false;

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  void _saveChanges() async {
    User? user = _authService.getCurrentUser();
    if (user != null) {
      bool updateSuccessful = await _authService.updateUserProfile(
        uid: user.uid,
        name: usernameController.text,
        phone: phoneController.text,
        birthdate: birthdateController.text,
      );

      if (updateSuccessful) {
        setState(() {
          showSuccessMessage = true;
          userName = usernameController.text;
        });

        Future.delayed(Duration(seconds: 2), () {
          setState(() {
            showSuccessMessage = false;
          });
        });
      }
    }
  }

  Future<void> loadUserInfo() async {
    User? user = _authService.getCurrentUser();
    if (user != null) {
      // Set email from Firebase Authentication
      setState(() {
        userEmail = _authService.getUserEmail() ?? '';
        userName = _authService.getUserDisplayName();
        emailController.text = userEmail;
      });

      // Fetch additional user info from Firestore
      Map<String, dynamic>? userData =
          await _authService.fetchUserInfo(user.uid);

      if (userData != null) {
        setState(() {
          usernameController.text = userData['name'] ?? userName;
          phoneController.text =
              Utils().formatPhoneNumber(userData['phone'] ?? '');
          birthdateController.text = userData['birthdate'] ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Thông tin cá nhân',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 70,
                backgroundImage: AssetImage('assets/avatar.png'),
              ),
              SizedBox(height: 10),
              Text(userName,
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFD0000))),
              SizedBox(height: 20),
              _buildTextField(usernameController, 'Tên đăng nhập'),
              _buildReadOnlyTextField(phoneController, 'Số điện thoại'),
              _buildTextField(emailController, 'Email'),
              _buildDateField(birthdateController, 'Ngày sinh'),
              SizedBox(height: 20),

              // Save Changes Button with Success Message
              Stack(
                alignment: Alignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('Lưu thay đổi',
                        style: TextStyle(color: Colors.white, fontSize: 23)),
                  ),
                  if (showSuccessMessage)
                    Positioned(
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Color(0xFFFD0000),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Lưu thay đổi thành công',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 23),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.check_circle, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyTextField(
      TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextField(
        controller: controller,
        readOnly: true,
        style: TextStyle(fontSize: 20, color: Colors.grey),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade200,
          labelText: label,
          labelStyle: TextStyle(fontSize: 23, color: Colors.grey.shade400),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey, width: 1),
          ),
        ),
      ),
    );
  }

  // Existing _buildTextField and _buildDateField methods remain the same
  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextField(
        controller: controller,
        style: TextStyle(fontSize: 20, color: Colors.black),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: label,
          labelStyle: TextStyle(fontSize: 23, color: Colors.grey.shade400),
          floatingLabelStyle: TextStyle(fontSize: 23, color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red, width: 1),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
          controller: controller,
          style: TextStyle(fontSize: 20, color: Colors.black),
          readOnly: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            labelText: label,
            labelStyle: TextStyle(fontSize: 23, color: Colors.grey.shade400),
            floatingLabelStyle: TextStyle(fontSize: 23, color: Colors.black),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red, width: 1),
            ),
            suffixIcon: Icon(Icons.calendar_today, color: Colors.black),
          ),
          onTap: () async {
            DateTime initialDate = DateTime.now();

            if (controller.text.isNotEmpty) {
              try {
                List<String> dateParts = controller.text.split('/');
                initialDate = DateTime(
                  int.parse(dateParts[2]), // Year
                  int.parse(dateParts[1]), // Month
                  int.parse(dateParts[0]), // Day
                );
              } catch (e) {
                // Nếu format lỗi, vẫn giữ initialDate là DateTime.now()
              }
            }

            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: initialDate,
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );

            if (pickedDate != null) {
              setState(() {
                controller.text =
                    '${pickedDate.day.toString().padLeft(2, '0')}/'
                    '${pickedDate.month.toString().padLeft(2, '0')}/'
                    '${pickedDate.year}';
              });
            }
          }),
    );
  }
}
