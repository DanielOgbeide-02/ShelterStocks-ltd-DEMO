import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:shelterstocks_prototype2/common/widgets/buttons/buttons.dart';
import 'package:shelterstocks_prototype2/common/widgets/buttons/goBackBtn.dart';
import 'package:shelterstocks_prototype2/presentation/provider/admin/adminData.dart';
import 'package:shelterstocks_prototype2/presentation/profile/pages/admin/editAdminProfilePage.dart';

import '../../../../common/helpers/functions/getScale.dart';
import '../../../../common/widgets/profile_components/userProfileItem.dart';
import '../../../provider/profile/user_profile/profileData.dart';
import '../../../provider/user/userData.dart';



class Adminprofilepage extends StatefulWidget {
  static String id = 'adminProfilePage_screen';
  const Adminprofilepage({super.key});

  @override
  State<Adminprofilepage> createState() => _AdminprofilepageState();
}

class _AdminprofilepageState extends State<Adminprofilepage> with WidgetsBindingObserver{
  late final userProvider;
  late final userProfileProvider;
  bool showSpinner = true;
  bool isloading = false;
  bool isConnectedToInternet = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userProvider  = Provider.of<UserData>(context, listen: false);
    userProfileProvider  = Provider.of<profileData>(context, listen: false);
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  Future<void> _loadData() async {
    await userProvider.loadUserData();
    await userProfileProvider.loadUserProfileData();
    setState(() {
      showSpinner = false; // Hide spinner after data is loaded
    });
  }
  StreamSubscription? _internetConnectionStreamSubscription;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _loadData();
    _checkInternetConnection();
    _internetConnectionStreamSubscription = InternetConnectionCheckerPlus().onStatusChange.listen((status) {
      setState(() {
        isConnectedToInternet = status == InternetConnectionStatus.connected;
        if(isConnectedToInternet == false){
          showInternetLostSnackbar();
        }
      });
    });
  }
  Future<void> _checkInternetConnection() async {
    final internetConnectionStatus = await InternetConnectionCheckerPlus().connectionStatus;
    setState(() {
      isConnectedToInternet = internetConnectionStatus == InternetConnectionStatus.connected;
      print('Is connected o: ${isConnectedToInternet}');
      if(isConnectedToInternet == false){
        showInternetLostSnackbar();
      }
    });
  }
  void showInternetLostSnackbar() {
    Get.snackbar(
      "Connection Lost",  // Title of the snackbar
      "You have lost connection to the internet.",  // Message of the snackbar
      snackPosition: SnackPosition.TOP,  // Snackbar appears at the bottom
      backgroundColor: Colors.red,  // Red background color
      colorText: Colors.white,  // White text color
      margin: EdgeInsets.all(16),  // Add some margin for modern look
      borderRadius: 10,  // Rounded corners
      icon: Icon(
        Icons.wifi_off,  // Icon indicating no connection
        color: Colors.white,
      ),
      snackStyle: SnackStyle.FLOATING,  // Floating snackbar for a modern look
      duration: Duration(seconds: 3),  // Duration before it disappears
      isDismissible: true,  // Allow user to swipe it away
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async{
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _internetConnectionStreamSubscription?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    bool isTablet = screenWidth > 600;
    bool isSmallPhone = screenWidth < 413 && screenHeight<733;
    if(showSpinner){
      return Center(
        child: CircularProgressIndicator(color: Colors.white,),
      );
    }
    return ModalProgressHUD(
      inAsyncCall: isloading,
      progressIndicator: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(
                height: isSmallPhone?10*getScale(context):(15.h),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Please wait...',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.black, // Change the text color
                    ),
                  ),
                  SizedBox(width: 5.w),
                  Icon(FontAwesomeIcons.hourglassHalf, color: Colors.blue), // Add an icon
                ],
              ),
            ],
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          top: true,
          child:
          Container(
            margin: EdgeInsets.only(top: isTablet?18*getScale(context):(isSmallPhone?20.0*getScale(context):30.0*getScale(context)),left: 20.0*getScale(context), right: 20.0*getScale(context)),
            // margin: const EdgeInsets.only(top: 30.0,left: 20.0, right: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                goBackBtn(size:  isTablet?20*getScale(context):(isSmallPhone?20*getScale(context):25*getScale(context)),),
                // goBackBtn(size: 25,),
                SizedBox(
                  height: isTablet?15*getScale(context):(isSmallPhone?15*getScale(context):(20.h)),
                  // height: 20.h,
                ),
                Text(
                    'ADMINISTRATOR PROFILE',
                  style: TextStyle(
                      fontSize: isTablet?12*getScale(context):(isSmallPhone?20*getScale(context):(20.sp)),
                    fontWeight: FontWeight.bold
                  ),
                ),

               //here
                Flexible(child: ListView(
                  children: [
                Container(
                padding: EdgeInsets.only(top: isTablet?20*getScale(context):(20.sp), bottom: isTablet?12*getScale(context):(20.sp)),
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: CupertinoColors.activeBlue, width: 2)
                      )
                  ),
                  child:
                  Consumer<Admindata>(
                    builder: (context, adminData, child) {
                      return
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ADMIN ID',
                              style: TextStyle(
                                  fontSize: isTablet?10*getScale(context):(14*getScale(context)),
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                            Text(adminData.currentAdmin!.adminId!, style: TextStyle(
                              fontSize: isTablet?10*getScale(context):10*getScale(context),
                              color: Colors.grey
                            ),)
                          ],
                        );
                    }
                  ),
                ),

                    Consumer<Admindata>(
                        builder: (context, adminData, child) {
                          return
                            userProfileItem(
                              profileItemHeader: 'ADMIN EMAIL',
                              profileItem: Text(
                                '${adminData.currentAdmin?.email}',
                                style: TextStyle(
                                    fontSize: isTablet?10*getScale(context):(14*getScale(context)),
                                    color: Colors.grey
                                ),
                              ),
                            );
                        }
                    ),
                    SizedBox(
                      height: 35.h,
                    ),
                    Buttons(width: double.infinity, buttonText: 'Edit Profile', buttonTextColor: Colors.white, buttonColor: Color(0xFF1A1AFF), onPressed: ()async{
                      if(isConnectedToInternet){
                        setState(() {
                          isloading = true;
                        });
                        Future.delayed(Duration(seconds: 3), (){
                          Navigator.pushNamed(context, Editadminprofilepage.id).then((_){
                            setState(() {
                              isloading = false;
                            });
                          }
                          );
                        });
                      }
                      else{
                        showInternetLostSnackbar();
                      }
                    },),
                  ],
                ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

