import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shelterstocks_prototype2/common/widgets/notification_icon/notification_icon.dart';
import 'package:shelterstocks_prototype2/presentation/provider/profile/user_profile/profileData.dart';
import 'package:shelterstocks_prototype2/presentation/account/pages/user/settings/notification/notificationScreen.dart';
import 'package:shelterstocks_prototype2/presentation/portfolio/pages/PortfolioPage.dart';
import 'package:shelterstocks_prototype2/presentation/stock_transactions/pages/buyStocksScreen.dart';
import 'package:shelterstocks_prototype2/presentation/profile/pages/user/profilePage.dart';
import 'package:shelterstocks_prototype2/presentation/stock_transactions/pages/showSellScreen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../common/helpers/functions/getScale.dart';
import '../../../../common/widgets/buttons/ExploreButtons.dart';
import '../../../../common/widgets/flush_bar/Flushbar.dart';
import '../../../../core/configs/Theme/app_colors.dart';
import '../../../provider/notification/notificationData.dart';
import '../../../provider/user/userData.dart';



class HomeScreen extends StatefulWidget {
  static String id = 'Home_screen';
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver{
  void _launchURL(Uri uri, bool inApp) async{
    try{
      if(await canLaunchUrl(uri)){
        if(inApp){
          await launchUrl(uri, mode: LaunchMode.inAppWebView);
        }
        else{
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    }
    catch(ex){
      print(ex.toString());
    }
  }
  late final userProvider;
  late final userProfileProvider;
  bool showSpinner = true;
  bool isConnectedToInternet = false;
  bool isCheckingInternet = true;
  bool _mounted = true;

  StreamSubscription? _internetConnectionStreamSubscription;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkInternetConnection();
    _setupInternetConnectionListener();
    userProvider  = Provider.of<UserData>(context, listen: false);
    userProfileProvider = Provider.of<profileData>(context, listen: false);
    WidgetsBinding.instance.addObserver(this);
    _initialSetup();
  }
  Future<void> _initialSetup() async {
    await _checkInternetConnection();
    await _loadData();
    if (_mounted) {
      setState(() {
        isCheckingInternet = false;
        showSpinner = false;
      });
    }
    _setupInternetConnectionListener();
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
    // Only show the snackbar if it's not already visible
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
    // Call fetchAndUpdateUserStocks here
    await userProvider.fetchAndUpdateUserStocks();
    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('email');
    // print('current user id: $userId');

    if (_mounted) {
      setState(() {
        showSpinner = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async{
    if (state == AppLifecycleState.resumed) {
      await _loadData();
      // Call fetchAndUpdateUserStocks here
      await userProvider.fetchAndUpdateUserStocks();
    }
  }

  @override
  void dispose() {
    _mounted = false;
    _internetConnectionStreamSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: '₦',
  );

  @override
  Widget build(BuildContext context) {
    // print(userProvider.currentUser.userId);
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    // Check if the device is a tablet (adjust threshold as needed)
    bool isTablet = screenWidth > 600;
    bool isSmallPhone = screenWidth < 413 && screenHeight<800;
    if(isCheckingInternet && showSpinner){
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white,),
        ),
      );
    }
    return
      isConnectedToInternet?
      Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.background,
        body:  Column(
          children: [
            Expanded(
              flex: 5,
              child:
              Container(
                height: 400*getScale(context),
                // color: Colors.red,
                padding: EdgeInsets.only(top:30*getScale(context), left: (isTablet?20*getScale(context):30.w), right: isTablet?20*getScale(context):30.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Image(
                          image: AssetImage('images/SSdashboardlogo.png'),
                          height: isSmallPhone?40*getScale(context):(isTablet?41*getScale(context):45*getScale(context)),
                          width: isSmallPhone?85*getScale(context):(isTablet?86*getScale(context):90*getScale(context)),
                          fit: BoxFit.contain,
                        ),
                        GestureDetector(
                          onTap: (){

                            Navigator.pushNamed(context, Notificationscreen.id);
                          },
                          child: Consumer<UserData>(
                            builder: (context, userData, child) {
                              return
                                Consumer<notificationData>(
                                builder: (context,notificationData, child) {
                                  notificationData.loadNotifications(userData.currentUser!.userId!, 'Notifications');
                                  return NotificationIconWithDot(hasUnreadNotifications: notificationData.hasUnreadNotifications());
                                },
                              );
                            },
                          ),
                        )
                      ],
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.only(top: isSmallPhone?50*getScale(context):(isTablet?45*getScale(context):90*getScale(context))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Consumer<UserData>(
                                  builder: (context, userProvider, child) {
                                    return
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          //welcome message
                                          Text(
                                            'Welcome, ${userProvider.currentUser?.firstName}!',
                                            style: TextStyle(
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.w900,
                                              fontSize: isSmallPhone?15*getScale(context):(isTablet?15*getScale(context):25*getScale(context)),
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            'Here is your ShelterStocks dashboard.',
                                            style: TextStyle(
                                                fontFamily: 'Roboto',
                                                fontWeight: FontWeight.w700,
                                                fontSize: isSmallPhone?12*getScale(context):(isTablet?7*getScale(context):15*getScale(context)),
                                                color: Colors.grey.shade200
                                            ),
                                          )
                                        ],
                                      );
                                  }
                              ),
                              SizedBox(
                                height: isSmallPhone?15*getScale(context):(isTablet?21*getScale(context):25*getScale(context)),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Consumer<UserData>(
                                      builder:(context, userProvider, child){
                                        // _loadData();
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'SHELTERSTOCK\nUNITS',
                                              style: TextStyle(
                                                fontSize: isSmallPhone?9*getScale(context):(isTablet?9*getScale(context):13*getScale(context)),
                                                color: Colors.lightGreen,
                                                fontFamily: 'Roboto',
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            Text(
                                              '${userProvider.currentUser?.stockUnits}',
                                              style: TextStyle(
                                                fontSize: isSmallPhone?18*getScale(context):(isTablet?12*getScale(context):23*getScale(context)),
                                                color: Colors.white,
                                                fontFamily: 'Roboto',
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                  ),
                                  Consumer<UserData>(
                                      builder: (context, userProvider, child) {
                                        _loadData();
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'SHELTERSTOCK\nVALUE(\₦)',
                                              style: TextStyle(
                                                fontSize: isSmallPhone?9*getScale(context):(isTablet?9*getScale(context):13*getScale(context)),
                                                color: Colors.lightGreen,
                                                fontFamily: 'Roboto',
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            Text(
                                              '${currencyFormatter.format(userProvider.currentUser?.stockValue)}',
                                              style: TextStyle(
                                                fontSize: isSmallPhone?18*getScale(context):(isTablet?12*getScale(context):25*getScale(context)),
                                                color: Colors.white,
                                                fontFamily: 'Roboto',
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                  )

                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: isSmallPhone?12*getScale(context):(isTablet?5*getScale(context):17*getScale(context)),
            ),
            Expanded(
              flex: 7,
              child: Container(
                height: 380.h,
                width: double.infinity,
                padding: EdgeInsets.only(top: isSmallPhone?35*getScale(context):(isTablet?25*getScale(context):40*getScale(context)), left: (isTablet?20*getScale(context):30.w), right: (isTablet?20*getScale(context):30.w),),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(45.r), topRight: Radius.circular(45.r))
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'We are on the mission to democratize real estate investing by breaking down the barriers to entry and creating opportunities for people from all works of life.',
                        style: TextStyle(
                          fontSize: isSmallPhone?11*getScale(context):(isTablet?9*getScale(context):13*getScale(context)),
                          color: Colors.grey,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                        height: isSmallPhone?20*getScale(context):(isTablet?5*getScale(context):25.h),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Explore',
                            style: TextStyle(
                              fontSize: isSmallPhone?12*getScale(context):(isTablet?10*getScale(context):15*getScale(context)),
                              color: Colors.black,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(
                            width: isSmallPhone?2*getScale(context):(isTablet?3.w:5.w),
                          ),
                          Text(
                            'ShelterStocks',
                            style: TextStyle(
                              fontSize: isSmallPhone?15*getScale(context):(isTablet?10*getScale(context):20*getScale(context)),
                              color: AppColors.background,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: isSmallPhone?10*getScale(context):(isTablet?11.h:15.h),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ExploreButtons(buttonText: 'Profile', buttonIcon: FontAwesomeIcons.circleUser, onPressed: (){
                            Navigator.pushNamed(context, profilePage.id);
                          },),
                          ExploreButtons(buttonText: 'Buy', buttonIcon: FontAwesomeIcons.creditCard, onPressed: () async{
                            final userProfileProvider = Provider.of<profileData>(context, listen: false);
                            _loadData();
                            if (userProfileProvider.currentUserProfile?.regStatus == true) {
                              Navigator.pushNamed(context, buyStocksScreen.id);
                            } else {
                              showTopSnackBar(
                                context: context,
                                title: 'Note:',
                                message: 'You must complete registration to access this feature. Go To: Account>COMPLETE REGISTRATION',
                              );
                            }
                          },),
                          ExploreButtons(buttonText: 'Sell', buttonIcon: Icons.swap_horiz_outlined, onPressed: ()async{
                            showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context)=> Showsellscreen()
                            );
                          },)
                        ],
                      ),
                      SizedBox(
                        height: isSmallPhone?10*getScale(context):(isTablet?11.h:15.h),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ExploreButtons(buttonText: 'Portfolio', buttonIcon: FontAwesomeIcons.houseChimney, onPressed: (){
                            Navigator.pushNamed(context, Portfoliopage.id);
                          },),
                          ExploreButtons(buttonText: 'Privacy', buttonIcon: FontAwesomeIcons.shieldHalved, onPressed: (){
                            _launchURL(Uri.parse('https://shelterstocks.com/privacy-policy/'), false);
                          },),
                          ExploreButtons(buttonText: 'Help', buttonIcon: FontAwesomeIcons.circleInfo, onPressed: (){
                            _launchURL(Uri.parse('https://shelterstocks.com/about-shelterstocks/'), false);
                          },)
                        ],),
                      SizedBox(
                        height: isSmallPhone?40*getScale(context):(40.h),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
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


