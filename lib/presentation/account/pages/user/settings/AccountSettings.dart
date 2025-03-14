
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:shelterstocks_prototype2/common/widgets/buttons/buttons.dart';
import 'package:shelterstocks_prototype2/common/helpers/NetworkChecker.dart';
import 'package:shelterstocks_prototype2/domain/models/user_profile/userProfileInfo.dart';
import 'package:shelterstocks_prototype2/presentation/account/pages/user/settings/banking_information/bank_info.dart';
import 'package:shelterstocks_prototype2/presentation/provider/profile/user_profile/profileData.dart';
import 'package:shelterstocks_prototype2/presentation/registeration/pages/before_signup/PersonalInfoScreen.dart';
import 'package:shelterstocks_prototype2/presentation/account/pages/user/settings/identification/meansOfId.dart';
import 'package:shelterstocks_prototype2/presentation/account/pages/user/settings/next_of_kin/nextOfKin.dart';
import 'package:shelterstocks_prototype2/presentation/account/pages/user/settings/notification/notificationScreen.dart';

import '../../../../../common/helpers/functions/getScale.dart';
import '../../../../../common/widgets/account_page_component/AccountPageItem.dart';
import '../../../../../common/widgets/alert_dialogs/coming_soon/ComingSoonAlertDialog.dart';
import '../../../../../common/widgets/buttons/goBackBtn.dart';
import '../../../../../common/widgets/flush_bar/Flushbar.dart';
import '../../../../provider/user/userData.dart';
import '../../../../provider/firebase/firebaseData.dart';
import '../../../../intro/pages/ShelterStocksGetStartedScreen.dart';
import '../../../../profile/pages/user/profilePage.dart';




class accountSettingsPage extends StatefulWidget {
  static String id = 'accountSettingsPage_screen';
  const accountSettingsPage({super.key});

  @override
  State<accountSettingsPage> createState() => _accountSettingsState();
}

class _accountSettingsState extends State<accountSettingsPage> with WidgetsBindingObserver{
  late final userProvider;
  late final userProfileProvider;
  bool showSpinner = true;
  bool isLoading = false;
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
    super.didChangeDependencies();
    _loadData();
    _checkInternetConnection();
    _internetConnectionStreamSubscription = InternetConnectionCheckerPlus().onStatusChange.listen((status) {
      setState(() {
        isConnectedToInternet = status == InternetConnectionStatus.connected;
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
    // Check if the device is a tablet (adjust threshold as needed)
    bool isTablet = screenWidth > 600;
    bool isSmallPhone = screenWidth < 413 && screenHeight<733;
    if(showSpinner){
      return Center(
        child: CircularProgressIndicator(color: Colors.white,),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: true,
        child: isConnectedToInternet?
        Padding(
          padding: const EdgeInsets.only(left: 20.0,right: 20.0, bottom: 20, top: 30),
          child: SingleChildScrollView(
            child:

            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: double.infinity,
                  height: 80.0*getScale(context),
                  decoration: BoxDecoration(
                  ),
                  child:  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      goBackBtn(size: 25,),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Account Settings',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20*getScale(context),
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: isTablet?5*getScale(context):18*getScale(context),
                ),
            Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade200,
                  ),
                  child:

                  Column(
                    children: [
                      accountPageItem(
                        itemName: 'Profile Settings',
                        onPressed: (){
                          Navigator.pushNamed(context, profilePage.id);
                        },
                      ),
                      accountPageItem(
                        itemName: 'Means of Identification',
                        onPressed: (){
                          Navigator.pushNamed(context, meansOfIdPage.id);
                        },
                      ),
                      Consumer<profileData>(
                        builder: (context,userProfileData, child) {
                          bool? registerationStatus = userProfileData.currentUserProfile?.regStatus;
                          return accountPageItem(
                            itemName: 'Banking Information',
                            onPressed: (){
                              (registerationStatus!)?Navigator.pushNamed(context, editBankinginfoScreen.id):showTopSnackBar(
                                context: context,
                                title: 'Note:',
                                message: 'You must complete registration to access this feature. Go To: Account>COMPLETE REGISTRATION',
                              );
                            },
                          );
                        },
                      ),
                      accountPageItem(
                        itemName: 'Next of Kin',
                        onPressed: (){
                          Navigator.pushNamed(context, nextOfKin.id);
                        },
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.pushNamed(context, Notificationscreen.id);

                        },
                        child: Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                  border:Border(bottom: BorderSide.none)
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Notifications',
                                    style: TextStyle(
                                      fontSize: isTablet?10*getScale(context):(isSmallPhone?15.0*getScale(context):(17.0*getScale(context))),
                                      letterSpacing: 0.0,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right_sharp,
                                    color: Color(0xFF1A1AFF),
                                    size: isTablet?20*getScale(context):(isSmallPhone?20.0*getScale(context):(24.0*getScale(context))),
                                  ),
                                ],
                              ),
                        ),
                      )
                    ],
                  )
                ),
                SizedBox(
                  height: 50,
                ),
              ],
            ),
          ),
        ):
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 30),
                child: Container(
                  alignment: Alignment.topLeft,
                  child:goBackBtn(size: 25,),
                ),
              ),
            ),
            Expanded(
              flex: 10,
              child: Container(
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
