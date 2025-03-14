import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../../../data/sources/firebase_operations/firebase_service.dart';
import 'package:shelterstocks_prototype2/domain/models/notification/notification.dart';

class notificationData extends ChangeNotifier{
  final FirebaseService _firebaseService = FirebaseService(); // Reference to FirebaseService
  List<Notifications> _notifications = [];
  List<Notifications> get notifications {
    return List<Notifications>.from(_notifications);
  }

  int get notificationCount => _notifications.length;

  Future<void> addNewNotification(String uid, String notificationTitle, String notificationBody,DateTime notificationDateTime, String notificationIcon, bool isRead) async {
    final newNotification = Notifications(
        notificationTitle: notificationTitle,
      notificationBody: notificationBody,
      notificationDateTime: notificationDateTime,
      notificationIcon: notificationIcon,
      isRead: isRead
    );
    _notifications.insert(0, newNotification);  // Add to the beginning of the list
    notifyListeners();

    await _firebaseService.addToSubCollection(uid, 'Notifications', {
      'notificationTitle': notificationTitle,
      'notificationBody':notificationBody,
      'notificationDateTime':notificationDateTime,
      'notificationIcon':notificationIcon,
      'is read':isRead
    });
  }

  Future<bool> fetchNotification(String uid,String subCollection) async {
    try {
      List<Map<String, dynamic>> notificationList = await _firebaseService.fetchNotifFromSubCollection(uid, subCollection);
      _notifications = notificationList.map((data) => Notifications(
        notificationTitle: data['notificationTitle'],
        notificationBody: data['notificationBody'],
        notificationDateTime: (data['notificationDateTime']  as Timestamp).toDate(),
        notificationIcon: data['notificationIcon'],
        isRead: data['is read'],
        notificationId: data['id']
      )).toList();
      _notifications.sort((a, b) => b.notificationDateTime.compareTo(a.notificationDateTime));
      notifyListeners();
      return true;
    } catch (ex) {
      print('Error fetching Notifications: $ex');
      return false;
    }
  }

  Future<void> clearNotificationsOnLogout() async {
    _notifications.clear();
    notifyListeners();
  }

  Future<void> loadNotifications(String uid, String subCollection) async {
    bool success = await fetchNotification(uid, subCollection);
    if (success) {
      notifyListeners();  // Notify listeners after successfully fetching transactions
    } else {
      print('Failed to load Notifications.');
    }
  }

// Function to update the 'is read' field
  Future<void> updateIsReadStatus(Notifications notifs, String userId) async {
    try {
      // Try to update the notification's 'is read' field in Firestore
      await _firebaseService.updateNotificationField(
        userId: userId,
        notificationId: notifs.notificationId!, // Ensure notificationId is valid
        fieldName: 'is read',
        newValue: true,
      );

      // If the Firestore update is successful, update the local state
      notifs.isRead = true;
      print('Read status updated successfully');
      notifyListeners();  // Notify listeners

    } catch (e) {
      print('Unable to update read status: ${e.toString()}');
    }
  }

  // Function to check if there are unread notifications
  bool hasUnreadNotifications() {
    return _notifications.any((notification) => !(notification.isRead??false) );
  }


  Future<void> deleteNotification(Notifications notif,String userId, String notificationId) async {
    try {
      // Delete the notification from Firestore
      await _firebaseService.deleteFromSubCollection(
        userId,
        'Notifications',
        notificationId,
      );

      // Remove the notification from the local list
      _notifications.removeWhere((notification) => notification.notificationId == notificationId);

      // Notify listeners of the change
      notifyListeners();

      print('Notification deleted successfully');
    } catch (e) {
      print('Error deleting notification: ${e.toString()}');
      // You might want to rethrow the error or handle it in a way that's appropriate for your app
    }
  }

}