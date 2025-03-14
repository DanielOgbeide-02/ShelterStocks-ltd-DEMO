import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shelterstocks_prototype2/common/helpers/functions/getScale.dart';
import 'package:shelterstocks_prototype2/domain/models/notification/notification.dart';
import 'package:shelterstocks_prototype2/presentation/provider/notification/notificationData.dart';

import '../../../../../provider/user/userData.dart';

class Notificationscreen extends StatefulWidget {
  static String id = 'notification_screen';
  const Notificationscreen({super.key});

  @override
  State<Notificationscreen> createState() => _NotificationscreenState();
}

class _NotificationscreenState extends State<Notificationscreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final _userData = Provider.of<UserData>(context,listen: false);
    final _notificationData = Provider.of<notificationData>(context, listen: false);
    _notificationData.loadNotifications(_userData.currentUser!.userId!, 'Notifications');
  }

  bool isRead = false;
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    // Check if the device is a tablet (adjust threshold as needed)
    bool isTablet = screenWidth > 600;
    bool isSmallPhone = screenWidth < 413 && screenHeight<800;
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Color(0xFF1A1AFF),
        iconTheme: IconThemeData(
          color: Colors.white
        ),
      ),
      body: Consumer<notificationData>(
        builder: (context,notificationData,child){
          final _userData = Provider.of<UserData>(context,listen: false);
          final notificationCount = notificationData.notificationCount;
          //watch out
          notificationData.loadNotifications(_userData.currentUser!.userId!, 'Notifications');
          return
            notificationCount>=1?  Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0))
              ),
              child:
              ListView.builder(
                itemCount: notificationData.notifications.length,
                  itemBuilder: (context, index){
                    final eachNotification = notificationData.notifications[index];
                    final _userData = Provider.of<UserData>(context,listen: false);
                    // Function to show the confirmation dialog
                    Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
                      return showDialog<void>(
                        context: context,
                        barrierDismissible: false, // User must tap a button
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            title: Text('Confirm Delete'),
                            content: Text('Are you sure you want to delete this notification?'),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(dialogContext).pop(); // Dismiss the dialog
                                },
                              ),
                              TextButton(
                                child: Text('Delete'),
                                onPressed: () async{
                                  // Call your delete function here
                                  await notificationData.deleteNotification(eachNotification, _userData.currentUser!.userId!, eachNotification.notificationId!);
                                  Navigator.of(dialogContext).pop(); // Dismiss the dialog
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }

                    return GestureDetector(
                      onTap: ()async{
                        await notificationData.updateIsReadStatus(eachNotification, _userData.currentUser!.userId!);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(width: 1, color: Colors.grey.shade300)
                            )
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: isTablet?15*getScale(context):(isSmallPhone?20*getScale(context):(25*getScale(context))),
                              backgroundColor: Colors.blue.shade300,
                              child: Icon(
                                  (eachNotification.notificationIcon == 'account_balance_wallet')?Icons.account_balance_wallet:Icons.notifications,

                              ),
                            ),
                            SizedBox(
                              width: isSmallPhone?7*getScale(context):(8*getScale(context)),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(eachNotification.notificationTitle!,style: TextStyle(
                                    fontSize: isTablet?11*getScale(context):(15*getScale(context)),
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w700,
                                  ),),
                                  Text(eachNotification.notificationBody!,style: TextStyle(
                                      fontSize: isTablet?10*getScale(context):(13*getScale(context)),
                                      color: Colors.grey,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w500,
                                  ),),
                                  SizedBox(height: 4 * getScale(context)),  // Add some space
                                  Text(
                                    eachNotification.formattedDateTime,  // Use the new getter
                                    style: TextStyle(
                                      fontSize: isTablet?10*getScale(context):(12 * getScale(context)),
                                      color: Colors.grey.shade700,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 5*getScale(context),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if(eachNotification.isRead! == false)
                                  Icon(
                                    Icons.fiber_manual_record,
                                    size: isTablet?15*getScale(context):(isSmallPhone?15*getScale(context):(20*getScale(context))),
                                    color: Color(0xFF1A1AFF),
                                  ),
                                SizedBox(height: 10*getScale(context),),
                                IconButton(
                                  icon: Icon(Icons.delete, size: isTablet?15*getScale(context):(isSmallPhone?20*getScale(context):(25*getScale(context))),),
                                  onPressed: () {
                                    _showDeleteConfirmationDialog(context);
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );

                  }
              )
            ):_buildEmptyState(context);
        }
      ),
    );
  }
  Widget _buildEmptyState(BuildContext context) {
    return Center(child: Text('You don\'t have any notifications.', style: TextStyle(color: Colors.red)));
  }

}
