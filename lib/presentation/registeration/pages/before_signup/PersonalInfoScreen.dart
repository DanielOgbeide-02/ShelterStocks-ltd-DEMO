import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:provider/provider.dart';
import 'package:shelterstocks_prototype2/common/helpers/functions/getScale.dart';
import 'package:shelterstocks_prototype2/common/widgets/buttons/buttons.dart';
import 'package:shelterstocks_prototype2/presentation/provider/profile/user_profile/profileData.dart';
import 'package:shelterstocks_prototype2/presentation/registeration/pages/before_signup/identification_nextOfKinScreen.dart';
import 'package:shelterstocks_prototype2/presentation/dashboard/pages/user/dashBoardScreen.dart';

import '../../../../common/widgets/flush_bar/Flushbar.dart';
import '../../../../common/widgets/input_field/inputfields.dart';
import '../../../provider/user/userData.dart';
import '../../../provider/firebase/firebaseData.dart';

class PersonalInfoScreen extends StatefulWidget {
  static String id = 'personalInfo_screen';
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}
  List<String> marritalStatus = ['Single', 'Married'];
class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  bool isLoading = false;
  String currentMaritalStatus = marritalStatus[0];
  TextEditingController resaddressController = TextEditingController();
  TextEditingController phoneNoController = TextEditingController();
  String resAddress = '';
  String phoneNo = '';
  bool isConnectedToInternet = false;
  bool isPressed = false;

  StreamSubscription? _internetConnectionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
    _setupInternetConnectionListener();
  }

  Future<void> _checkInternetConnection() async {
    final internetConnectionStatus = await InternetConnectionCheckerPlus().connectionStatus;
    _updateConnectionStatus(internetConnectionStatus == InternetConnectionStatus.connected);
  }

  void _setupInternetConnectionListener() {
    _internetConnectionStreamSubscription = InternetConnectionCheckerPlus().onStatusChange.listen((status) {
      _updateConnectionStatus(status == InternetConnectionStatus.connected);
    });
  }

  void _updateConnectionStatus(bool isConnected) {
    setState(() {
      isConnectedToInternet = isConnected;
      if (!isConnectedToInternet) {
        showInternetLostSnackbar();
      }
    });
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
  @override
  void dispose() {
    _internetConnectionStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width and height
    var screenWidth = MediaQuery.of(context).size.width;
    // Check if the device is a tablet (adjust threshold as needed)
    bool isTablet = screenWidth > 600;
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 0),
            child: Consumer(
              builder: (context, profile, child) {
               return Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   SizedBox(
                     height: 40.h,
                   ),
                   Text(
                     // 'Please fill out the form below to complete your account registration with ShelterStocks.',
                     'Lets complete your profile:',
                     style: TextStyle(
                       color: Color(0xFF1A1AFF),
                       fontSize: isTablet?15*getScale(context):20.sp,
                       fontWeight: FontWeight.bold
                     ),
                   ),
                   SizedBox(height: 5.h,),
                   Text(
                       'Please fill out the form below to complete your account registration with ShelterStocks. All fields are required.',
                     style: TextStyle(
                         color: Colors.black,
                         fontSize: isTablet?10*getScale(context):14.sp,
                       fontWeight: FontWeight.bold
                     ),
                   ),
                   SizedBox(
                     height: 20.h,
                   ),
                   Text(
                     'STEP ${context.watch<profileData>().currentStep} OF ${context.watch<profileData>().totalSteps}',
                     style: TextStyle(
                       color: Color(0xFF1A1AFF),
                       fontSize: isTablet?10*getScale(context):13.sp,
                       fontWeight: FontWeight.bold
                     ),
                   ),
                   SizedBox(
                     height: 20.h,
                   ),
                   Text(
                       'PERSONAL INFORMATION',
                       style: TextStyle(
                           color: Colors.black,
                           fontSize: isTablet?12*getScale(context):15.sp,
                         fontWeight: FontWeight.bold
                       )
                   ),
                   SizedBox(
                     height: 10.h,
                   ),
                   Flexible(
                     child: Container(
                       decoration: BoxDecoration(
                         border: Border(top: BorderSide(color: Color(0xFF1A1AFF), width: 3.w))
                       ),
                       padding: EdgeInsets.only(top: 20),
                       child:
                       ListView(
                         // crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                         Text(
                         'MARITAL STATUS:',
                         style: TextStyle(
                             color: Colors.black,
                             fontWeight: FontWeight.bold,
                             fontSize: isTablet?11*getScale(context):13.sp
                         ),
                       ),
                           SizedBox(
                             height: 10.h,
                           ),
                           Container(
                             decoration: BoxDecoration(
                               border: Border.all(color: Color(0xFF1A1AFF)),
                               borderRadius: BorderRadius.circular(5.r),
                             ),
                             width: double.infinity,
                             child: Row(
                               children: [
                                 Expanded(
                                   child: RadioListTile(
                                     title: Text(
                                         'Single',
                                       style: TextStyle(
                                           fontSize: isTablet?10*getScale(context):13.sp,
                                           fontWeight: FontWeight.bold
                                       ),
                                     ),
                                       value: marritalStatus[0],
                                       groupValue: currentMaritalStatus,
                                       activeColor: Color(0xFF1A1AFF),
                                       onChanged: (value){
                                         setState(() {
                                           currentMaritalStatus = value!;
                                         });
                                       }
                                   ),
                                 ),
                                 SizedBox(
                                   width: 20.w,
                                 ),
                                 Expanded(
                                   child: RadioListTile(
                                       title: Text(
                                           'Married',
                                         style: TextStyle(
                                             fontSize: isTablet?10*getScale(context):13.sp,
                                             fontWeight: FontWeight.bold
                                         ),
                                       ),
                                       value: marritalStatus[1],
                                       groupValue: currentMaritalStatus,
                                       activeColor: Color(0xFF1A1AFF),
                                       onChanged: (value){
                                         setState(() {
                                           currentMaritalStatus = value!;
                                         });
                                       }
                                   ),
                                 )
                               ],
                             ),
                           ),
                           SizedBox(
                             height: 30.h,
                           ),
                           Container(
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Text(
                                     'CONTACT DETAILS:',
                                   style: TextStyle(
                                     color: Colors.black,
                                     fontWeight: FontWeight.bold,
                                     fontSize: isTablet?11*getScale(context):13.sp
                                   ),
                                 ),
                                 SizedBox(
                                   height: 20.h,
                                 ),
                                 InputField(hintText: 'Your Residential address',obscureText: false, controller_: resaddressController,),
                                 // SizedBox(
                                 //   height: 30,
                                 // ),
                                 // InputField(hintText: 'Your Email',obscureText: false),
                                 SizedBox(
                                   height: 30.h,
                                 ),
                                 InputField(hintText: 'Phone Number',obscureText: false,inputType: TextInputType.phone, controller_: phoneNoController,)
                               ],
                             ),
                           ),
                           SizedBox(
                             height: 30.h,
                           ),
                           Container(
                             child: Row(
                               children: [
                                 Expanded(
                                   child: Buttons(
                                     width: 50.w, isPressed: isPressed, buttonText: 'Skip', buttonColor: Color(0xFF1A1AFF), buttonTextColor: Colors.white,isLoading: isLoading,
                                     onPressed: (){
                                      if(isConnectedToInternet){
                                        setState(() {
                                          isPressed = true;
                                          isLoading = true;
                                        });
                                        Future.delayed(Duration(seconds: 2),() async{
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(builder: (context) => DashboardScreen()),
                                                (Route<dynamic> route) => false,
                                          ).then((_){
                                            setState(() {
                                              isPressed = false;
                                              isLoading = false;
                                            });
                                          });
                                        });
                                      }
                                      else{
                                        showInternetLostSnackbar();
                                      }
                                     },
                                   ),
                                 ),
                                 SizedBox(
                                   width: 20.w,
                                 ),
                                 Expanded(
                                   child: Buttons(
                                     width: 50.w, isPressed:isPressed,buttonText: 'Next', buttonColor: Color(0xFF1A1AFF), buttonTextColor: Colors.white,
                                     onPressed: () async {
                                       if(isConnectedToInternet){
                                         setState(() {
                                           isPressed = true;
                                           resAddress = resaddressController.text.trim();
                                           phoneNo = phoneNoController.text.trim();
                                         });
                                         final currentUserProfileProvider = Provider.of<profileData>(context, listen: false);
                                         final userProvider = Provider.of<UserData>(context, listen: false);
                                         String? userId = userProvider.currentUser?.userId;
                                         final firebaseProvider = Provider.of<FirebaseProvider>(
                                             context, listen: false);
                                         if(currentMaritalStatus.isNotEmpty && resAddress.isNotEmpty && phoneNo.isNotEmpty){
                                           currentUserProfileProvider.updateUserProfile(
                                               maritalStatus: currentMaritalStatus,
                                               residentialAddress: resAddress,
                                               phoneNo: phoneNo
                                           );
                                           currentUserProfileProvider.increaseCurrentStep();
                                           Map<String, dynamic> updateUserProfile = {
                                             //NEWLY ADDED
                                             "Marital Status":currentUserProfileProvider.currentUserProfile?.maritalStatus,
                                             "Residential Address": currentUserProfileProvider.currentUserProfile?.residentialAddress,
                                             "Phone Number": currentUserProfileProvider.currentUserProfile?.phoneNo,
                                           };
                                           await firebaseProvider.updateData('UserInformation',userId!,updateUserProfile);
                                           Navigator.pushNamed(context, IdentificationScreen.id);
                                           setState(() {
                                             isPressed = false;
                                           });
                                         }
                                         else{
                                           setState(() {
                                             isPressed = false;
                                           });
                                           print('Please fill all fields completely');
                                           showTopSnackBar(
                                             context: context,
                                             title: 'Error:',
                                             message: 'Please fill all fields completely',
                                           );
                                         }
                                       }
                                       else{
                                         setState(() {
                                           isPressed = false;
                                         });
                                         showInternetLostSnackbar();
                                       }
                                     },
                                   ),
                                 )
                               ],
                             ),
                           ),
                         ],
                         //contact details
                       ),
                     ),
                   )
                 ],
               );
              }
            ),
          )
      ),
    );
  }
}


