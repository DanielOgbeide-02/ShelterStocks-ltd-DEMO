import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shelterstocks_prototype2/main.dart';
import 'package:shelterstocks_prototype2/presentation/dashboard/pages/user/dashBoardScreen.dart';
import 'package:shelterstocks_prototype2/presentation/account/pages/user/settings/AccountSettings.dart';
import 'package:shelterstocks_prototype2/presentation/account/pages/user/settings/notification/notificationScreen.dart';
import 'package:shelterstocks_prototype2/presentation/home/pages/user/HomeScreen.dart';

class FirebaseApi{
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;


  //notification start
  Future<void> initNotifications() async{
    //request permission from user
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    //fetch FCM token for this device
    final fCMToken = await _firebaseMessaging.getToken();
    //print the token
    print('user token: ${fCMToken}');
    initPushNotifications();
  }

  void setupNotificationTapListener(RemoteMessage? message) {
    if (message == null) {
      print('Notification clicked, but message is null');
      return;
    }

    print('Notification clicked: ${message.data}');

    // Navigate to a specific screen based on the notification data
    if (message.data.isNotEmpty) {
      navigatorKey.currentState?.pushNamed(
          Notificationscreen.id,
          arguments: message.data
      );
    } else {
      print('Notification data is empty');
    }
  }

  Future initPushNotifications()async{
    //handle notification if the app was terminated and now opened
    FirebaseMessaging.instance.getInitialMessage().then(setupNotificationTapListener);
    //attach event listeners for when a notification opens the app
    FirebaseMessaging.onMessageOpenedApp.listen(setupNotificationTapListener);
  }

  void setupForegroundNotificationListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async{
      // print('Received a foreground notification: ${message.notification!.title}');

      if (message.notification != null) {
        String title = message.notification?.title ?? 'No Title';
        String body = message.notification?.body ?? 'No Body';
        final prefs = await SharedPreferences.getInstance();
        bool? isAdmin = prefs.getBool('isAdmin')??false;
        // Show a snackbar or update UI based on notification
        if(!isAdmin!){
          print('forground notif: ${message.notification!.title}');
          Get.snackbar(
            title, // Notification title
            body,  // Notification body
            snackPosition: SnackPosition.TOP,
            duration: Duration(seconds: 3),
            backgroundColor: Color(0xFF1A1AFF),
            backgroundGradient: LinearGradient(
              colors: [Color(0xFF1A1AFF), Colors.white],
            ),
            boxShadows:  [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(2, 2),
                blurRadius: 8,
              )
            ],
            snackStyle: SnackStyle.FLOATING,
            colorText: Colors.white,
            icon: Icon(Icons.notification_important, color: Colors.white),
          );
        }
        else{
          print('Admin notification received but not displayed: $title');
        }
      }
    });
  }

  Future<void> firebaseBackgroundMessageHandler(RemoteMessage message) async {
    print("Handling a background message: ${message.messageId}");

    // Example: Save notification data to local storage or Firestore
    if (message.notification != null) {
      //attach event listeners for when a notification opens the app
      print('Notification title: ${message.notification!.title}');
      // Save the notification data to the database or show in-app notification
    }
  }

  Future<String> getFCMToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        return token;
      } else {
        return 'No token found';
      }
    } catch (e) {
      // Log the error or handle the exception appropriately
      print('Error fetching FCM token: $e');
      return 'Error retrieving token';
    }
  }
}