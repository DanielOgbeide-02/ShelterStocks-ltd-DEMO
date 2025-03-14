import 'package:flutter/material.dart';

import '../../helpers/functions/getScale.dart';

class NotificationIconWithDot extends StatefulWidget {
  final bool hasUnreadNotifications;

  NotificationIconWithDot({required this.hasUnreadNotifications});

  @override
  State<NotificationIconWithDot> createState() => _NotificationIconWithDotState();
}

class _NotificationIconWithDotState extends State<NotificationIconWithDot> {
  @override
  Widget build(BuildContext context) {
    // print(userProvider.currentUser.userId);
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    // Check if the device is a tablet (adjust threshold as needed)
    bool isTablet = screenWidth > 600;
    bool isSmallPhone = screenWidth < 413 && screenHeight<800;
    return Stack(
      children: [
        Icon(
          Icons.notifications, // Base notification icon
          size: isSmallPhone?25*getScale(context):(isTablet?20*getScale(context):30*getScale(context)),
          color: Colors.white, // Adjust color as needed
        ),
        if (widget.hasUnreadNotifications)
          Positioned(
            top: 2.0, // Position of the dot
            right: 2.0, // Adjust as needed
            child: Container(
              width: 10.0, // Dot size
              height: 10.0,
              decoration: BoxDecoration(
                color: Colors.red, // Dot color
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
