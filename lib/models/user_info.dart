import 'package:cloud_firestore/cloud_firestore.dart';

class AccountInfo {
  final String userId;
  final String name;
  final String phone;
  final List<String> couponIds;
  final String fcmToken;
  final DateTime updatedAt;

  AccountInfo({
    required this.userId,
    required this.name,
    required this.phone,
    required this.couponIds,
    required this.fcmToken,
    required this.updatedAt,
  });

  factory AccountInfo.fromJson(Map<String, dynamic> json) {
    return AccountInfo(
      userId: json['uid'] ?? '',
      name: json['name'] ?? 'Khách hàng',
      phone: json['phone'] ?? 'Không tìm thấy',
      couponIds: (json['couponId'] != null && json['couponId'] is List)
          ? List<String>.from(json['couponId'])
          : [],
      fcmToken: json['fcmToken'] ?? '',
      updatedAt: (json['updatedAt'] != null && json['updatedAt'] is Timestamp)
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'uid': userId,
      'name': name,
      'phone': phone,
      'couponId': couponIds,
      'fcmToken': fcmToken,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
