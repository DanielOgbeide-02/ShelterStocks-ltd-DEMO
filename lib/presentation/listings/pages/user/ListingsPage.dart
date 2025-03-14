import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shelterstocks_prototype2/common/helpers/NetworkChecker.dart';
import 'package:shelterstocks_prototype2/presentation/home/pages/user/HomeScreen.dart';

class Listingspage extends StatefulWidget {
  static String id = 'Listings_screen';

  const Listingspage({super.key});

  @override
  State<Listingspage> createState() => _ListingspageState();
}

class _ListingspageState extends State<Listingspage> {
  void _showDialog(){
    showDialog(
        context: context,
        builder: (context){
          return
            AlertDialog(
            title:
            Row(
              children: [
                Text(
                    'Coming Soon'
                ),
              ],
            ),
            content: Text(
                'We are working on this feature, please check back later!'
            ),
            actions: [
              MaterialButton(
                  onPressed: (){

              },
                child: Text('OK'),
              )
            ],

          );
        }
    );
  }
  @override
  Widget build(BuildContext context) {
    return
      AlertDialog(
        backgroundColor: Colors.white, // Change the background color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0), // Rounded corners
        ),
        title: Row(
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
          // TextButton(
          //   onPressed: () {
          //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomeScreen()));// Replace with your home route name
          //   },
          //   style: TextButton.styleFrom(
          //     backgroundColor: Colors.blue, // Change the button background color
          //   ),
          //   child: Text(
          //     'OK',
          //     style: TextStyle(
          //       color: Colors.white, // Change the button text color
          //     ),
          //   ),
          // ),
        ],
      );
      // Center(child: Text('Show dialog'));
  }
}
