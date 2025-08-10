import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../widgets/custom_app_bar.dart';

class NewsScreen2 extends StatelessWidget {
  const NewsScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final double normalFontsize = 14;
    final double bigFontSize = 20;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: customAppBar(
          context, 'SINH NHẬT THÊM BÁNH, BÉ YÊU THÊM VUI – GIÁ CHỈ TỪ 78K/BÉ',
          showCart: false),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner
              Image.asset('assets/news_banner_2.jpg', fit: BoxFit.fitWidth),

              // Main Content
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tiệc Sinh Nhật Vui Hết Nấc Cho Bé!',
                      style: TextStyle(
                        fontSize: normalFontsize + 2,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF354070),
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
                        children: [
                          const TextSpan(
                            text: 'Crunch & Dash ',
                            style: TextStyle(
                                color: Color(0xFFFD0000),
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                              text:
                                  'chính thức mang đến bữa tiệc sinh nhật trọn vẹn '
                                  'niềm vui với giá chỉ từ 78K! Hãy cùng bé tận '
                                  'hưởng những combo tiệc siêu ngon, siêu hấp dẫn:'),
                        ],
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
                        children: [
                          const TextSpan(
                            text: '🍗 Crunch Party 78K',
                            style: TextStyle(color: Color(0xFF4CB124)),
                          ),
                          TextSpan(
                              text:
                                  ': Gà rán + Khoai tây chiên (M) + Kem cây + Nước ngọt (M)'),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: normalFontsize,
                          color: Colors.black,
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(
                            text: '🍔 Dash Party 78K',
                            style: TextStyle(color: Color(0xFF385CF9)),
                          ),
                          TextSpan(
                              text:
                                  ': Burger Bulgogi/Burger Tôm + Phô mai que + Kem cây + Nước ngọt (M)'),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: normalFontsize,
                          color: Colors.black,
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(
                            text: '🍝 Crunchy Fun 97K',
                            style: TextStyle(color: Color(0xFFECA21A)),
                          ),
                          TextSpan(
                              text:
                                  ': Gà rán + Mì Ý + Khoai tây chiên (M) + Kem cây + Nước ngọt (M)'),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: normalFontsize,
                          color: Colors.black,
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(
                            text: '👑 Party King 123K',
                            style: TextStyle(color: Color(0xFFFC25BF)),
                          ),
                          TextSpan(
                              text:
                                  ': Gà rán + Mì Ý thịt bò + Phô mai que + Kem ly + Nước ngọt (M)'),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: normalFontsize,
                          color: Colors.black,
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(
                            text: '🎈 MIỄN PHÍ trang trí set up tiệc',
                            style: TextStyle(color: Color(0xFFFFC115)),
                          ),
                          TextSpan(
                              text: ' với bóng bay rực rỡ cùng biệt đội C&D'),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      '🎂 Tặng nón và thiệp sinh nhật cho bé khi đặt tiệc tại Crunch & Dash',
                      style: TextStyle(
                        fontSize: normalFontsize,
                        color: Colors.black,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      '🔥 Thêm một chút ngọt ngào cho buổi tiệc! 🔥\nNhững chiếc bánh kem siêu xinh với mức giá KHÔNG THỂ HẤP DẪN HƠN:',
                      style: TextStyle(
                        fontSize: normalFontsize,
                        color: Colors.black,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: normalFontsize,
                          color: Colors.black,
                          height: 1.5,
                        ),
                        children: [
                          TextSpan(text: '🦄 Unicorn Rainbow Fresh - '),
                          TextSpan(
                            text: '450K',
                            style: TextStyle(color: Color(0xFF96D17F)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: normalFontsize,
                          color: Colors.black,
                          height: 1.5,
                        ),
                        children: [
                          TextSpan(text: '🍊 Delighted Orange Fresh - '),
                          TextSpan(
                            text: '430K',
                            style: TextStyle(color: Color(0xFF385CF9)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: normalFontsize,
                          color: Colors.black,
                          height: 1.5,
                        ),
                        children: [
                          TextSpan(text: '🍪 Cookie Cheese Mousse - '),
                          TextSpan(
                            text: '430K',
                            style: TextStyle(color: Color(0xFFECA21A)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: normalFontsize,
                          color: Colors.black,
                          height: 1.5,
                        ),
                        children: [
                          TextSpan(text: '🧸 Teddy Bear - Party Time Cake - '),
                          TextSpan(
                            text: '430K',
                            style: TextStyle(color: Color(0xFFFC25BF)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      '#CrunchDashParty 🎉 #VuiHếtNấc 🎂 #TiệcSiêuXịn #SinhNhậtBéYêu🎈',
                      style: TextStyle(
                        fontSize: normalFontsize,
                        color: Colors.black,
                        height: 1.5,
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
