import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:shelterstocks_prototype2/common/widgets/flush_bar/Flushbar.dart';
import 'package:shelterstocks_prototype2/common/widgets/buttons/buttons.dart';
import 'package:shelterstocks_prototype2/common/helpers/NetworkChecker.dart';
import 'package:shelterstocks_prototype2/common/widgets/buttons/goBackBtn.dart';
import 'package:shelterstocks_prototype2/common/widgets/profile_components/profilePicture.dart';
import 'package:shelterstocks_prototype2/presentation/profile/pages/user/editProfilePage.dart';

import '../../../../common/helpers/functions/getScale.dart';
import '../../../../common/widgets/profile_components/userProfileItem.dart';
import '../../../provider/profile/user_profile/profileData.dart';
import '../../../provider/user/userData.dart';
import '../../../provider/firebase/firebaseData.dart';
import '../../../auth/pages/user/loginScreen.dart';
import 'package:shelterstocks_prototype2/common/helpers/functions/getScale.dart';



class profilePage extends StatefulWidget {
  static String id = 'profilePage_screen';
  const profilePage({super.key});

  @override
  State<profilePage> createState() => _profilePageState();
}

class _profilePageState extends State<profilePage> with WidgetsBindingObserver{
  late final userProvider;
  late final userProfileProvider;
  bool showSpinner = true;
  bool isloading = false;
  bool isConnectedToInternet = false;
  final TextEditingController userIdController = TextEditingController();

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
    String profileImageUrl = userProfileProvider.currentUserProfile?.profilePictureUrl;
    userIdController.text = '${userProvider.currentUser?.userId}';
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
            margin: EdgeInsets.only(top: isSmallPhone?20.0*getScale(context):30.0*getScale(context),left: 20.0*getScale(context), right: 20.0*getScale(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              goBackBtn(size:  isTablet?20*getScale(context):(isSmallPhone?20*getScale(context):(25*getScale(context))),),
                SizedBox(
                  height:isSmallPhone?15*getScale(context):(20.h),
                ),
                Text(
                    'MY PROFILE',
                  style: TextStyle(
                    fontSize: isTablet?12*getScale(context):(isSmallPhone?20*getScale(context):(20.sp)),
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w900,
                  ),
                ),

               //here
                Flexible(child: ListView(
                  children: [
                    userProfileItem(
                      profileItemHeader: 'DISPLAY PICTURE',
                      profileItem:isConnectedToInternet?
                      Container(
                          width: isTablet?40*getScale(context):(isSmallPhone?55*getScale(context):(60.0.w)),
                          height: isTablet?40*getScale(context):(isSmallPhone?55*getScale(context):(60.0.h)),
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                              color: Color(0xFF1A1AFF),
                              shape: BoxShape.circle,
                              image: profileImageUrl.isNotEmpty ? DecorationImage(
                                image: NetworkImage(profileImageUrl), fit: BoxFit.cover,) : null
                          ),
                          child:
                          profileImageUrl.isNotEmpty?Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage(profileImageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ):
                          Center(
                            child: Icon(
                              Icons.person,
                              size: isTablet?25*getScale(context):(isSmallPhone?30*getScale(context):(35*getScale(context))),
                              color: Colors.white,
                            ),
                          )
                      ):Center(
                        child: CircularProgressIndicator(
                          color: Colors.blue,
                        ),
                      )
                    ),

                    userProfileItem(
                      profileItemHeader: 'USER ID',
                      profileItem:
                      Flexible(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, top: 5*getScale(context)),
                          child: SizedBox(
                            height: isSmallPhone?20*getScale(context):(25*getScale(context)),
                            child: TextField(
                              controller: userIdController,
                              readOnly: true,
                              style: TextStyle(
                                  fontSize: isTablet?10*getScale(context):(isSmallPhone?12*getScale(context):(14*getScale(context))),
                                  color: Colors.grey
                              ),
                              textAlign: TextAlign.right,
                              decoration: InputDecoration(
                                hintText: 'Enter User Id',
                                hintStyle: TextStyle(
                                    fontSize: isTablet?10*getScale(context):(isSmallPhone?15*getScale(context):(14.sp)),
                                    color: Colors.black,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w900,
                                ),
                                border: InputBorder.none,
                              ),

                            ),
                          ),
                        ),
                      ),

                    ),

                    userProfileItem(
                      profileItemHeader: 'Name',
                      profileItem: Text(
                        '${userProvider.currentUser?.firstName} ${userProvider.currentUser?.lastName}',
                        style: TextStyle(
                            fontSize: isTablet?10*getScale(context):(isSmallPhone?16*getScale(context):(14.sp)),
                            color: Colors.grey,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    Consumer<profileData>(
                      builder: (context, userProvider, child) {
                        if (userProvider.currentUserProfile?.regStatus == true) {
                          return
                            userProfileItem(
                              profileItemHeader: 'Phone Number',
                              profileItem: Text(
                                '${userProvider.currentUserProfile?.phoneNo}',
                                style: TextStyle(
                                    fontSize: isTablet?10*getScale(context):(isSmallPhone?16*getScale(context):(14.sp)),
                                    color: Colors.grey,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            );
                        } else {
                          return  userProfileItem(
                            profileItemHeader: 'Phone Number',
                            profileItem: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  FontAwesomeIcons.circleExclamation,
                                  color: Colors.red,
                                ),
                                SizedBox(
                                  width: 3.w,
                                ),
                                Text(
                                  'COMPLETE REGISTERATION',
                                  style: TextStyle(
                                      fontSize: isTablet?10*getScale(context):(isSmallPhone?16*getScale(context):(14.sp)),
                                      color: Colors.red,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ); // Return an empty widget if regStatus is true
                        }
                      },
                    ),

                    //new changes from ogbeish
                    userProfileItem(
                      profileItemHeader: 'Email',
                      profileItem: Text(
                        '${userProvider.currentUser?.email}',
                        style: TextStyle(
                            fontSize: isTablet?10*getScale(context):(isSmallPhone?16*getScale(context):(14.sp)),
                            color: Colors.grey,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: isSmallPhone?30*getScale(context):(35.h),
                    ),
                    Buttons(width: double.infinity,buttonText: 'Edit Profile', buttonTextColor: Colors.white, buttonColor: Color(0xFF1A1AFF), onPressed: ()async{
                      if(isConnectedToInternet){
                        setState(() {
                          isloading = true;
                        });
                        Future.delayed(Duration(seconds: 3), (){
                          Navigator.pushNamed(context, editProfilePage.id).then((_){
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

