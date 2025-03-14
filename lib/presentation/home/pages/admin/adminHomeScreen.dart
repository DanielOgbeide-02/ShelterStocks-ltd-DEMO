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
import 'package:shelterstocks_prototype2/common/widgets/buttons/adminHomeBtns.dart';
import 'package:shelterstocks_prototype2/presentation/provider/profile/user_profile/profileData.dart';
import 'package:shelterstocks_prototype2/presentation/provider/admin/adminData.dart';
import 'package:shelterstocks_prototype2/presentation/profile/pages/admin/adminProfilePage.dart';
import 'package:shelterstocks_prototype2/presentation/admin_user_info/pages/adminSearchUsersPage.dart';
import 'package:shelterstocks_prototype2/presentation/stock_transactions/pages/sellRequestsPage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../common/helpers/functions/getScale.dart';
import '../../../provider/user/userData.dart';
import '../../../../common/widgets/alert_dialogs/coming_soon/ComingSoonAlertDialog.dart';


class Adminhomescreen extends StatefulWidget {
  static String id = 'adminHome_screen';
  @override
  State<Adminhomescreen> createState() => _AdminhomescreenState();
}

class _AdminhomescreenState extends State<Adminhomescreen> with WidgetsBindingObserver{
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
  late final adminProvider;
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
    adminProvider  = Provider.of<Admindata>(context, listen: false);
    userProfileProvider = Provider.of<profileData>(context, listen: false);
    WidgetsBinding.instance.addObserver(this);
    _initialSetup();
    _loadAdminData();
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

  Future<void> _loadAdminData() async {
    await adminProvider.loadAdminData();
    await userProfileProvider.loadUserProfileData();
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
    _loadAdminData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async{
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

  final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: '₦',
  );

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    // Check if the device is a tablet (adjust threshold as needed)
    bool isTablet = screenWidth > 600;
    bool isSmallPhone = screenWidth < 413 && screenHeight<800;
    if(isCheckingInternet || showSpinner){
      return Scaffold(
        backgroundColor: Color(0xFF1A1AFF),
        body: Center(
          child: CircularProgressIndicator(color: Colors.white,),
        ),
      );
    }
    return
      isConnectedToInternet?
      Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Color(0xFF1A1AFF),
        body:  Column(
          children: [
            Expanded(
              flex: 5,
              child:
              Container(
                height: 400*getScale(context),
                // color: Colors.red,
                padding: EdgeInsets.only(top:30*getScale(context), left: isTablet?20*getScale(context):30.w, right: isTablet?20*getScale(context):30.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image(
                          image: AssetImage('images/SSdashboardlogo.png'),
                          height: isTablet?41*getScale(context):45*getScale(context),
                          width: isTablet?86*getScale(context):90*getScale(context),
                          fit: BoxFit.contain,
                        ),
                        GestureDetector(
                          onTap: (){
                            showDialog(
                                context: context,
                                builder: (context)=>
                                    comingSoonAlertdialog()
                            );
                          },
                          child: Icon(
                            Icons.notifications,
                            color: Colors.white,
                            size: isTablet?26*getScale(context):30*getScale(context),
                          ),
                        )
                      ],
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.only(top: isSmallPhone?50*getScale(context):90*getScale(context)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Consumer<UserData>(
                                  builder: (context, userProvider, child) {
                                    return
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          //welcome message
                                          Text(
                                            'Welcome, Administrator!',
                                            style: TextStyle(
                                                fontSize: isTablet?25*getScale(context):35*getScale(context),
                                                color: Colors.white,
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          Text(
                                            'Here is your Administrator dashboard.',
                                            style: TextStyle(
                                                fontSize: isTablet?10*getScale(context):18*getScale(context),
                                                color: Colors.grey.shade200,
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          )
                                        ],
                                      );
                                  }
                              ),
                              SizedBox(
                                height: isTablet?21*getScale(context):25*getScale(context),
                              ),
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
              height: isTablet?13*getScale(context):17*getScale(context),
            ),
            Expanded(
              flex: 7,
              child: Container(
                height: 380.h,
                width: double.infinity,
                padding: EdgeInsets.only(top: isTablet?36*getScale(context):40*getScale(context), left: isTablet?20*getScale(context):30.w, right: isTablet?20*getScale(context):30.w,),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(45.r), topRight: Radius.circular(45.r))
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        child: Adminhomebtns(buttonText: 'Profile', buttonIcon: FontAwesomeIcons.circleUser, onPressed: (){
                          Navigator.pushNamed(context, Adminprofilepage.id);
                        },
                          enterText: Text('Edit your profile.', style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w700,
                          ),),
                        ),
                      ),
                      SizedBox(
                        height: isTablet?11.h:15.h,
                      ),
                      Container(
                        width: double.infinity,
                        child: Consumer<Admindata>(
                          builder: (context,admindata,child) {
                          return Adminhomebtns(buttonText: 'Users', buttonIcon: FontAwesomeIcons.user,
                              onPressed: () async{
                            // admindata.fetchAndStoreAllUsersData();
                            Navigator.pushNamed(context, SearchUsersPage.id);
                          },
                            enterText: Text('View all Users.',
                            style: TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w700
                            ),),
                          );

                        },),
                      ),
                      SizedBox(
                        height: isTablet?11.h:15.h,
                      ),
                      Container(
                        width: double.infinity,
                        child:
                        Adminhomebtns(
                          buttonText: 'Sell Requests',
                          buttonIcon: Icons.swap_horiz_outlined,
                          onPressed: ()async{
                            Navigator.pushNamed(context, SellrequestsPage.id);
                        },
                          enterText: const Text('Manage all sell requests.', style: TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w700
                            ),
                          ),
                        ),
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


