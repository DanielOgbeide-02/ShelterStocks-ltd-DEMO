import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:provider/provider.dart';
import 'package:shelterstocks_prototype2/presentation/registeration/pages/before_signup/bankingDetailsScreen.dart';
// import 'package:avoid_keyboard/avoid_keyboard.dart';

import '../../../../common/helpers/functions/getScale.dart';
import '../../../../common/widgets/flush_bar/Flushbar.dart';
import '../../../../common/widgets/buttons/buttons.dart';
import '../../../../common/widgets/input_field/inputfields.dart';
import '../../../provider/profile/user_profile/profileData.dart';
import '../../../provider/user/userData.dart';
import '../../../provider/firebase/firebaseData.dart';
import 'inAppBankingDetailsScreen.dart';

class inAppIdentificationScreen extends StatefulWidget {
  static String id = 'inAppIdentification_screen';
  const inAppIdentificationScreen({super.key});

  @override
  State<inAppIdentificationScreen> createState() => _inAppIdentificationScreenState();
}

class _inAppIdentificationScreenState extends State<inAppIdentificationScreen> {
  TextEditingController meansOfIdController = TextEditingController();
  TextEditingController idNoController = TextEditingController();
  TextEditingController issueDateController = TextEditingController();
  TextEditingController expiryDateController = TextEditingController();
  TextEditingController nokFullnameController = TextEditingController();
  TextEditingController nokRelationController = TextEditingController();
  TextEditingController nokPhonenoController = TextEditingController();
  TextEditingController nokEmailController = TextEditingController();
  TextEditingController nokAddressController = TextEditingController();
  String meansOfId = '';
  String idNo = '';
  String issueDate = '';
  String expiryDate = '';
  String nokFullname = '';
  String nokRelation = '';
  String nokPhoneno = '';
  String nokEmail = '';
  String nokAddress = '';
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
      body: Padding(
        padding: const EdgeInsets.only( top: 30, bottom: 0, left: 20, right: 20),
        child: ListView(
            children: [
              Text(
                'STEP ${context.watch<profileData>().currentStep} OF ${context.watch<profileData>().totalSteps}',
                style: TextStyle(
                  color: Color(0xFF1A1AFF),
                  fontSize: 17,
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              Text(
                  'IDENTIFICATION',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: isTablet?11*getScale(context):15.sp,
                      fontWeight: FontWeight.bold
                  )
              ),
              SizedBox(
                height: 10.h,
              ),
              //Identification
              Container(
                decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFF1A1AFF), width: 3.w))
                ),
                padding: EdgeInsets.only(top: 30),
                child:
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: InputField(hintText: 'Valid means of identification',obscureText: false, controller_: meansOfIdController,)),
                        SizedBox(
                          width: 20.w,
                        ),
                        Expanded(child: InputField(hintText: 'ID NUMBER',obscureText: false, controller_: idNoController,))
                      ],
                    ),
                    SizedBox(height: 20.h,),
                    Row(
                      children: [
                        Expanded(child: InputField(hintText: 'Issue Date(dd/mm/yyyy)',obscureText: false, controller_: issueDateController,)),
                        SizedBox(
                          width: 20.w,
                        ),
                        Expanded(child: InputField(hintText: 'Expiry Date(dd/mm/yyyy)',obscureText: false, controller_: expiryDateController,))
                      ],
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                  ],
                  //contact details
                ),
              ),
              SizedBox(
                height: 5.h,
              ),

              //Next of kin
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      'NEXT OF KIN',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: isTablet?11*getScale(context):15.sp,
                          fontWeight: FontWeight.bold
                      )
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: Color(0xFF1A1AFF), width: 3.w))
                    ),
                    padding: EdgeInsets.only(top: 30),
                    child:
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InputField(hintText: 'Next of kin\'s Full Name',obscureText: false, controller_: nokFullnameController,),
                        SizedBox(height: 20.h,),
                        InputField(hintText: 'Relationship',obscureText: false, controller_: nokRelationController,),
                        SizedBox(height: 20.h,),
                        InputField(hintText: 'Next of Kin\'s Phone Number',obscureText: false, controller_: nokPhonenoController, inputType: TextInputType.phone,),
                        SizedBox(height: 20.h,),
                        InputField(hintText: 'Next of Kin\'s email',obscureText: false, controller_: nokEmailController, inputType: TextInputType.emailAddress,),
                        SizedBox(height: 20.h,),
                        InputField(hintText: 'Next of Kin\'s Contact Address',obscureText: false, controller_: nokAddressController,),
                        SizedBox(height: 20.h,),
                      ],
                      //contact details
                    ),
                  )
                ],
              ),

              //Button
              Container(
                child: Row(
                  children: [
                    Expanded(
                      child: Buttons(
                        width: 50.w, height: 45.h, buttonText: 'Previous', buttonColor: Color(0xFF1A1AFF), buttonTextColor: Colors.white,
                        onPressed: (){
                          setState(() {
                            Provider.of<profileData>(context, listen: false).decreaseCurrentStep();
                          });
                          print(Provider.of<profileData>(context, listen: false).currentStep);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    SizedBox(
                      width: 20.w,
                    ),
                    Expanded(
                      child: Buttons(
                        width: 50.w, isPressed:isPressed,height: 45.h, buttonText: 'Next', buttonColor: Color(0xFF1A1AFF), buttonTextColor: Colors.white,
                        onPressed: () async {
                          if(isConnectedToInternet){
                            setState(() {
                              isPressed = true;
                              meansOfId = meansOfIdController.text.trim();
                              idNo = idNoController.text.trim();
                              issueDate = issueDateController.text.trim();
                              expiryDate = expiryDateController.text.trim();
                              nokFullname = nokFullnameController.text.trim();
                              nokRelation = nokRelationController.text.trim();
                              nokPhoneno = nokPhonenoController.text.trim();
                              nokEmail = nokEmailController.text.trim();
                              nokAddress = nokAddressController.text.trim();
                            });
                            final currentUserProfileProvider = Provider.of<profileData>(context, listen: false);
                            final userProvider = Provider.of<UserData>(context, listen: false);
                            String? userId = userProvider.currentUser?.userId;
                            final firebaseProvider = Provider.of<FirebaseProvider>(
                                context, listen: false);
                            if(meansOfId.isNotEmpty && nokAddress.isNotEmpty && issueDate.isNotEmpty && expiryDate.isNotEmpty && nokFullname.isNotEmpty && idNo.isNotEmpty && nokRelation.isNotEmpty && nokPhoneno.isNotEmpty && nokEmail.isNotEmpty){
                              currentUserProfileProvider.updateUserProfile(
                                meansOfId: meansOfId,
                                nextOfKinsContactAddress: nokAddress,
                                issueDate: issueDate,
                                expiryDate: expiryDate,
                                nextOfKinsFullname: nokFullname,
                                idNumber: idNo,
                                nextOfKinsEmail: nokEmail,
                                nextOfKinsPhoneno: nokPhoneno,
                                relationshipNOK: nokRelation,
                              );
                              currentUserProfileProvider.increaseCurrentStep();
                              Map<String, dynamic> updateUserProfile = {
                                //NEWLY ADDED
                                "Means of Identification":currentUserProfileProvider.currentUserProfile?.meansOfId,
                                "Next of kin\'s contact address": currentUserProfileProvider.currentUserProfile?.nextOfKinsContactAddress,
                                "Issue Date": currentUserProfileProvider.currentUserProfile?.issueDate,
                                "Expiry Date": currentUserProfileProvider.currentUserProfile?.expiryDate,
                                "Next of kin\'s fullname": currentUserProfileProvider.currentUserProfile?.nextOfKinsFullname,
                                "ID Number": currentUserProfileProvider.currentUserProfile?.idNumber,
                                "Next of kin\'s email": currentUserProfileProvider.currentUserProfile?.nextOfKinsEmail,
                                "Next of kin\'s phone number": currentUserProfileProvider.currentUserProfile?.nextOfKinsPhoneno,
                                "Relationship with Next of kin": currentUserProfileProvider.currentUserProfile?.relationshipNOK,
                              };
                              await firebaseProvider.updateData('UserInformation',userId!,updateUserProfile);
                              Navigator.pushNamed(context, inAppBankingdetailsScreen.id);
                              setState(() {
                                isPressed = false;
                              });
                            }
                            else{
                              setState(() {
                                isPressed = false;
                              });
                              print('Please fill fields completely');
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
              )
            ],
          ),
        ),
      );
  }
}
