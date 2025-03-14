
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';

import 'package:shelterstocks_prototype2/common/widgets/buttons/buttons.dart';
import 'package:shelterstocks_prototype2/common/helpers/NetworkChecker.dart';
import 'package:shelterstocks_prototype2/presentation/provider/profile/user_profile/profileData.dart';
import 'package:shelterstocks_prototype2/presentation/provider/notification/notificationData.dart';
import 'package:shelterstocks_prototype2/presentation/registeration/pages/before_signup/PersonalInfoScreen.dart';
import 'package:shelterstocks_prototype2/presentation/account/pages/user/settings/AccountSettings.dart';
import 'package:shelterstocks_prototype2/presentation/account/pages/user/contact_us/Contact%20Us.dart';
import 'package:shelterstocks_prototype2/presentation/account/pages/user/security/Security.dart';
import 'package:shelterstocks_prototype2/presentation/account/pages/user/transaction_history/TransactionHistory.dart';

import '../../../../common/helpers/functions/getScale.dart';
import '../../../../common/widgets/account_page_component/AccountPageItem.dart';
import '../../../provider/transactions/transactionData.dart';
import '../../../provider/user/userData.dart';
import '../../../provider/firebase/firebaseData.dart';
import '../../../intro/pages/ShelterStocksGetStartedScreen.dart';
import '../../../registeration/pages/after_signup/InAppPersonalInfoScreen.dart';
// import 'package:get/get.dart';



class accountPage extends StatefulWidget {
  static String id = 'accountPage_screen';
  const accountPage({super.key});

  @override
  State<accountPage> createState() => _accountPageState();
}

class _accountPageState extends State<accountPage> with WidgetsBindingObserver{
  // late HomePageModel _model;

  late final userProvider;
  late final userProfileProvider;
  bool showSpinner = true;
  bool isLoading = false;
  bool isPressed = false;
  bool isConnectedToInternet = false;
  bool isCheckingInternet = true;
  bool _mounted = true;
  StreamSubscription? _internetConnectionStreamSubscription;

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserData>(context, listen: false);
    userProfileProvider = Provider.of<profileData>(context, listen: false);
    WidgetsBinding.instance.addObserver(this);
    _initialSetup();
  }

  Future<void> _initialSetup() async {
    await _checkInternetConnection();
    if (_mounted) {
      setState(() {
        isCheckingInternet = false;
        showSpinner = false;
      });
    }
    _setupInternetConnectionListener();
    await _loadData();
  }

  Future<void> _checkInternetConnection() async {
    final internetConnectionStatus = await InternetConnectionCheckerPlus().connectionStatus;
    _updateConnectionStatus(internetConnectionStatus == InternetConnectionStatus.connected);
  }

  void _setupInternetConnectionListener() {
    _internetConnectionStreamSubscription = InternetConnectionCheckerPlus().onStatusChange.listen((status) {
      if (_mounted) {
        _updateConnectionStatus(status == InternetConnectionStatus.connected);
      }
    });
  }

  void _updateConnectionStatus(bool isConnected) {
    if (_mounted) {
      setState(() {
        isConnectedToInternet = isConnected;
        if (!isConnectedToInternet) {
          showInternetLostSnackbar();
        }
      });
    }
  }

  void showInternetLostSnackbar() {
    if (!Get.isSnackbarOpen) {
      Get.snackbar(
        "Connection Lost",
        "You have lost connection to the internet.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: EdgeInsets.all(16),
        borderRadius: 10,
        icon: Icon(Icons.wifi_off, color: Colors.white),
        snackStyle: SnackStyle.FLOATING,
        duration: Duration(seconds: 3),
        isDismissible: true,
      );
    }
  }

  Future<void> _loadData() async {
    await userProvider.loadUserData();
    await userProfileProvider.loadUserProfileData();
    if (_mounted) {
      setState(() {
        showSpinner = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  @override
  void dispose() {
    _mounted = false;
    _internetConnectionStreamSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    // Check if the device is a tablet (adjust threshold as needed)
    bool isTablet = screenWidth > 600;
    bool isSmallPhone = screenWidth < 413 && screenHeight<800;
    String profileImageUrl = userProfileProvider.currentUserProfile?.profilePictureUrl;
    if(isCheckingInternet || showSpinner){
      return Scaffold(
        backgroundColor: Color(0xFF1A1AFF),
        body: Center(
          child: CircularProgressIndicator(color: Colors.white,),
        ),
      );
    }
    final userFirebaseProvider = Provider.of<FirebaseProvider>(context, listen: false);
    return
      isConnectedToInternet?
      Scaffold(
            backgroundColor: Colors.white,
            body: Padding(
                padding: const EdgeInsets.only(left: 20.0,right: 20.0, bottom: 20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: double.infinity,
                        height: isTablet?100*getScale(context):(130.0*getScale(context)),
                        decoration: BoxDecoration(
                        ),
                        child:
                        Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
             Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Text(
                   'My Account,',
                   style: TextStyle(
                       color: Colors.black,
                       fontSize: isTablet?20:(isSmallPhone?17.0*getScale(context):(20.0*getScale(context))),
                     fontFamily: 'Roboto',
                     fontWeight: FontWeight.w900,
                   ),
                 ),

                 Consumer<UserData>(
                     builder: (context, userProvider, child) {
                       return Text(
                         '${userProvider.currentUser?.firstName} ${userProvider.currentUser?.lastName}',
                         style: TextStyle(
                             color: Colors.grey,
                             fontSize: isTablet?12*getScale(context):(isSmallPhone?15.0*getScale(context):(20.0*getScale(context))),
                           fontFamily: 'Roboto',
                           fontWeight: FontWeight.w700,
                         ),
                       );
                     }
                 ),
               ],
             ),
              isConnectedToInternet?Container(
                  width: 60.0,
                  height: 60.0,
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
                      size: 35,
                      color: Colors.white,
                    ),
                  )
              ):Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              ),
            ]
                        ),
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
                itemName: 'Account Settings',
                onPressed: (){
                  Navigator.pushNamed(context, accountSettingsPage.id);
                },
              ),
              accountPageItem(
                itemName: 'Security',
                onPressed: (){
                  Navigator.pushNamed(context, securitySettingsPage.id);
                },
              ),
              accountPageItem(
                itemName: 'Contact Us',
                onPressed: (){
                  Navigator.pushNamed(context, contactUsPage.id);
                },
              ),
              Consumer<profileData>(
                builder: (context, userProvider, child) {
                  return GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>TransactionHistoryScreen()));
                    },
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          border: (userProvider.currentUserProfile?.regStatus)!? Border(bottom: BorderSide.none):Border(
                              bottom: BorderSide(color: Colors.grey.shade300, width: 1)
                          )
                      ),
                      child:
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Transactions History',
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
                  );
                },
              ),

              GestureDetector(
                  onTap: (){
                      Navigator.pushNamed(context, inAppPersonalInfoScreen.id);
                  },
                  child: CompleteRegisteration()
              ),



            ],
                        ),
                      ),
                      SizedBox(
                        height: isTablet?20*getScale(context):(isSmallPhone?25.0*getScale(context):(50.0*getScale(context))),
                      ),
                      Buttons(width: double.infinity, isPressed: isPressed,buttonText: 'Log out', buttonTextColor: Colors.white, buttonColor: Color(0xFF1A1AFF), isLoading: isLoading,onPressed: ()async{
                        setState(() {
            isPressed = true;
            isLoading = true;
                        });
                        final transactionsProvider = Provider.of<transactionData>(context, listen: false);
                        final notificationsProvider = Provider.of<notificationData>(context, listen: false);
                        Future.delayed(Duration(seconds: 2),() async{
            userFirebaseProvider.signOut(transactionsProvider, notificationsProvider);
            Navigator.of(context).pushNamedAndRemoveUntil(
              getStartedScreen.id,
                  (Route<dynamic> route) => false,
            ).then((_){
              setState(() {
                isLoading = false;
                isPressed = false;
              });
            });
                        });
                      },),

                    ],
                  ),
                ),
            ),
          ):
      Scaffold(
        backgroundColor: Colors.white,
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                isConnectedToInternet ? Icons.wifi : Icons.wifi_off,
                size: 50,
                color: isConnectedToInternet ? Colors.green : Colors.red,
              ),
              Text(isConnectedToInternet ? 'You are connected to the internet.' : 'You are not connected to the internet.')
            ],
          ),
        ),
      );
  }
}

class CompleteRegisteration extends StatelessWidget {
  const CompleteRegisteration({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    // Check if the device is a tablet (adjust threshold as needed)
    bool isTablet = screenWidth > 600;
    bool isSmallPhone = screenWidth < 413 && screenHeight<800;
    return Consumer<profileData>(
      builder: (context, userProvider, child) {
        if (userProvider.currentUserProfile?.regStatus == false) {
          return Container(
            padding: EdgeInsets.all(20),
            color: Colors.transparent,
            // This ensures the entire container is tappable
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded( // This ensures the text takes up all available space
                  child: Text(
                    'COMPLETE REGISTRATION',
                    style: TextStyle(
                        fontSize: isTablet?10*getScale(context):(isSmallPhone?15.0*getScale(context):(17.0*getScale(context))),
                        letterSpacing: 0.0,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        color: Colors.red
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_sharp,
                  color: Color(0xFF1A1AFF),
                  size: isTablet?20*getScale(context):(isSmallPhone?20.0*getScale(context):(24.0*getScale(context))),
                ),
              ],
            ),
          );
        } else {
          return SizedBox
              .shrink(); // Return an empty widget if regStatus is true
        }
      },
    );
  }
}