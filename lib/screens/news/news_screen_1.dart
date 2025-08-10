import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../widgets/custom_app_bar.dart';

class NewsScreen1 extends StatelessWidget {
  const NewsScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final double normalFontsize = 14;
    final double bigFontSize = 20;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: customAppBar(
          context, 'SANG XỊN MỊN -WAGYU BURGER CHÍNH THỨC LÊN SÓNG!',
          showCart: false),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner
              Image.asset('assets/news_banner_1.jpg', fit: BoxFit.fitWidth),

              // Main Content
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BẠN ĐÃ SẴN SÀNG NÂNG TẦM VỊ GIÁC VỚI MỘT TUYỆT TÁC BURGER MỚI CHƯA?',
                      style: TextStyle(
                        fontSize: normalFontsize + 2,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFD0000),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: normalFontsize,
                          color: Colors.black,
                          height: 1.5,
                        ),
                        children: const [
                          TextSpan(text: 'Chúng tôi tự hào giới thiệu '),
                          TextSpan(
                            text: 'Wagyu Burger',
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text:
                                ' - chiếc burger đẳng cấp với bò Wagyu hảo hạng, mềm tan, thơm ngậy, kết hợp với lớp phô mai béo mịn, sốt đặc biệt và bánh nướng vàng giòn. Mỗi miếng cắn là một trải nghiệm bùng nổ hương vị!',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      '💥 Có gì đặc biệt?',
                      style: TextStyle(
                        fontSize: normalFontsize,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                        '✅ Thịt bò Wagyu - Ngon mềm, thẩm vị, tan ngay đầu lưỡi',
                        style: TextStyle(fontSize: normalFontsize)),
                    Text(
                        '✅ Bánh nướng thủ công - Giòn ngoài, mềm trong, chuẩn vị gourmet',
                        style: TextStyle(fontSize: normalFontsize)),
                    Text(
                        '✅ Sốt đặc biệt - Hòa quyện hương vị, đưa burger lên một tầm cao mới',
                        style: TextStyle(fontSize: normalFontsize)),
                    SizedBox(height: screenHeight * 0.02),
                    Row(
                      children: [
                        Text(
                          '🔥 Giá chỉ: ',
                          style: TextStyle(fontSize: normalFontsize),
                        ),
                        Text(
                          '49.000đ',
                          style: TextStyle(
                            fontSize: normalFontsize,
                            color: Color(0xFFFD0000),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: normalFontsize),
                        children: [
                          TextSpan(
                            text:
                                '💥 Chiếc Burger "mới toe" này lên kệ từ ngày ',
                            style: TextStyle(
                                color:
                                    Colors.black), // Make sure to set the color
                          ),
                          TextSpan(
                            text: '01/01/2025',
                            style: TextStyle(
                              color: Color(0xFFFFC115),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      '🛵 Đặt ngay - Thưởng thức trước, phiền sau!',
                      style: TextStyle(fontSize: normalFontsize),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      '#WagyuBurger #NgonMềmTanChảy #SangXịnMịn',
                      style: TextStyle(
                        fontSize: normalFontsize,
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
