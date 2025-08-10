import 'package:demo_firebase/screens/cart/cart_screen.dart';
import 'package:demo_firebase/screens/home_screen.dart';
import 'package:demo_firebase/screens/news/news_screen_1.dart';
import 'package:demo_firebase/screens/profile.dart';
import 'package:demo_firebase/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'screens/main_screen.dart';
import 'screens/screen_loading.dart';
import 'screens/login.dart'; // Import màn hình đăng nhập
import 'firebase_options.dart'; // Import Firebase options

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Đảm bảo Flutter khởi tạo trước
  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions.currentPlatform, // Nếu có Firebase CLI setup
  );
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Color(0xFFFFFFFF), // Màu nền của status bar
      statusBarIconBrightness:
          Brightness.dark, // Icon màu đen (dark) hoặc trắng (light)
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/', // Route mặc định
        routes: {
          // '/': (context) => MainScreen(),
          '/': (context) => ScreenLoading1(),
          '/home': (context) => MainScreen(),
          // '/': (context) => CartScreen(),
          // '/': (context) => NewsScreen2(),
          '/login': (context) => AuthScreen(), // Màn hình đăng nhập
        },
      ),
    );
  }
}
