import 'package:flutter/material.dart';

class MenuItem {
  final String name;
  final String price;
  final String imagePath;

  MenuItem({
    required this.name,
    required this.price,
    required this.imagePath,
  });
}

class ListComboWidget extends StatelessWidget {
  ListComboWidget({super.key});

  final List<MenuItem> menuItems = [
    MenuItem(
      name: 'Combo Một Mình Ăn Ngonnnnn',
      price: '79,000 đ',
      imagePath: 'assets/chicken_bucket_1.png',
    ),
    MenuItem(
      name: 'Gà Rán Giòn Tan',
      price: '65,000 đ',
      imagePath: 'assets/chicken_bucket_1.png',
    ),
    MenuItem(
      name: 'Pizza Hải Sản',
      price: '99,000 đ',
      imagePath: 'assets/chicken_bucket_1.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _buildFoodCard(menuItems[index], context),
          );
        },
      ),
    );
  }

  Widget _buildFoodCard(MenuItem item, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 3,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              // Food Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  item.imagePath,
                  height: 100,
                  fit: BoxFit.cover,
                  // Use a placeholder during development
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[300],
                      child: Icon(Icons.fastfood, color: Colors.grey[600]),
                    );
                  },
                ),
              ),
              SizedBox(width: 16),
              // Food Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      item.price,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Mua ngay',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
