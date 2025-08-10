import 'package:demo_firebase/screens/discount_screen.dart';
import 'package:demo_firebase/screens/login.dart';
import 'package:demo_firebase/screens/order/order_history.dart';
import 'package:demo_firebase/screens/policy/policy_screen.dart';
import 'package:demo_firebase/screens/register_phone.dart';
import 'package:demo_firebase/screens/screen_loading.dart';
import 'package:demo_firebase/screens/store_list_screen.dart';
import 'package:demo_firebase/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import './profile_info.dart';
import './change_password.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = 'User';
  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  void _loadUserName() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userName = user.displayName ?? user.email?.split('@').first ?? 'User';
      });
    }
  }

  void _handleLogout(BuildContext context) async {
    await AuthService().signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            title: Column(
              children: [
                const SizedBox(height: 20),
                const CircleAvatar(
                  radius: 55,
                  backgroundImage: AssetImage('assets/avatar.png'),
                ),
                const SizedBox(height: 5),
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 245, 0, 0),
                  ),
                ),
              ],
            ),
            centerTitle: true,
            toolbarHeight: 180,
            pinned: true,
            floating: false,
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const Divider(
                    color: Color.fromARGB(255, 251, 224, 222), thickness: 4),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    'Tài khoản của tôi',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black),
                  ),
                ),
                _buildMenuItem(Icons.person, 'Thông tin cá nhân', context),
                _buildMenuItem(Icons.lock, 'Mật khẩu & Bảo mật', context),
                _buildMenuItem(Icons.history, 'Lịch sử đơn hàng', context),
                _buildMenuItem(Icons.confirmation_number, 'Ưu đãi', context),
                const Divider(
                    color: Color.fromARGB(255, 251, 224, 222), thickness: 4),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    'Thông tin chung',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black),
                  ),
                ),
                _buildMenuItem(
                    Icons.store_mall_directory, 'Danh sách cửa hàng', context),
                _buildMenuItem(Icons.policy, 'Chính sách', context),
                const Divider(
                    color: Color.fromARGB(255, 251, 224, 222), thickness: 4),
                _buildMenuItem(Icons.logout, 'Đăng xuất', context),
                const SizedBox(height: 0),
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title, style: const TextStyle(fontSize: 22)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 20),
      onTap: () {
        if (title == 'Thông tin cá nhân') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfileInfoPage()),
          );
        }
        if (title == 'Mật khẩu & Bảo mật') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChangePasswordPage()),
          );
        }
        if (title == 'Lịch sử đơn hàng') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OrderHistoryScreen()),
          );
        }
        if (title == 'Ưu đãi') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DiscountScreen()),
          );
        }
        if (title == 'Danh sách cửa hàng') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => StoreListScreen()),
          );
        }
        if (title == 'Đăng xuất') {
          _handleLogout(context);
        }
        if (title == 'Chính sách') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PolicyScreen()),
          );
        }
      },
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Divider(color: Color.fromARGB(255, 251, 224, 222), thickness: 4),
        const SizedBox(height: 10),
        Image.asset(
          'assets/logo.jpg',
          width: 250,
          fit: BoxFit.contain,
        ),
        const Divider(
            color: Color.fromARGB(255, 251, 224, 222),
            thickness: 1,
            indent: 20,
            endIndent: 20),
        const SizedBox(height: 5),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.phone, size: 30),
            SizedBox(width: 10),
            Icon(Icons.language, size: 30),
            SizedBox(width: 10),
            Icon(Icons.smartphone, size: 30),
          ],
        ),
        const SizedBox(height: 5),
        const Divider(
            color: Color.fromARGB(255, 251, 224, 222),
            thickness: 1,
            indent: 20,
            endIndent: 20),
        const Text('Hotline CSKH', style: TextStyle(fontSize: 18)),
        const Text('0906 483 257', style: TextStyle(fontSize: 18)),
        const Divider(
            color: Color.fromARGB(255, 251, 224, 222),
            thickness: 1,
            indent: 20,
            endIndent: 20),
        const SizedBox(height: 10),
        const Text('Kết nối với CRUNCH & DASH', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                icon: const Icon(FontAwesomeIcons.facebook,
                    color: Colors.blue, size: 30),
                onPressed: () {}),
            IconButton(
                icon: const Icon(FontAwesomeIcons.instagram,
                    color: Colors.purple, size: 30),
                onPressed: () {}),
            IconButton(
                icon: const Icon(FontAwesomeIcons.tiktok,
                    color: Colors.black, size: 30),
                onPressed: () {}),
            IconButton(
                icon: const Icon(FontAwesomeIcons.youtube,
                    color: Colors.red, size: 30),
                onPressed: () {}),
          ],
        ),
        const SizedBox(height: 150),
      ],
    );
  }
}
