import 'package:demo_firebase/models/notify.dart';
import 'package:demo_firebase/screens/news/news_screen_2.dart';
import 'package:demo_firebase/widgets/custom_loading.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../../services/notification_service.dart';
import '../../widgets/notification_item.dart';
import '../news/news_screen_1.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    initial();
  }

  Future<void> initial() async {
    // Request notification permission
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Only proceed if permission is granted
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission.');

      String? fcmToken = await FirebaseMessaging.instance.getToken();

      if (fcmToken != null) {
        print('FCM Token: $fcmToken');
        await _notificationService.checkAndSaveFcmToken(fcmToken);
      }
    } else {
      print('User denied notification permission. Skipping FCM token save.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.only(top: 20.0),
          child: Text(
            "Thông báo",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 100,
      ),
      body: FutureBuilder<List<Notify>>(
        future: _notificationService.getNotifications(), // Fetch notifications
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CustomLoading(); // Loading state
          } else if (snapshot.hasError) {
            return Center(child: Text("${snapshot.error}")); // Error state
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text(
              "Chưa có thông báo",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            )); // Empty state
          }

          List<Notify> notifications = snapshot.data!;

          notifications.add(
            Notify(
              title: 'SANG XỊN MỊN -WAGYU BURGER CHÍNH THỨC LÊN SÓNG!',
              body:
                  'Chỉ từ 49.000đ/ người các bạn có thể thưởng thức Thịt bò Wagyu - Ngon mềm, thắm...',
              dateCreated: DateTime.now(),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => NewsScreen1())),
            ),
          );

          notifications.add(
            Notify(
              title: 'SINH NHẬT THẢ GA, ĐÊ CRUNCH & DASH LO NHA!!!',
              body:
                  'Chỉ từ 78.000đ/ bé tiệc vui sắn sàng cho cả nhà cùng vui sinh nhật!',
              dateCreated: DateTime.now(),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => NewsScreen2())),
            ),
          );

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  NotificationItem(notify: notifications[index]),
                  const Divider(
                      height: 5, thickness: 5, color: Color(0xFFEEEEEE)),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
