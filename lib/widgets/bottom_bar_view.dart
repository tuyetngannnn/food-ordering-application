import 'package:demo_firebase/screens/favourite_screen.dart';
import 'package:demo_firebase/screens/home_screen.dart';
import 'package:demo_firebase/screens/profile.dart';
import 'package:flutter/material.dart';

import '../screens/category_screen.dart';
import '../screens/notification/notification_screen.dart';

class BottomBarView extends StatefulWidget {
  final int initialIndex;

  const BottomBarView({super.key, required this.initialIndex});

  @override
  _BottomBarViewState createState() => _BottomBarViewState();
}

class _BottomBarViewState extends State<BottomBarView>
    with SingleTickerProviderStateMixin {
  late int _selectedIndex;
  late PageController _pageController;

  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;

  final List<Widget> _pages = [
    HomeScreen(),
    FavouriteScreen(),
    CategoryScreen(),
    // TestScreen(),
    NotificationScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; // Set the initial tab
    _pageController = PageController(initialPage: _selectedIndex);

    _fabAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _fabScaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.easeOutQuad,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 500),
      curve: Curves.decelerate,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: BouncingScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _pages,
      ),
      extendBody: true,
      floatingActionButton: ScaleTransition(
        scale: _fabScaleAnimation,
        child: FloatingActionButton(
          backgroundColor: Colors.white,
          onPressed: () {
            _fabAnimationController.forward().then((_) {
              Future.delayed(Duration(milliseconds: 100), () {
                _fabAnimationController.reverse();
              });
            });
            _onItemTapped(2);
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: Icon(Icons.receipt_long, size: 32, color: Color(0xFFFD0000)),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8,
        color: Color(0xFFFD0000),
        child: Container(
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(_selectedIndex == 0 ? Icons.home : Icons.home_outlined,
                    size: 32,
                    color: _selectedIndex == 0 ? Colors.white : Colors.white70),
                onPressed: () => _onItemTapped(0),
              ),
              IconButton(
                icon: Icon(_selectedIndex == 1 ? Icons.favorite_outlined : Icons.favorite_border,
                    size: 32,
                    color: _selectedIndex == 1 ? Colors.white : Colors.white70),
                onPressed: () => _onItemTapped(1),
              ),
              SizedBox(width: 40), // Space for FAB
              IconButton(
                icon: Icon(_selectedIndex == 3 ? Icons.notifications : Icons.notifications_none,
                    size: 32,
                    color: _selectedIndex == 3 ? Colors.white : Colors.white70),
                onPressed: () => _onItemTapped(3),
              ),
              IconButton(
                icon: Icon(_selectedIndex == 4 ? Icons.person : Icons.person_outline,
                    size: 32,
                    color: _selectedIndex == 4 ? Colors.white : Colors.white70),
                onPressed: () => _onItemTapped(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
