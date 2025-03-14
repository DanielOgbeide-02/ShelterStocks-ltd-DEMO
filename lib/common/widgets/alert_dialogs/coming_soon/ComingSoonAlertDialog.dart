import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../buttons/buttons.dart';

class comingSoonAlertdialog extends StatefulWidget {
  @override
  State<comingSoonAlertdialog> createState() => _Alertdialog();
}

class _Alertdialog extends State<comingSoonAlertdialog> {

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    // Check if the device is a tablet (adjust threshold as needed)
    bool isTablet = screenWidth > 600;
    return AlertDialog(
      title:
      Row(
        children: [
          Icon(FontAwesomeIcons.hourglassHalf, color: Colors.blue), // Add an icon
          SizedBox(width: 8),
          Text(
            'Coming Soon',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
              color: Colors.black, // Change the text color
            ),
          ),
        ],
      ),
      content: Text(
        'We are working on this feature, please check back later!',
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.grey[700], // Change the content text color
        ),
      ),

      actions: [
        Buttons(width: double.infinity, buttonText: 'OK', buttonColor: Color(0xFF1A1AFF), buttonTextColor: Colors.white, onPressed: (){
          Navigator.pop(context);
        },)
      ],
    );
  }
}