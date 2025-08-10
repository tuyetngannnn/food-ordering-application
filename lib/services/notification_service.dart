import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/notify.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  Future<List<Notify>> getNotifications() async {
    try {
      // Fetch products by categoryId
      QuerySnapshot notificationSnapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('notifications')
          .get();

      List<Notify> notifications = notificationSnapshot.docs.map((doc) {
        return Notify.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();

      return notifications;
    } catch (e) {
      print("Error fetching notifications: $e");
      return [];
    }
  }

  Future<void> checkAndSaveFcmToken(String newToken) async {
    final user = _auth.currentUser;
    if (user == null) return;

    String userId = user.uid;
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(userId);

    DocumentSnapshot userDoc = await userRef.get();

    if (userDoc.exists) {
      Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;

      String? storedToken = data?['fcmToken'];

      // Only update Firestore if the token is new or changed
      if (storedToken == null || storedToken != newToken) {
        await userRef.set({
          'fcmToken': newToken,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } else {
      // If user document does not exist, create it
      await userRef.set({
        'fcmToken': newToken,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
