import 'package:flutter/material.dart';

import '../models/news.dart';
import '../screens/news/news_screen_1.dart';
import '../screens/news/news_screen_2.dart';

class ListNewsWidget extends StatelessWidget {
  ListNewsWidget({super.key});

  final List<News> newsItems = [
    News(
        newsId: '1',
        newsImageUrl: 'assets/news_banner_1.jpg',
        newsTitle: 'SANG XỊN MỊN -WAGYU BURGER CHÍNH THỨC LÊN SÓNG!',
        newsFunction: (context) => Navigator.push(
            context, MaterialPageRoute(builder: (context) => NewsScreen1()))),
    News(
        newsId: '2',
        newsImageUrl: 'assets/news_banner_2.jpg',
        newsTitle: 'SINH NHẬT THÊM BÁNH, BÉ YÊU THÊM VUI - GIÁ CHỈ TỪ...',
        newsFunction: (context) => Navigator.push(
            context, MaterialPageRoute(builder: (context) => NewsScreen2()))),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: newsItems.length,
        itemBuilder: (context, index) {
          return _buildNewsCard(newsItems[index], context);
        },
      ),
    );
  }

  Widget _buildNewsCard(News item, BuildContext context) {
    return GestureDetector(
      onTap: () => item.newsFunction!(context),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.5,
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
          child: Column(
            children: [
              // Food Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  item.newsImageUrl,
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  item.newsTitle,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
