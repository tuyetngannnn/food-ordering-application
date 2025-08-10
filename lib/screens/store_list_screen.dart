import 'package:flutter/material.dart';

class StoreListScreen extends StatelessWidget {
  final List<Map<String, String>> stores = [
    {
      'name': 'CRUNCH & DASH - Sư Vạn Hạnh',
      'address': '828 Sư Vạn Hạnh, Phường 12, Quận 10, TP Hồ Chí Minh',
      'hours': '09:00 - 22:00',
      'phone': '123456789'
    },
    {
      'name': 'CRUNCH & DASH - Trường Sơn',
      'address': '32 Trường Sơn, Phường 2, Tân Bình, TP Hồ Chí Minh',
      'hours': '09:00 - 22:00',
      'phone': '123456789'
    },
    {
      'name': 'CRUNCH & DASH - Ba Gia',
      'address': '52 Ba Gia, Phường 7, Tân Bình, TP Hồ Chí Minh',
      'hours': '09:00 - 22:00',
      'phone': '123456789'
    },
    {
      'name': 'CRUNCH & DASH - Hóc Môn',
      'address': '806 QL22, ấp Mỹ Hoà 3, Hóc Môn, TP Hồ Chí Minh',
      'hours': '09:00 - 22:00',
      'phone': '123456789'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Danh sách cửa hàng',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
                color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        itemCount: stores.length,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          final store = stores[index];
          return Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
                side: BorderSide(
                    color: const Color.fromARGB(255, 243, 214, 217),
                    width: 1.3)),
            margin: EdgeInsets.symmetric(),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            store['name']!,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: EdgeInsets.only(left: 15),
                          child: Text(store['address']!,
                              style: TextStyle(
                                  color: Colors.grey[700], fontSize: 16)),
                        ),
                        SizedBox(height: 8),
                        Padding(
                          padding: EdgeInsets.only(left: 15),
                          child: Text('Liên hệ cửa hàng: ${store['phone']}',
                              style: TextStyle(
                                  color: Colors.grey[700], fontSize: 16)),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: 50), // Điều chỉnh khoảng cách ảnh xuống dưới
                    child: Image.asset(
                      'assets/storelist.png',
                      width: 90,
                      height: 90,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
