import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../widgets/custom_app_bar.dart';

class PolicyScreen extends StatelessWidget {
  const PolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final double normalFontsize = 14;
    final double bigFontSize = 24;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: customAppBar(context , 'Chính sách'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Content
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'A. CHÍNH SÁCH VẬN CHUYỂN, GIAO HÀNG, THANH TOÁN',
                      style: TextStyle(
                        fontSize: normalFontsize + 2,
                        // fontWeight: FontWeight.bold,
                        color: Color(0xFFFD0000),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      '1. Hình thức mua hàng',
                      style: TextStyle(
                        fontSize: normalFontsize + 2,
                        // fontWeight: FontWeight.bold,
                        color: Color(0xFFFD0000),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "• ",
                          style: TextStyle(
                            fontSize: normalFontsize,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Khách hàng đến trực tiếp cửa hàng để mua hàng.',
                            style: TextStyle(
                              fontSize: normalFontsize,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "• ",
                          style: TextStyle(
                            fontSize: normalFontsize,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Khách hàng đặt hàng qua số Hotline 123 456 789 và cửa hàng sẽ giao hàng đến địa chỉ khách yêu cầu trong đơn hàng.',
                            style: TextStyle(
                              fontSize: normalFontsize,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "• ",
                          style: TextStyle(
                            fontSize: normalFontsize
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Khách hàng đặt hàng trực tuyến qua Website www.crunch&dash.vn. Ứng dụng CRUNCH&DASH và cửa hàng sẽ giao hàng đến địa chỉ khách yêu cầu trong đơn hàng.',
                            style: TextStyle(
                              fontSize: normalFontsize,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      '2. Giao hàng',
                      style: TextStyle(
                        fontSize: normalFontsize + 2,
                        // fontWeight: FontWeight.bold,
                        color: Color(0xFFFD0000),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "• ",
                          style: TextStyle(
                            fontSize: normalFontsize,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Miễn phí giao hàng cho đơn hàng có giá trị từ 150,000đ trở lên và trong phạm vi bán kính giao hàng của từng cửa hàng.',
                            style: TextStyle(
                              fontSize: normalFontsize,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "• ",
                          style: TextStyle(
                            fontSize: normalFontsize,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Đảm bảo giao hàng trong vòng 30 phút trong khu vực giao hàng.',
                            style: TextStyle(
                              fontSize: normalFontsize,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "• ",
                          style: TextStyle(
                              fontSize: normalFontsize
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Thời gian hoạt động: 10h00 – 22h00 mỗi ngày (Thời gian đặt hàng: 0h00 - 21h30).',
                            style: TextStyle(
                              fontSize: normalFontsize,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      '3. Phương thức thanh toán cho giao hàng',
                      style: TextStyle(
                        fontSize: normalFontsize + 2,
                        // fontWeight: FontWeight.bold,
                        color: Color(0xFFFD0000),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "• ",
                          style: TextStyle(
                            fontSize: normalFontsize,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Nhân viên cửa hàng sẽ đến giao hàng và nhận tiền mặt trực tiếp từ khách hàng, hoặc khách hàng thao tác quét mã QRCode chuyển khoản thanh toán theo đơn hàng đã đặt trên Website & Ứng dụng của CRUNCH&DASH hoặc Hotline 123 456 789.',
                            style: TextStyle(
                              fontSize: normalFontsize,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "• ",
                          style: TextStyle(
                            fontSize: normalFontsize,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Khách hàng thao tác thanh toán qua thẻ ATM, thẻ tín dụng/ghi nợ, Ví MoMo, ZaloPay.',
                            style: TextStyle(
                              fontSize: normalFontsize,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      'B. CHÍNH SÁCH ĐIỀU CHỈNH NỘI DUNG ĐƠN HÀNG',
                      style: TextStyle(
                        fontSize: normalFontsize + 2,
                        // fontWeight: FontWeight.bold,
                        color: Color(0xFFFD0000),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      'Sau khi hoàn tất việc đặt hàng trên Website & Ứng dụng của CRUNCH&DASH, vui lòng gọi Hotline 123 456 789 trong thời gian sớm nhất có thể để được hỗ trợ kiểm tra trạng thái đơn hàng và điều chỉnh thông tin nếu đơn hàng chưa được cửa hàng thực hiện. Khách hàng sẽ không thể điều chỉnh, thay đổi sản phẩm trong đơn hàng nếu đơn hàng đã và đang được thực hiện bởi cửa hàng.',
                      style: TextStyle(
                        fontSize: normalFontsize,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      'C. CHÍNH SÁCH BẢO MẬT',
                      style: TextStyle(
                        fontSize: normalFontsize + 2,
                        // fontWeight: FontWeight.bold,
                        color: Color(0xFFFD0000),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      'CRUNCH & DASH công nhận và tôn trọng thông tin bảo mật của các cá nhân đăng nhập vào Website & Ứng dụng của CRUNCH & DASH. CRUNCH & DASH cam kết sẽ bảo mật những thông tin mang tính riêng tư của khách hàng. Quý khách hàng vui lòng đọc bản “Chính sách bảo mật” dưới đây để hiểu hơn những cam kết mà chúng tôi thực hiện.\n\nCRUNCH & DASH có thể điều chỉnh chính sách bảo mật này bất cứ khi nào chúng tôi thấy cần thiết, vì vậy vui lòng đăng nhập vào Website & Ứng dụng của CRUNCH & DASH thường xuyên để cập nhật thông tin mới.',
                      style: TextStyle(
                        fontSize: normalFontsize,
                      ),
                      textAlign: TextAlign.justify,
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
