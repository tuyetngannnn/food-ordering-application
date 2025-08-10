import 'package:demo_firebase/services/cart_service.dart';
import 'package:demo_firebase/utils/utils.dart';
import 'package:demo_firebase/widgets/custom_app_bar.dart';
import 'package:demo_firebase/widgets/custom_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:demo_firebase/services/order_service.dart';

class FeedbackScreen extends StatefulWidget {
  final String orderId;

  const FeedbackScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  FeedbackScreenState createState() => FeedbackScreenState();
}

class FeedbackScreenState extends State<FeedbackScreen> {
  double _rating = 0;
  TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> _orderItems = [];
  bool _isLoading = true;
  bool _isRated = false;
  String? _errorMessage;
  late String _orderId;

  final OrderService _orderService = OrderService(CartService());

  @override
  void initState() {
    super.initState();
    _orderId = widget.orderId;
    _loadOrderItems();
  }

  Future<void> _loadOrderItems() async {
    try {
      final orderDetails = await _orderService.getOrderById(widget.orderId);
      final List<dynamic> cartItems = orderDetails['listCartItem'] ?? [];
      final ratedBar = orderDetails['ratedBar'] ?? 0;
      final processedItems = await _orderService.processOrderItems(cartItems);
      final comment = orderDetails['feedback'] ?? '';

      setState(() {
        _orderItems = processedItems;
        _isLoading = false;
        if (ratedBar > 0) {
          _isRated = true;
          _rating = ratedBar.toDouble();
          _commentController.text = comment;
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể tải đơn hàng: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _submitFeedback() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng chọn số sao đánh giá'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_isRated) return;
    try {
      await _orderService.addOrderRatingAndFeedback(
          widget.orderId, _rating, _commentController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã gửi đánh giá thành công')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Lỗi khi gửi đánh giá: ${e.toString()}'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to make the layout responsive
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (_isLoading) {
      return Scaffold(
        body: Center(child: CustomLoading()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Text(
            _errorMessage!,
            style: TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: customAppBar(context, "Đánh giá", showCart: false),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Đơn hàng của bạn',
                style: TextStyle(
                    fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: screenHeight * 0.01),
              // Responsive container for products
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: screenHeight * 0.4,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListView.separated(
                    padding: EdgeInsets.all(8),
                    physics: AlwaysScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _orderItems.length,
                    separatorBuilder: (context, index) => Divider(
                      color: Color.fromARGB(255, 242, 197, 197),
                      height: 1,
                      thickness: 1,
                    ),
                    itemBuilder: (context, index) =>
                        _buildItem(_orderItems[index]),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Center(
                child: Text(
                  'Bạn Cảm Thấy Thế Nào Về Đơn Hàng Này',
                  style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Center(
                child: RatingBar.builder(
                  initialRating: _rating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemSize: screenWidth * 0.1,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, index) => Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Color(0xFFFFD700), // Màu vàng
                  ),
                  unratedColor: Color(0xFFFFD700),
                  onRatingUpdate: _isRated
                      ? (_) {}
                      : (rating) {
                          setState(() {
                            _rating = (_rating == rating) ? 0 : rating;
                          });
                        },
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                'Hãy viết thêm nhận xét để giúp người dùng khác có thêm thông tin cho sự lựa chọn.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: screenWidth * 0.04),
              ),
              SizedBox(height: screenHeight * 0.02),
              TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Cảm nhận của bạn thế nào?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                minLines: 1,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                readOnly: _isRated,
              ),
              SizedBox(height: screenHeight * 0.03),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRated
                        ? Colors.grey
                        : const Color.fromARGB(255, 244, 48, 34),
                    padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.02,
                        horizontal: screenWidth * 0.1),
                    minimumSize: Size(double.infinity, screenHeight * 0.08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isRated ? null : _submitFeedback,
                  child: Text(
                    _isRated ? 'Đã Đánh Giá' : 'Đánh giá món ăn',
                    style: TextStyle(
                        color: Colors.white, fontSize: screenWidth * 0.05),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '${item['quantity']}x ',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          SizedBox(width: 7),
          Image.network(
            item['productImg'] ?? 'assets/placeholder.png',
            width: 100,
            height: 100,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/placeholder.png',
                width: 100,
                height: 100,
                fit: BoxFit.contain,
              );
            },
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['productName'] ?? 'Sản phẩm',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  item['sizeName'] ?? 'Standard',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                Text(
                  Utils().formatCurrency(item['price']),
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 17),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
