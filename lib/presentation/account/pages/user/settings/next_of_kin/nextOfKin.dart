
import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:provider/provider.dart';
import 'package:shelterstocks_prototype2/common/widgets/buttons/buttons.dart';
import 'package:shelterstocks_prototype2/common/widgets/buttons/goBackBtn.dart';
import '../../../../../../common/helpers/functions/getScale.dart';
import '../../../../../../common/widgets/flush_bar/Flushbar.dart';
import '../../../../../../common/widgets/profile_components/userProfileItem.dart';
import '../../../../../provider/profile/user_profile/profileData.dart';
import '../../../../../provider/user/userData.dart';
import '../../../../../provider/firebase/firebaseData.dart';


class nextOfKin extends StatefulWidget {
  static String id = 'nextOfKinPage_screen';
  const nextOfKin({super.key});

  @override
  State<nextOfKin> createState() => _nextOfKin();
}

class _nextOfKin extends State<nextOfKin> with WidgetsBindingObserver{
  // late HomePageModel _model;
  late final userProvider;
  late final userProfileProvider;
  bool showSpinner = true;
  bool isloading = false;
  bool readOnly = false;
  bool isConnectedToInternet = false;
  final TextEditingController nextOfKinsFullnameController = TextEditingController();
  final TextEditingController relationshipNOKController = TextEditingController();
  final TextEditingController nextOfKinsPhonenoController = TextEditingController();
  final TextEditingController nextOfKinsEmailController = TextEditingController();
  final TextEditingController nextOfKinsContactAddressController = TextEditingController();
  String updatednextOfKinsFullname = '';
  String updatedrelationshipNOK = '';
  String updatednextOfKinsPhoneno = '';
  String updatednextOfKinsEmail = '';
  String updatednextOfKinsContactAddress = '';



  void _updateReadOnlyStatus() {
    if (userProfileProvider.currentUserProfile?.regStatus == false) {
      if (!readOnly) {
        setState(() {
          readOnly = true;
        });
      }
    } else {
      if (readOnly) {
        setState(() {
          readOnly = false;
        });
      }
    }
  }


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
        if (!isConnectedToInternet) {
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

  String toTitleCase(String str) {
    if (str.isEmpty) return str;
    return str[0].toUpperCase() + str.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    // Check if the device is a tablet (adjust threshold as needed)
    bool isTablet = screenWidth > 600;
    bool isSmallPhone = screenWidth < 413 && screenHeight<733;
    String nokFullName = '${userProfileProvider.currentUserProfile?.nextOfKinsFullname}';
    String relationship = userProfileProvider.currentUserProfile?.relationshipNOK;
    String nokPhoneNo = userProfileProvider.currentUserProfile?.nextOfKinsPhoneno;
    String nokEmail = userProfileProvider.currentUserProfile?.nextOfKinsEmail;
    String nokContactAddress = userProfileProvider.currentUserProfile?.nextOfKinsContactAddress;
    nextOfKinsFullnameController.text = nokFullName;
    relationshipNOKController.text = relationship;
    nextOfKinsPhonenoController.text = nokPhoneNo;
    nextOfKinsEmailController.text = nokEmail;
    nextOfKinsContactAddressController.text = nokContactAddress;

    if(showSpinner){
      return Center(
        child: CircularProgressIndicator(color: Colors.white,),
      );
    }
    final userFirebaseProvider = Provider.of<FirebaseProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: true,
        child:
        Container(
          margin: const EdgeInsets.only(top: 30.0,left: 20.0, right: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              goBackBtn(size: 25,),
              SizedBox(
                height: 20,
              ),
              Text(
                'Next of Kin',
                style: TextStyle(
                    fontSize: 20.sp,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Consumer<profileData>(
                builder: (context, userProvider, child) {
                  if (userProvider.currentUserProfile?.regStatus == false) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _updateReadOnlyStatus();
                    });
                    return
                      Text(
                        'Please complete your registration to edit fields.',
                        style: TextStyle(
                            color: Colors.red,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w700,
                        ),
                      );
                  } else {
                    return Text(
                      'Tap to edit your next of kin\'s details.',
                      style: TextStyle(
                          color: Color(0xFF1A1AFF),
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                      ),
                    ); // Return an empty widget if regStatus is true
                  }
                },
              ),
              //here
              Flexible(child: ListView(
                children: [
                  userProfileItem(
                      profileItemHeader: 'Next of kin\'s Full Name',
                      profileItem:
                      Flexible(
                        child: SizedBox(
                          height: 25,
                          child:
                          TextField(
                            controller: nextOfKinsFullnameController,
                            readOnly: readOnly,
                            style: TextStyle(
                              fontSize: isTablet?10*getScale(context):(16.sp),
                                color: Colors.grey,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              hintText: 'Enter NOK Full Name',
                              hintStyle: TextStyle(
                                fontSize: isTablet?10*getScale(context):(16.sp),
                                color: Colors.grey,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w700,
                              ),
                              border: InputBorder.none,
                            ),

                          ),
                        ),
                      )
                  ),

                  userProfileItem(
                      profileItemHeader: 'Relationship',
                      profileItem:
                      Flexible(
                        child: SizedBox(
                          height: 25,
                          child: TextField(
                            controller: relationshipNOKController,
                            readOnly: readOnly,
                            style: TextStyle(
                              fontSize: isTablet?10*getScale(context):(16.sp),
                              color: Colors.grey,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              hintText: 'Enter NOK relationship',
                              hintStyle: TextStyle(
                                fontSize: isTablet?10*getScale(context):(16.sp),
                                color: Colors.grey,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w700,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      )
                  ),

                  userProfileItem(
                      profileItemHeader: 'Next of Kin\'s Phone Number',
                      profileItem:
                      Flexible(
                        child: SizedBox(
                          height: 25,
                          child: TextField(
                            controller: nextOfKinsPhonenoController,
                            readOnly: readOnly,
                            style: TextStyle(
                              fontSize: isTablet?10*getScale(context):(16.sp),
                              color: Colors.grey,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              hintText: 'Enter NOK phone number',
                              hintStyle: TextStyle(
                                fontSize: isTablet?10*getScale(context):(16.sp),
                                color: Colors.grey,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w700,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      )
                  ),
                  //new changes from ogbeish
                  userProfileItem(
                      profileItemHeader: 'Next of Kin\'s email',
                      profileItem:
                      Flexible(
                        child: SizedBox(
                          height: 25,
                          child: TextField(
                            controller: nextOfKinsEmailController,
                            readOnly: readOnly,
                            style: TextStyle(
                              fontSize: isTablet?10*getScale(context):(16.sp),
                              color: Colors.grey,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              hintText: 'Enter NOK email',
                              hintStyle: TextStyle(
                                fontSize: isTablet?10*getScale(context):(16.sp),
                                color: Colors.grey,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w700,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      )
                  ),
                  userProfileItem(
                      profileItemHeader: 'Next of Kin\'s Contact Address',
                      profileItem:
                      Flexible(
                        child: SizedBox(
                          height: 25,
                          child: TextField(
                            controller: nextOfKinsContactAddressController,
                            readOnly: readOnly,
                            style: TextStyle(
                              fontSize: isTablet?10*getScale(context):(16.sp),
                              color: Colors.grey,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              hintText: 'Enter NOK contact address',
                              hintStyle: TextStyle(
                                fontSize: isTablet?10*getScale(context):(16.sp),
                                color: Colors.grey,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w700,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      )
                  ),
                  SizedBox(
                    height: 35,
                  ),
                  Buttons(isLoading: isloading,width: double.infinity, buttonText: 'FINISH', buttonTextColor: Colors.white, buttonColor: Color(0xFF1A1AFF), onPressed: ()async{
                    if(isConnectedToInternet){
                      setState(() {
                        isloading = true;
                        updatednextOfKinsFullname = toTitleCase(nextOfKinsFullnameController.text.trim());
                        updatedrelationshipNOK = toTitleCase(relationshipNOKController.text.trim());
                        updatednextOfKinsPhoneno = nextOfKinsPhonenoController.text.trim();
                        updatednextOfKinsEmail = nextOfKinsEmailController.text.trim();
                        updatednextOfKinsContactAddress = nextOfKinsContactAddressController.text.trim();
                      });
                      if (nokFullName != updatednextOfKinsFullname || relationship != updatedrelationshipNOK || nokPhoneNo != updatednextOfKinsPhoneno || nokEmail != updatednextOfKinsEmail || nokContactAddress != updatednextOfKinsContactAddress) {
                        final firebaseProvider = Provider.of<FirebaseProvider>(context, listen: false);
                        Map<String, dynamic> userData = {};
                        if (nokFullName != updatednextOfKinsFullname && updatednextOfKinsFullname.split(' ').length >= 2) {
                          userData["Next of kin's fullname"] = toTitleCase(nextOfKinsFullnameController.text);
                        }
                        else{
                          showTopSnackBar(context: context, title: 'Error:', message: 'Please enter Next of Kin\'s Full Name');
                        }
                        if (relationship != updatedrelationshipNOK) {
                          userData["Relationship with Next of kin"] = (relationshipNOKController.text);
                        }
                        if (nokPhoneNo != updatednextOfKinsPhoneno) {
                          userData["Next of kin's phone number"] = nextOfKinsPhonenoController.text;
                        }
                        if (nokEmail != updatednextOfKinsEmail) {
                          userData["Next of kin's email"] = nextOfKinsEmailController.text;
                        }
                        if (nokContactAddress != updatednextOfKinsContactAddress) {
                          userData["Next of kin's contact address"] = nextOfKinsContactAddressController.text;
                        }

                        if (userData.isNotEmpty) {
                          final updateDataResult = await firebaseProvider.updateData('UserInformation', userProvider.currentUser?.userId, userData);
                          if (updateDataResult['status'] == 'success') {
                            userProfileProvider.updateUserProfile(
                                meansOfId: userProfileProvider.currentUserProfile?.meansOfId,
                                nextOfKinsContactAddress: updatednextOfKinsContactAddress,
                                issueDate: userProfileProvider.currentUserProfile?.issueDate,
                                expiryDate: userProfileProvider.currentUserProfile?.expiryDate,
                                nextOfKinsFullname: updatednextOfKinsFullname,
                                idNumber: userProfileProvider.currentUserProfile?.idNumber,
                                nextOfKinsEmail: updatednextOfKinsEmail,
                                nextOfKinsPhoneno: updatednextOfKinsPhoneno,
                                relationshipNOK: updatedrelationshipNOK,
                                maritalStatus: userProfileProvider.currentUserProfile?.maritalStatus,
                                residentialAddress: userProfileProvider.currentUserProfile?.residentialAddress,
                                phoneNo: userProfileProvider.currentUserProfile?.phoneNo,
                                accountNumber: userProfileProvider.currentUserProfile?.accountNumber,
                                bankAccountName: userProfileProvider.currentUserProfile?.bankAccountName,
                                bank: userProfileProvider.currentUserProfile?.bank,
                                regStatus: userProfileProvider.currentUserProfile?.regStatus,
                                profilePictureUrl: userProfileProvider.currentUserProfile?.profilePictureUrl
                            );
                            showTopSnackBar(
                              context: context,
                              title: 'Success',
                              message: 'Next of Kin\'s details have been updated successfully',
                            );
                          }
                        }
                      }
                      else{
                        showTopSnackBar(
                          context: context,
                          title: 'Note:',
                          message: 'No changes were made',
                        );
                      }
                      setState(() {
                        isloading = false;
                      });
                      print(userProfileProvider.currentUserProfile?.relationshipNOK);
                    }
                    else{
                      showInternetLostSnackbar();
                      setState(() {
                        nextOfKinsFullnameController.text = nokFullName;
                        relationshipNOKController.text = relationship;
                        nextOfKinsPhonenoController.text = nokPhoneNo;
                        nextOfKinsEmailController.text = nokEmail;
                        nextOfKinsContactAddressController.text = nokContactAddress;
                      });
                    }
                  }
                  ),
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }
}

