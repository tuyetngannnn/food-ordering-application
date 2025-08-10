import 'dart:async';
import 'package:demo_firebase/widgets/delivery_address_widget.dart';
import 'package:demo_firebase/widgets/list_news_widget.dart';
import 'package:flutter/material.dart';
import '../widgets/cart_badge.dart';
import 'cart/cart_screen.dart';
import '../widgets/list_combo_widget.dart';
import 'main_screen.dart';
import 'menu_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController();
  final List<String> _images = [
    'assets/banner3.jpg',
    'assets/banner4.jpg',
    'assets/banner5.jpg',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _appBar(context),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner Slider
                  _slider(),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: DeliveryAddressWidget(),
                  ),

                  _enjoyNowContent(),

                  // _mustTryContent(),

                  _newsContent(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _appBar(BuildContext context) {
    return Container(
      color: Colors.white, // Màu nền của header
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 40, // Tránh status bar
        // bottom: 10, // Khoảng cách dưới
        left: 10,
        right: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Image.asset(
            'assets/icon_home.jpg',
            width: 200,
            fit: BoxFit.fitWidth,
          ),
          // Search and Cart Icons
          Row(
            children: [
              // IconButton(
              //   icon: Icon(Icons.search, size: 32, color: Colors.red),
              //   onPressed: () {
              //     // Xử lý khi bấm tìm kiếm
              //   },
              // ),
              CartBadge(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _slider() {
    return Column(
      children: [
        SizedBox(
          height: 200, // Chiều cao banner
          child: PageView.builder(
            controller: _pageController,
            itemCount: _images.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return Image.asset(
                _images[index],
                fit: BoxFit.cover,
                width: double.infinity,
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _images.asMap().entries.map((entry) {
            int index = entry.key;
            return Container(
              width: 8,
              height: 8,
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index ? Colors.red : Colors.grey,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _enjoyNowContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'THƯỞNG THỨC NGAY',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainScreen(initialIndex: 2),
                  ),
                ),
                child: Text(
                  'Xem tất cả',
                  style: TextStyle(
                    color: Color(0xFFD3212C),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MenuScreen(
                        color: Color(0xFFFD0000),
                        categoryId: 'gr',
                      ),
                    ),
                  ),
                  child: Container(
                    height: 250,
                    margin: EdgeInsets.only(right: 16),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Red background with rounded corners
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFFD0000),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),

                        // Title text at the top
                        Positioned(
                          top: 20,
                          left: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'GÀ GIÒN',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              Container(
                                width: 140,
                                child: Text(
                                  'Ngon nhất khi kết hợp với sốt chưa cay đặc biệt.',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Positioned(
                          bottom: -35,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Image.asset(
                              'assets/chicken_bucket_1.png',
                              width: 200,
                              height: 200,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Right side column with two containers
              Expanded(
                flex: 1, // Takes less space
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MenuScreen(
                            color: Color(0xFFFF9E6E),
                            categoryId: 'my',
                          ),
                        ),
                      ),
                      child: SizedBox(
                        height: 110,
                        // margin: EdgeInsets.only(bottom: 8),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFFFF5F0),
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            Positioned(
                              top: 20,
                              left: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'MÌ Ý',
                                    style: TextStyle(
                                      color: Color(0xFFFD0000),
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: -25,
                              left: 0,
                              right: -10,
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Image.asset(
                                  'assets/spaghetti_1.png',
                                  width: 100,
                                  // height: 100,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MenuScreen(
                            color: Color(0xFF009C75),
                            categoryId: 'bg',
                          ),
                        ),
                      ),
                      child: Container(
                        height: 110,
                        margin: EdgeInsets.only(top: 30),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFFFF5F0),
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            Positioned(
                              top: 20,
                              left: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'BURGER',
                                    style: TextStyle(
                                      color: Color(0xFFFD0000),
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: -25,
                              left: 0,
                              right: -10,
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Image.asset(
                                  'assets/burger_1.png',
                                  width: 100,
                                  // height: 100,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  // Widget _mustTryContent() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Padding(
  //         padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
  //         child: Text(
  //           textAlign: TextAlign.left,
  //           'MÓN NGON PHẢI THỬ',
  //           style: TextStyle(
  //             color: Colors.black,
  //             fontSize: 18,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //       ),
  //       ListComboWidget(),
  //     ],
  //   );
  // }

  Widget _newsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          child: Text(
            textAlign: TextAlign.left,
            'TIN TỨC',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListNewsWidget(),
        SizedBox(height: 150),
      ],
    );
  }
}
