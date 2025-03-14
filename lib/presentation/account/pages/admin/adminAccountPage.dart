
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:shelterstocks_prototype2/common/helpers/functions/getScale.dart';
import 'package:shelterstocks_prototype2/common/widgets/buttons/buttons.dart';
import 'package:shelterstocks_prototype2/common/helpers/NetworkChecker.dart';
import 'package:shelterstocks_prototype2/presentation/provider/profile/user_profile/profileData.dart';
import 'package:shelterstocks_prototype2/presentation/provider/admin/adminData.dart';
import 'package:shelterstocks_prototype2/presentation/registeration/pages/before_signup/PersonalInfoScreen.dart';
import 'package:shelterstocks_prototype2/presentation/account/pages/admin/settings/adminAccountSettings.dart';
import 'package:shelterstocks_prototype2/presentation/account/pages/admin/security/adminSecurity.dart';
import 'package:shelterstocks_prototype2/presentation/account/pages/user/settings/AccountSettings.dart';
import 'package:shelterstocks_prototype2/presentation/account/pages/user/contact_us/Contact%20Us.dart';
import 'package:shelterstocks_prototype2/presentation/account/pages/user/security/Security.dart';
import 'package:shelterstocks_prototype2/presentation/account/pages/user/transaction_history/TransactionHistory.dart';

import '../../../../common/widgets/account_page_component/AccountPageItem.dart';
import '../../../provider/transactions/transactionData.dart';
import '../../../provider/user/userData.dart';
import '../../../provider/firebase/firebaseData.dart';
import '../../../intro/pages/ShelterStocksGetStartedScreen.dart';
import '../../../registeration/pages/after_signup/InAppPersonalInfoScreen.dart';
// import 'package:get/get.dart';



class Adminaccountpage extends StatefulWidget {
  static String id = 'accountPage_screen';
  const Adminaccountpage({super.key});

  @override
  State<Adminaccountpage> createState() => _AdminaccountpageState();
}

class _AdminaccountpageState extends State<Adminaccountpage> with WidgetsBindingObserver{
  // late HomePageModel _model;

  late final userProvider;
  late final adminProvider;
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
    adminProvider = Provider.of<Admindata>(context, listen: false);
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
    await _loadAdminData();
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

  Future<void> _loadAdminData() async {
    await adminProvider.loadAdminData();
    if (_mounted) {
      setState(() {
        showSpinner = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAdminData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadAdminData();
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
    bool isSmallPhone = screenWidth < 413 && screenHeight<733;
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
                                  fontSize: isTablet?12*getScale(context):(20*getScale(context)),
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w900,
                              ),
                            ),

                            Consumer<UserData>(
                                builder: (context, userProvider, child) {
                                  return Text(
                                    'Administrator',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: isTablet?12*getScale(context):(20*getScale(context)),
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  );
                                }
                            ),
                          ],
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
                          Navigator.pushNamed(context, Adminaccountsettings.id);
                        },
                      ),
                      Consumer<profileData>(
                        builder: (context, userProvider, child) {
                          return GestureDetector(
                            onTap: (){
                              Navigator.pushNamed(context, Adminsecurity.id);
                            },
                            child: Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide.none)
                              ),
                              child:
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Security',
                                    style: TextStyle(
                                      fontFamily: 'Readex Pro',
                                      fontSize: isTablet?10*getScale(context):(15*getScale(context)),
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right_sharp,
                                    color: Color(0xFF1A1AFF),
                                    size: isTablet?20*getScale(context):(20*getScale(context)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                    ],
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                Buttons(width: double.infinity, isPressed: isPressed,buttonText: 'Log out', buttonTextColor: Colors.white, buttonColor: Color(0xFF1A1AFF), isLoading: isLoading,onPressed: ()async{
                  setState(() {
                    isPressed = true;
                    isLoading = true;
                  });
                  Future.delayed(Duration(seconds: 2),() async{
                    userFirebaseProvider.signOutAdmin(adminProvider.currentAdmin?.role);
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
