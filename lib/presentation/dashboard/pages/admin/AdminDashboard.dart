import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shelterstocks_prototype2/presentation/home/pages/admin/adminHomeScreen.dart';
import 'package:shelterstocks_prototype2/presentation/listings/pages/admin/adminListingsPage.dart';
import '../../../account/pages/admin/adminAccountPage.dart';


class Admindashboard extends StatefulWidget {
  static String id = 'adminDashBoard_screen';
  final int initialIndex;
  const Admindashboard({super.key,this.initialIndex = 0});

  @override
  State<Admindashboard> createState() => _AdmindashboardState();
}

class _AdmindashboardState extends State<Admindashboard>{
  //control screen tab
  int _currentIndex = 0;

  //use init state to run the fetchuserdata function
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _currentIndex = widget.initialIndex;
  }



  @override
  Widget build(BuildContext context) {
    List<Widget> body = [
      Adminhomescreen(),
      admin_listings_page(),
      // Listingspage(),
      Adminaccountpage()
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
                label: 'Home', icon: Icon(Icons.home)
            ),
            BottomNavigationBarItem(
                label: 'Listings', icon: Icon(Icons.menu)
            ),
            BottomNavigationBarItem(
                label: 'Account', icon: Icon(Icons.person)
            )
          ]
      ),
    );
  }

}



