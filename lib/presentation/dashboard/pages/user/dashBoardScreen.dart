import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shelterstocks_prototype2/common/helpers/functions/getScale.dart';
import 'package:shelterstocks_prototype2/common/widgets/buttons/buttons.dart';
import 'package:shelterstocks_prototype2/common/widgets/flush_bar/Flushbar.dart';
import 'package:shelterstocks_prototype2/presentation/account/pages/user/AccountPage.dart';
import 'package:shelterstocks_prototype2/presentation/listings/pages/user/ListingsPage.dart';

import '../../../../data/api/firebase_messaging/firebaseApi.dart';
import '../../../home/pages/user/HomeScreen.dart';


class DashboardScreen extends StatefulWidget {
  static String id = 'dashBoard_screen';
  final int initialIndex;
  const DashboardScreen({super.key,this.initialIndex = 0});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>{
  //control screen tab
  int _currentIndex = 0;

  //use init state to run the fetchuserdata function
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _currentIndex = widget.initialIndex;
    // FirebaseApi().setupForegroundNotificationListener();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    FirebaseApi().setupForegroundNotificationListener();
  }


  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    // Check if the device is a tablet (adjust threshold as needed)
    bool isTablet = screenWidth > 600;
    bool isSmallPhone = screenWidth < 413 && screenHeight<733;
    List<Widget> body = [
      HomeScreen(),
      Listingspage(),
      accountPage(),
    ];
    return Scaffold(
    backgroundColor: Color(0xFF1A1AFF),
      body:
      body[_currentIndex],
      //navigation bar
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
          backgroundColor: Color(0xFF1A1AFF),
          currentIndex: _currentIndex,
          onTap: (int newIndex){
            setState(() {
              _currentIndex = newIndex;
            });
          },
          items:[
            BottomNavigationBarItem(
                label: 'Home', icon: Icon(
                Icons.home,
              size: isTablet?20*getScale(context):(isSmallPhone?22*getScale(context):30*getScale(context)),
            )
            ),
            BottomNavigationBarItem(
                label: 'Listings', icon: Icon(Icons.menu,size:  isTablet?20*getScale(context):(isSmallPhone?22*getScale(context):30*getScale(context)),)
            ),
            BottomNavigationBarItem(
                label: 'Account', icon: Icon(Icons.person,size:  isTablet?20*getScale(context):(isSmallPhone?22*getScale(context):30*getScale(context)),)
            )
          ]
      ),
    );
  }

}



