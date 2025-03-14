
import 'dart:async';
import 'dart:math';

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
import 'package:shelterstocks_prototype2/common/helpers/functions/getScale.dart';
import 'package:shelterstocks_prototype2/common/widgets/buttons/buttons.dart';
import 'package:shelterstocks_prototype2/common/widgets/buttons/goBackBtn.dart';
import '../../../../../../common/widgets/flush_bar/Flushbar.dart';
import '../../../../../../common/widgets/profile_components/userProfileItem.dart';
import '../../../../../provider/profile/user_profile/profileData.dart';
import '../../../../../provider/user/userData.dart';
import '../../../../../provider/firebase/firebaseData.dart';


class meansOfIdPage extends StatefulWidget {
  static String id = 'meansOfIdPage_screen';
  const meansOfIdPage({super.key});

  @override
  State<meansOfIdPage> createState() => _meansOfIdPageState();
}

class _meansOfIdPageState extends State<meansOfIdPage> with WidgetsBindingObserver{
  late final userProvider;
  late final userProfileProvider;
  bool showSpinner = true;
  bool isloading = false;
  bool readOnly = false;
  bool isConnectedToInternet = false;
  final TextEditingController meansOfIdController = TextEditingController();
  final TextEditingController idNumberController = TextEditingController();
  final TextEditingController issueDateController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  String updatedMeansOfId = '';
  String updatedIdNumber = '';
  String updatedIssueDate = '';
  String updatedExpiryDate = '';


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
  // String? firstName;

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
    String meansOfId = '${userProfileProvider.currentUserProfile?.meansOfId}';
    String idNumber = userProfileProvider.currentUserProfile?.idNumber;
    String issueDate = userProfileProvider.currentUserProfile?.issueDate;
    String expiryDate = userProfileProvider.currentUserProfile?.expiryDate;
    meansOfIdController.text = meansOfId;
    idNumberController.text = idNumber;
    issueDateController.text = issueDate;
    expiryDateController.text = expiryDate;
    if(showSpinner){
      return Center(
        child: CircularProgressIndicator(color: Colors.white,),
      );
    }
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
                'Means of Identification',
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
                      if(isConnectedToInternet) {
                        _updateReadOnlyStatus();
                      }
                    });
                    return
                      Text(
                          isConnectedToInternet?'Please complete your registration to edit fields.':'Please connect to the internet to edit fields',
                        style: TextStyle(
                          color: Colors.red,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w700,
                        ),
                      );
                  } else {
                    return Text(
                      'Tap to edit Identification details.',
                      style: TextStyle(
                          color: Color(0xFF1A1AFF),
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w900,
                      ),
                    ); // Return an empty widget if regStatus is true
                  }
                },

              ),
              //here
              Flexible(child: ListView(
                children: [
                  userProfileItem(
                    profileItemHeader: 'Means of Identification',
                    profileItem:
                    Flexible(
                      child: SizedBox(
                        height: 25,
                        child:
                        TextField(
                          controller: meansOfIdController,
                          readOnly: readOnly,
                          style: TextStyle(
                              fontSize: isTablet?10*getScale(context):(16.sp),
                              color: Colors.grey,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            hintText: 'Enter means of ID',
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
                      profileItemHeader: 'ID Number',
                      profileItem:
                      Flexible(
                        child: SizedBox(
                          height: 25,
                          child: TextField(
                            controller: idNumberController,
                            readOnly: readOnly,
                            style: TextStyle(
                              fontSize: isTablet?10*getScale(context):(16.sp),
                                color: Colors.grey,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              hintText: 'Enter ID Number',
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
                    profileItemHeader: 'Issue Date',
                    profileItem:
                    Flexible(
                      child: SizedBox(
                        height: 25,
                        child: TextField(
                          controller: issueDateController,
                          readOnly: readOnly,
                          style: TextStyle(
                            fontSize: isTablet?10*getScale(context):(16.sp),
                              color: Colors.grey,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            hintText: 'Enter issue date',
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
                    profileItemHeader: 'Expiry Date',
                    profileItem:
                    Flexible(
                      child: SizedBox(
                        height: 25,
                        child: TextField(
                          controller: expiryDateController,
                          readOnly: readOnly,
                          style: TextStyle(
                            fontSize: isTablet?10*getScale(context):(16.sp),
                              color: Colors.grey,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            hintText: 'Enter expiry date',
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
                        updatedMeansOfId = toTitleCase(meansOfIdController.text.trim());
                        updatedIdNumber = idNumberController.text.trim();
                        updatedIssueDate = issueDateController.text.trim();
                        updatedExpiryDate = expiryDateController.text.trim();
                      });
                      if (meansOfId != updatedMeansOfId || idNumber != updatedIdNumber || issueDate != updatedIssueDate || expiryDate != updatedExpiryDate) {
                        final firebaseProvider = Provider.of<FirebaseProvider>(context, listen: false);
                        Map<String, dynamic> userData = {};
                        if (meansOfId != updatedMeansOfId) {
                          userData["Means of Identification"] = (meansOfIdController.text);
                        }
                        if (idNumber != updatedIdNumber) {
                          userData["ID Number"] = idNumberController.text;
                        }
                        if (issueDate != updatedIssueDate) {
                          userData["Issue Date"] = issueDateController.text;
                        }
                        if (expiryDate != updatedExpiryDate) {
                          userData["Expiry Date"] = expiryDateController.text;
                        }

                        if (userData.isNotEmpty) {
                          final updateDataResult = await firebaseProvider.updateData('UserInformation', userProvider.currentUser?.userId, userData);
                          if (updateDataResult['status'] == 'success') {
                            userProfileProvider.updateUserProfile(
                                meansOfId: updatedMeansOfId,
                                nextOfKinsContactAddress: userProfileProvider.currentUserProfile?.nextOfKinsContactAddress,
                                issueDate: updatedIssueDate,
                                expiryDate: updatedExpiryDate,
                                nextOfKinsFullname: userProfileProvider.currentUserProfile?.nextOfKinsFullname,
                                idNumber: updatedIdNumber,
                                nextOfKinsEmail: userProfileProvider.currentUserProfile?.nextOfKinsEmail,
                                nextOfKinsPhoneno: userProfileProvider.currentUserProfile?.nextOfKinsPhoneno,
                                relationshipNOK: userProfileProvider.currentUserProfile?.relationshipNOK,
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
                              message: 'Identification details have been updated successfully',
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
                    }
                    else{
                      showInternetLostSnackbar();
                      setState(() {
                        meansOfIdController.text = meansOfId;
                        idNumberController.text = idNumber;
                        issueDateController.text = issueDate;
                        expiryDateController.text = expiryDate;
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

