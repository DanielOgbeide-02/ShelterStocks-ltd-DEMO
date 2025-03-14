//first try
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:shelterstocks_prototype2/presentation/account/pages/user/settings/banking_information/bank_info.dart';
import 'package:shelterstocks_prototype2/presentation/provider/admin/adminData.dart';
import 'package:shelterstocks_prototype2/data/api/firebase_messaging/firebaseApi.dart';
import 'package:shelterstocks_prototype2/presentation/provider/firebase/firebaseData.dart';
import 'package:shelterstocks_prototype2/data/sources/firebase_operations/firebase_service.dart';
import 'package:shelterstocks_prototype2/presentation/provider/notification/notificationData.dart';
import 'package:shelterstocks_prototype2/presentation/dashboard/pages/admin/AdminDashboard.dart';
import 'package:shelterstocks_prototype2/presentation/registeration/pages/before_signup/PersonalInfoScreen.dart';
import 'package:shelterstocks_prototype2/presentation/registeration/pages/before_signup/bankingDetailsScreen.dart';
import 'package:shelterstocks_prototype2/presentation/registeration/pages/before_signup/identification_nextOfKinScreen.dart';
import 'package:shelterstocks_prototype2/presentation/auth/pages/user/signUpScreen.dart';
import 'package:shelterstocks_prototype2/presentation/home/pages/admin/adminHomeScreen.dart';
import 'package:shelterstocks_prototype2/presentation/auth/pages/admin/adminLogin.dart';
import 'package:shelterstocks_prototype2/presentation/dashboard/pages/user/dashBoardScreen.dart';
import 'package:shelterstocks_prototype2/presentation/auth/pages/admin/AdminResumeApp.dart';
import 'package:shelterstocks_prototype2/presentation/account/pages/admin/settings/adminAccountSettings.dart';
import 'package:shelterstocks_prototype2/presentation/listings/pages/admin/adminListingsPage.dart';
import 'package:shelterstocks_prototype2/presentation/profile/pages/admin/adminProfilePage.dart';
import 'package:shelterstocks_prototype2/presentation/admin_user_info/pages/adminSearchUsersPage.dart';
import 'package:shelterstocks_prototype2/presentation/account/pages/admin/security/adminSecurity.dart';
import 'package:shelterstocks_prototype2/presentation/profile/pages/admin/editAdminProfilePage.dart';
import 'package:shelterstocks_prototype2/presentation/stock_transactions/pages/sellRequestsPage.dart';
import 'package:shelterstocks_prototype2/presentation/account/pages/user/AccountPage.dart';
import 'package:shelterstocks_prototype2/presentation/account/pages/user/settings/AccountSettings.dart';
import 'package:shelterstocks_prototype2/presentation/account/pages/user/settings/identification/meansOfId.dart';
import 'package:shelterstocks_prototype2/presentation/account/pages/user/settings/next_of_kin/nextOfKin.dart';
import 'package:shelterstocks_prototype2/presentation/account/pages/user/settings/notification/notificationScreen.dart';
import 'package:shelterstocks_prototype2/presentation/account/pages/user/contact_us/Contact%20Us.dart';
import 'package:shelterstocks_prototype2/presentation/account/pages/user/security/Security.dart';
import 'package:shelterstocks_prototype2/presentation/home/pages/user/HomeScreen.dart';
import 'package:shelterstocks_prototype2/presentation/registeration/pages/after_signup/InAppPersonalInfoScreen.dart';
import 'package:shelterstocks_prototype2/presentation/listings/pages/user/ListingsPage.dart';
import 'package:shelterstocks_prototype2/presentation/portfolio/pages/PortfolioPage.dart';
import 'package:shelterstocks_prototype2/presentation/account/pages/admin/adminAccountPage.dart';
import 'package:shelterstocks_prototype2/presentation/stock_transactions/pages/buyStocksScreen.dart';
import 'package:shelterstocks_prototype2/presentation/profile/pages/user/editProfilePage.dart';
import 'package:shelterstocks_prototype2/presentation/registeration/pages/after_signup/inAppBankingDetailsScreen.dart';
import 'package:shelterstocks_prototype2/presentation/registeration/pages/after_signup/inAppIdentification_nextOfKinScreen.dart';
import 'package:shelterstocks_prototype2/presentation/profile/pages/user/profilePage.dart';
import 'package:shelterstocks_prototype2/presentation/auth/pages/user/loginScreen.dart';
import 'package:shelterstocks_prototype2/presentation/auth/pages/user/resumeAppScreen.dart';
import 'package:shelterstocks_prototype2/presentation/intro/pages/ShelterStocksGetStartedScreen.dart';
import 'package:provider/provider.dart';
import 'package:shelterstocks_prototype2/presentation/provider/user/userData.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'firebase_config.dart';
import 'presentation/provider/profile/user_profile/profileData.dart';
import 'package:flutter/services.dart';

import 'presentation/provider/transactions/transactionData.dart';
import 'presentation/provider/sell_requests/sellRequestData.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


final navigatorKey = GlobalKey<NavigatorState>();
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle the message here when the app is in the background or terminated.
  print("Handling a background message: ${message.messageId}");
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);
  // await Firebase.initializeApp(
  //     name: 'ShelterStocksDemo',
  //     options: const FirebaseOptions(
  //         apiKey: "AIzaSyAPtIwVV0mxcf3FsiiM2jwS2zKYbM3LT60",
  //         projectId: "shelterstocksdemo",
  //         storageBucket: "shelterstocksdemo.appspot.com",
  //         messagingSenderId: "690125551128",
  //         appId: "1:690125551128:android:72d6f4e41daa02e9a2b56d"
  //     )
  // );
  await Firebase.initializeApp(
    name: 'ShelterStocksDemo',
    options: const FirebaseOptions(
      apiKey: FirebaseConfig.apiKey,
      projectId: FirebaseConfig.projectId,
      storageBucket: FirebaseConfig.storageBucket,
      messagingSenderId: FirebaseConfig.messagingSenderId,
      appId: FirebaseConfig.appId,
    ),
  );

  await FirebaseApi().initNotifications();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);


  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedin') ?? false;
  String initialRoute = getStartedScreen.id;

  if (isLoggedIn) {
    final bool isAdmin = prefs.getBool('isAdmin') ?? false;
    if (isAdmin) {
      initialRoute = AdminResumeApp.id;
    } else {
      initialRoute = resumeAppScreen.id;
    }
  }

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatefulWidget {
  final String initialRoute;
  const MyApp({required this.initialRoute, super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver{
  late bool isLoggedIn;
  late String currentRoute;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    currentRoute = widget.initialRoute;
    _checkUserState();
  }

  Future<void> _checkUserState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedin') ?? false;
      if (isLoggedIn) {
        currentRoute = resumeAppScreen.id;
      } else {
        currentRoute = getStartedScreen.id;
      }
    });
    print("Current Route: $currentRoute");
  }
    @override
  void didChangeAppLifecycleState(AppLifecycleState state) async{
      final prefs = await SharedPreferences.getInstance();
    // TODO: implement didChangeAppLifecycleState
    if (state == AppLifecycleState.paused) {
      // App is being sent to the background, save the login state
      bool? isLoggedIn = prefs.getBool('isLoggedin');
      bool? isAdmin = prefs.getBool('isAdmin');
      prefs.setBool('isLoggedin', isLoggedIn ?? false);
      prefs.setBool('isAdmin', isAdmin ?? false);
    } else if (state == AppLifecycleState.resumed) {
      // App is being resumed, read the login state again
       bool? isLoggedIn = prefs.getBool('isLoggedin');
       bool? isAdmin = prefs.getBool('isAdmin');
       if (isLoggedIn != null && isLoggedIn == true) {
         if (isAdmin != null && isAdmin == true) {
           // Navigate to admin dashboard
           currentRoute = AdminResumeApp.id;
         } else {
           // Navigate to normal resume screen
           currentRoute = resumeAppScreen.id;
         }
       } else {
         // Not logged in, navigate to get started screen
         currentRoute = getStartedScreen.id;
       }
       // setState(() {
       //   // Force navigation based on login state
       //   Navigator.pushNamedAndRemoveUntil(context, currentRoute, (route) => false);
       // });
      // setState(() {
      //   currentRoute = (isLoggedIn!=null && isLoggedIn == true)?(isAdmin!=null && isAdmin)?forAdmin.id:resumeAppScreen.id : getStartedScreen.id;
      // });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("Building app with route: $currentRoute");
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (BuildContext context) => UserData()),
        ChangeNotifierProvider(create: (BuildContext context) => profileData()),
        ChangeNotifierProvider(create: (BuildContext context) => FirebaseProvider()),
        ChangeNotifierProvider(create: (BuildContext context) => transactionData()),
        ChangeNotifierProvider(create: (BuildContext context) => Admindata()),
        ChangeNotifierProvider(create: (BuildContext context) => Sellrequestdata()),
        ChangeNotifierProvider(create: (BuildContext context) => notificationData()),
      ],
      child: ScreenUtilInit(
        designSize: Size(360, 690),
        builder: (context, child) => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: currentRoute,
          navigatorKey: navigatorKey,
          routes: {
            getStartedScreen.id: (context) => const getStartedScreen(),
           Signupscreen.id : (context)=>const Signupscreen(),
           PersonalInfoScreen.id: (context) =>const PersonalInfoScreen(),
           inAppPersonalInfoScreen.id:(context)=>inAppPersonalInfoScreen(),
           IdentificationScreen.id: (context)=>const IdentificationScreen(),
           inAppIdentificationScreen.id:(context)=>inAppIdentificationScreen(),
           BankingdetailsScreen.id: (context) => const BankingdetailsScreen(),
           inAppBankingdetailsScreen.id:(context)=>const inAppBankingdetailsScreen(),
           Loginscreen.id:(context)=> const Loginscreen(),
           DashboardScreen.id:(context)=> const DashboardScreen(),
           resumeAppScreen.id:(context)=> const resumeAppScreen(),
           buyStocksScreen.id:(context)=> const buyStocksScreen(),
           HomeScreen.id:(context)=> HomeScreen(),
           profilePage.id:(context)=> profilePage(),
           accountPage.id:(context)=>accountPage(),
           Listingspage.id:(context)=>Listingspage(),
           editProfilePage.id:(context)=>editProfilePage(),
           accountSettingsPage.id:(context)=>accountSettingsPage(),
           Adminaccountpage.id:(context)=>Adminaccountpage(),
           meansOfIdPage.id:(context)=>meansOfIdPage(),
           nextOfKin.id:(context)=>nextOfKin(),
           securitySettingsPage.id:(context)=>securitySettingsPage(),
           contactUsPage.id:(context)=>contactUsPage(),
           Portfoliopage.id:(context)=>Portfoliopage(),
           Adminlogin.id:(context)=>Adminlogin(),
           Admindashboard.id:(context)=>Admindashboard(),
           Adminhomescreen.id:(context)=>Adminhomescreen(),
            AdminResumeApp.id:(context)=>AdminResumeApp(),
           SearchUsersPage.id:(context)=>SearchUsersPage(),
            SellrequestsPage.id:(context)=>SellrequestsPage(),
            Adminaccountsettings.id:(context)=>Adminaccountsettings(),
            Adminprofilepage.id:(context)=>Adminprofilepage(),
            Editadminprofilepage.id:(context)=>Editadminprofilepage(),
            Adminsecurity.id:(context)=>Adminsecurity(),
            Notificationscreen.id:(context)=>Notificationscreen(),
            admin_listings_page.id:(context)=>admin_listings_page(),
            editBankinginfoScreen.id:(context)=>editBankinginfoScreen(),
          },
        ),
      ),
    );
  }
}





