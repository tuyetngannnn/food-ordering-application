import 'package:flutter/material.dart';

import '../models/notify.dart';

class NotificationItem extends StatelessWidget {
  final Notify notify;

  const NotificationItem({
    super.key,
    required this.notify,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: notify.onTap,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.notifications_none,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notify.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notify.body,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: Colors.black26,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}
