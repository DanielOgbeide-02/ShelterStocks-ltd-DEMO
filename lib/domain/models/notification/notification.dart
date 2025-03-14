import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class Notifications{
  final String? notificationTitle;
  final String? notificationBody;
  final DateTime notificationDateTime;
  final String? notificationIcon;
  bool? isRead;
  final String? notificationId;

  Notifications({required this.notificationTitle, required this.notificationBody, required this.notificationDateTime, this.notificationIcon, this.isRead, this.notificationId}){}
  String get notificationDate => DateFormat('MMMM dd, yyyy').format(notificationDateTime);
  String get notificationTime => DateFormat('HH:mm:ss').format(notificationDateTime);

  String get formattedDateTime {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final notifDate = DateTime(notificationDateTime.year, notificationDateTime.month, notificationDateTime.day);

    if (notifDate == today) {
      return 'Today, ${notificationTime}';
    } else if (notifDate == yesterday) {
      return 'Yesterday, ${notificationTime}';
    } else {
      return '${DateFormat('MMM d').format(notificationDateTime)}, ${notificationTime}';
    }
  }
}