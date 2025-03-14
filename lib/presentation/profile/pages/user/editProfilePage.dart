
import 'dart:async';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:provider/provider.dart';
import 'package:shelterstocks_prototype2/common/helpers/functions/getScale.dart';
import 'package:shelterstocks_prototype2/common/widgets/buttons/ExploreButtons.dart';
import 'package:shelterstocks_prototype2/common/widgets/buttons/buttons.dart';
import 'package:shelterstocks_prototype2/common/widgets/buttons/goBackBtn.dart';
import 'package:shelterstocks_prototype2/common/widgets/input_field/inputfields.dart';
import 'package:shelterstocks_prototype2/presentation/provider/notification/notificationData.dart';

import '../../../../common/widgets/flush_bar/Flushbar.dart';
import '../../../../common/widgets/profile_components/profilePicture.dart';
import '../../../../common/widgets/profile_components/userProfileItem.dart';
import '../../../provider/profile/user_profile/profileData.dart';
import '../../../provider/transactions/transactionData.dart';
import '../../../provider/user/userData.dart';
import '../../../provider/firebase/firebaseData.dart';
import '../../../intro/pages/ShelterStocksGetStartedScreen.dart';
import 'package:image_picker/image_picker.dart';



class editProfilePage extends StatefulWidget {
  static String id = 'editProfilePage_screen';
  const editProfilePage({super.key});

  @override
  State<editProfilePage> createState() => _profilePageState();
}

class _profilePageState extends State<editProfilePage> with WidgetsBindingObserver{
  late final userProvider;
  late final userProfileProvider;
  bool showSpinner = true;
  bool isloading = false;
  bool _authLoad = false;
  String? newProfileImageUrl;
  bool isConnectedToInternet = false;
  bool isPressed = false;


  String toTitleCase(String str) {
    if (str.isEmpty) return str;
    return str[0].toUpperCase() + str.substring(1).toLowerCase();
  }

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneNoController = TextEditingController();
  final TextEditingController userIDController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController userIdController = TextEditingController();


  String updatedName = '';
  String updatedEmail = '';
  String updatedPhoneNo = '';

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
    // TODO: implement didChangeDependencies
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
    String name = '${userProvider.currentUser?.firstName} ${userProvider.currentUser?.lastName}';
    String email = '${userProvider.currentUser?.email}';
    String phoneNo = '${userProfileProvider.currentUserProfile?.phoneNo}';
    String currentProfileImageUrl = userProfileProvider.currentUserProfile?.profilePictureUrl;
    nameController.text = name;
    phoneNoController.text = phoneNo;
    emailController.text = email;
    userIDController.text = '${userProvider.currentUser?.userId}';
    if(showSpinner){
      return Center(
        child: CircularProgressIndicator(color: Colors.white,),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child:
        Container(
          margin: EdgeInsets.only(top: isSmallPhone?15.0*getScale(context):30.0*getScale(context),left: 20.0*getScale(context), right: 20.0*getScale(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              goBackBtn(size: 25,),
              SizedBox(
                height: 20,
              ),
              Text(
                'MY PROFILE',
                style: TextStyle(
                    fontSize: isTablet?12*getScale(context):(isSmallPhone?20*getScale(context):(20.sp)),
                  fontWeight: FontWeight.bold
                ),
              ),
              Text(
                'Tap to edit profile details.',
                style: TextStyle(
                    fontSize: isTablet?10*getScale(context):(13.sp),
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1AFF)
                ),
              ),
              SizedBox(height: 10,),
              Flexible(
                child: ListView(
                  children: [
                    userProfileItem(
                      profileItemHeader: 'USER ID',
                      profileItem:
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: SizedBox(
                            height: 25.sp,
                            child: TextField(
                              controller: userIDController,
                              readOnly: true,
                              style: TextStyle(
                                  fontSize: isTablet?10*getScale(context):(14.sp),
                                  color: Colors.grey
                              ),
                              textAlign: TextAlign.right,
                              decoration: InputDecoration(
                                hintText: 'Enter Name',
                                hintStyle: TextStyle(
                                    fontSize: isTablet?10*getScale(context):13.sp,
                                    color: Colors.grey
                                ),
                                border: InputBorder.none,
                              ),

                            ),
                          ),
                        ),
                      ),

                    ),

                    userProfileItem(
                        profileItemHeader: 'DISPLAY PICTURE',
                        profileItem:isConnectedToInternet?
                        profilePicture(
                          imageUrl: newProfileImageUrl ?? currentProfileImageUrl,
                          onTap: _handleProfilePictureTap,
                        ):Center(
                          child: CircularProgressIndicator(
                            color: Colors.blue,
                          ),
                        ),
                    ),

                    userProfileItem(
                      profileItemHeader: 'Name',
                      profileItem:
                      Flexible(
                        child: SizedBox(
                          height: 25,
                          child:
                          TextField(
                            onChanged: (value) {
                              final text = nameController.text; // Get current text
                              final selection = nameController.selection; // Get current selection
                              nameController.value = TextEditingValue(
                                text: value, // Update text
                                selection: selection, // Keep the same selection
                              );
                            },
                            controller: nameController,
                            readOnly: false,
                            style: TextStyle(
                                fontSize: isTablet?10*getScale(context):14.sp,
                                color: Colors.grey
                            ),
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              hintText: 'Enter Name',
                              hintStyle: TextStyle(
                                  fontSize: isTablet?10*getScale(context):14.sp,
                                  color: Colors.grey
                              ),
                              border: InputBorder.none,
                            ),

                          ),
                        ),
                      )

                    ),

                    Consumer<profileData>(
                      builder: (context, userProvider, child) {
                        if (userProvider.currentUserProfile?.regStatus == true) {
                          return
                            userProfileItem(
                              profileItemHeader: 'Phone Number',
                              profileItem:
                              Flexible(
                                child: SizedBox(
                                  height: 25,
                                  child: TextField(
                                    onChanged: (value) {
                                      final text = phoneNoController.text; // Get current text
                                      final selection = phoneNoController.selection; // Get current selection
                                      phoneNoController.value = TextEditingValue(
                                        text: value, // Update text
                                        selection: selection, // Keep the same selection
                                      );
                                    },
                                    controller: phoneNoController,
                                    readOnly: false,
                                    style: TextStyle(
                                        fontSize: isTablet?10*getScale(context):14.sp,
                                        color: Colors.grey
                                    ),
                                    textAlign: TextAlign.right,
                                    decoration: InputDecoration(
                                      hintText: 'Enter phone nummber',
                                      hintStyle: TextStyle(
                                          fontSize: isTablet?10*getScale(context):14.sp,
                                          color: Colors.grey
                                      ),
                                      border: InputBorder.none,
                                    ),

                                  ),
                                ),
                              )
                            );
                        } else {
                          return  userProfileItem(
                            profileItemHeader: 'Phone Number',
                            profileItem: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  FontAwesomeIcons.circleExclamation,
                                  color: Colors.red,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'COMPLETE REGISTERATION',
                                  style: TextStyle(
                                      fontSize: isTablet?10*getScale(context):14.sp,
                                      color: Colors.red
                                  ),
                                ),
                              ],
                            ),
                          ); // Return an empty widget if regStatus is true
                        }
                      },
                    ),

                    //new changes from ogbeish
                    userProfileItem(
                      profileItemHeader: 'Email',
                      profileItem: Flexible(
                        child: SizedBox(
                          height: 25,
                          child: TextField(
                            onChanged: (value) {
                              final text = emailController.text; // Get current text
                              final selection = emailController.selection; // Get current selection
                              emailController.value = TextEditingValue(
                                text: value, // Update text
                                selection: selection, // Keep the same selection
                              );
                            },
                            controller: emailController,
                            readOnly: false,
                            style: TextStyle(
                                fontSize: isTablet?10*getScale(context):14.sp,
                                color: Colors.grey
                            ),
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              hintText: 'anything',
                              hintStyle: TextStyle(
                                  fontSize: isTablet?10*getScale(context):14.sp,
                                  color: Colors.grey
                              ),
                              border: InputBorder.none,
                            ),

                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: isSmallPhone?30*getScale(context):(35.h),
                    ),
                    Buttons(width: double.infinity, buttonText: 'Finish',buttonTextColor: Colors.white, buttonColor: Color(0xFF1A1AFF), isLoading: isloading,isPressed:isPressed,onPressed: ()async{
                      if(isConnectedToInternet){
                        setState(() {
                          isloading = true;
                          isPressed=true;
                          updatedName = nameController.text.trim();
                          updatedEmail = emailController.text.trim();
                          updatedPhoneNo = phoneNoController.text.trim();
                        });
                        passwordController.clear();

                        String name = '${userProvider.currentUser?.firstName} ${userProvider.currentUser?.lastName}';
                        String email = '${userProvider.currentUser?.email}';
                        String phoneNo = '${userProfileProvider.currentUserProfile?.phoneNo}';
                        String currentProfileImageUrl = userProfileProvider.currentUserProfile?.profilePictureUrl;

                        if (name != updatedName || phoneNo != updatedPhoneNo || updatedEmail != email || newProfileImageUrl != null) {
                          String nameChangeStatus = '';
                          String phoneChangeStatus = '';
                          String profilePictureChangeStatus = '';
                          final firebaseProvider = Provider.of<FirebaseProvider>(context, listen: false);

                          Map<String, dynamic> userData = {};

                          if (name != updatedName) {
                            if(updatedName.split(' ').length >= 2){
                              String firstName = toTitleCase(updatedName.split(' ')[0]);
                              String lastName = toTitleCase(updatedName.split(' ')[1]);
                              userData["firstName"] = firstName;
                              userData["lastName"] = lastName;
                            }
                          else{
                            setState(() {
                              isPressed = false;
                              isloading = false;
                            });
                            showTopSnackBar(context: context, title: 'Error', message: "Please enter full name");
                            return;
                          }
                          }


                          if (phoneNo != updatedPhoneNo) {
                            userData["Phone Number"] = updatedPhoneNo;
                          }

                          if (newProfileImageUrl != null && newProfileImageUrl != currentProfileImageUrl) {
                            userData["profileImageUrl"] = newProfileImageUrl;
                          }

                          if (userData.isNotEmpty) {
                            final updateDataResult = await firebaseProvider.updateData('UserInformation', userProvider.currentUser?.userId, userData);
                            if (updateDataResult['status'] == 'success') {
                              if (userData.containsKey("firstName")) {
                                userProvider.updateUser(
                                  userData["firstName"],
                                  userData["lastName"],
                                  userProvider.currentUser?.email,
                                  userProvider.currentUser?.password,
                                  userProvider.currentUser?.userId,
                                  userProvider.currentUser?.stockUnits,
                                  userProvider.currentUser?.stockValue,
                                  userProvider.currentUser?.fCMToken
                                );
                                nameChangeStatus = 'success';
                              }
                              if (userData.containsKey("Phone Number")) {
                                userProfileProvider.updateUserProfile(
                                    meansOfId: userProfileProvider.currentUserProfile?.meansOfId,
                                    nextOfKinsContactAddress: userProfileProvider.currentUserProfile?.nextOfKinsContactAddress,
                                    issueDate: userProfileProvider.currentUserProfile?.issueDate,
                                    expiryDate: userProfileProvider.currentUserProfile?.expiryDate,
                                    nextOfKinsFullname: userProfileProvider.currentUserProfile?.nextOfKinsFullname,
                                    idNumber: userProfileProvider.currentUserProfile?.idNumber,
                                    nextOfKinsEmail: userProfileProvider.currentUserProfile?.nextOfKinsEmail,
                                    nextOfKinsPhoneno: userProfileProvider.currentUserProfile?.nextOfKinsPhoneno,
                                    relationshipNOK: userProfileProvider.currentUserProfile?.relationshipNOK,
                                    maritalStatus: userProfileProvider.currentUserProfile?.maritalStatus,
                                    residentialAddress: userProfileProvider.currentUserProfile?.residentialAddress,
                                    phoneNo: updatedPhoneNo,
                                    accountNumber: userProfileProvider.currentUserProfile?.accountNumber,
                                    bankAccountName: userProfileProvider.currentUserProfile?.bankAccountName,
                                    bank: userProfileProvider.currentUserProfile?.bank,
                                    regStatus: userProfileProvider.currentUserProfile?.regStatus,
                                    profilePictureUrl: userProfileProvider.currentUserProfile?.profilePictureUrl
                                );
                                phoneChangeStatus = 'success';
                              }
                              if (userData.containsKey("profileImageUrl")) {
                                userProfileProvider.updateUserProfile(
                                    meansOfId: userProfileProvider.currentUserProfile?.meansOfId,
                                    nextOfKinsContactAddress: userProfileProvider.currentUserProfile?.nextOfKinsContactAddress,
                                    issueDate: userProfileProvider.currentUserProfile?.issueDate,
                                    expiryDate: userProfileProvider.currentUserProfile?.expiryDate,
                                    nextOfKinsFullname: userProfileProvider.currentUserProfile?.nextOfKinsFullname,
                                    idNumber: userProfileProvider.currentUserProfile?.idNumber,
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
                                    profilePictureUrl: newProfileImageUrl
                                );
                                profilePictureChangeStatus = 'success';
                              }
                            }
                          }

                          if (nameChangeStatus == 'success' || phoneChangeStatus == 'success' || profilePictureChangeStatus == 'success') {
                            showTopSnackBar(
                              context: context,
                              title: 'Success',
                              message: 'Profile has been updated successfully',
                            );
                          }

                          if (updatedEmail != email) {
                            openReAuthDialog();
                          }
                        } else {
                          showTopSnackBar(
                            context: context,
                            title: 'Note:',
                            message: 'No changes were made',
                          );
                        }
                        setState(() {
                          isPressed = false;
                          isloading = false;
                        });
                      }
                      else{
                        showInternetLostSnackbar();
                        setState(() {
                          isPressed = false;
                          nameController.text = name;
                          phoneNoController.text = phoneNo;
                          emailController.text = email;
                        });
                      }
                    }
                    ,)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _handleProfilePictureTap() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    try {
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef.child('${userProvider.currentUser?.userId} Profile Picture.jpg');
      final imageBytes = await image.readAsBytes();
      await imageRef.putData(imageBytes);

      final String downloadUrl = await imageRef.getDownloadURL();
      setState(() {
        newProfileImageUrl = downloadUrl;
        // isloading = false;
      });
    } catch (e) {
      print('Error uploading image: $e');
      setState(() {
        // isloading = false;
      });
      showTopSnackBar(
        context: context,
        title: 'Error',
        message: 'Failed to upload image. Please try again.',
      );
    }
  }
  //show logout dialog
  Future openLogoutDialog()=>showDialog(
      context: context,
      builder: (context)=>
          AlertDialog(
        title:
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To complete your email change:',
              style: TextStyle(
                // fontSize: 30,
                  color: Colors.black
              ),
            ),
            SizedBox(height: 10,),
            Text(
              'A verification email has been sent ${updatedEmail}. Please check your email and verify the address. After verification, use the "Logout" button below to sign out, then sign in again with your new email.',
              style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 18
              ),
            ),
            SizedBox(height: 10,),
            Text(
              'Note: The verification link is valid for 24 hours.',
              style: TextStyle(
                // color: Color(0xFF1A1AFF),
                  color: Colors.grey.shade900,
                  fontSize: 18

              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              onPressed: (){
                print('closed');
                Navigator.pop(context);
              }, child: Text('Close')
          ),
          TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFF1A1AFF),
              ),
              onPressed: (){
                setState(() {
                  _authLoad = true;
                });
                final firebaseProvider = Provider.of<FirebaseProvider>(
                    context, listen: false);
                final transactionsProvider = Provider.of<transactionData>(context, listen: false);
                final notificationsProvider = Provider.of<notificationData>(context, listen: false);

                firebaseProvider.signOut(transactionsProvider, notificationsProvider);
                Navigator.of(context).pushNamedAndRemoveUntil(
                  getStartedScreen.id,
                      (Route<dynamic> route) => false,
                ).then((_){
                  setState(() {
                    _authLoad = false;
                  });
                });
                // CircularProgressIndicator(
                //   color: Colors.white,
                // ),
              },
              child: _authLoad?CircularProgressIndicator(
                color: Color(0xFF1A1AFF),
              ):Text('Logout')
          )
        ],
      )
  );

  //open reauthentication dialog
  Future openReAuthDialog()=> showDialog(
      context: context,
      builder: (context)=> StatefulBuilder(
        builder: (context, setState){
        return
  AlertDialog(
          title: Container(
              margin:  EdgeInsets.symmetric(horizontal: 15),
              child: Text('Enter your password to change your email')),
          content: Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              child: InputField(autoFocus: true,obscureText: true, isPassword: true, hintText: 'Enter your password',textfieldWidth: double.infinity, controller_: passwordController,)),
          actions: [
            Buttons(buttonText: 'Submit',isPressed:isPressed,buttonColor: Color(0xFF1A1AFF), buttonTextColor: Colors.white, width: double.infinity, isLoading: _authLoad,onPressed: ()async{
              if(isConnectedToInternet){
                setState(() {
                  isPressed = true;
                  _authLoad = true;
                });
                Future.delayed(Duration(seconds: 2),() async{
                  final firebaseProvider = Provider.of<FirebaseProvider>(
                      context, listen: false);
                  if(passwordController.text.isNotEmpty){
                    String authResult = await firebaseProvider.reauthenticateUser(userProvider.currentUser?.email, passwordController.text);
                    if(authResult.contains('Reauthentication successful!')){
                      print('success auth result: ${ authResult}');
                      final result = await firebaseProvider.updateEmail(updatedEmail);
                      if(result['status'] == 'success'){
                        setState(() {
                          _authLoad = false;
                          isPressed = false;
                        });
                        Navigator.pop(context);
                        openLogoutDialog();
                      }
                      else{
                        setState(() {
                          _authLoad = false;
                          isPressed = false;
                        });
                        showTopSnackBar(
                          context: context,
                          title: 'Error',
                          message: result['message']??'An error occurred. Please try again',
                        );
                      }
                    }
                    else{
                      setState(() {
                        isPressed = false;
                        _authLoad = false;
                      });
                      print('failed auth result: ${ authResult}');
                      showTopSnackBar(
                        context: context,
                        title: 'Error',
                        message: 'Incorrect Password',
                      );
                    }
                  }
                  else{
                    setState(() {
                      isPressed = false;
                      _authLoad = false;
                    });
                    print('please fill password');
                    showTopSnackBar(context: context, title: 'Error:', message: 'Please enter password');
                  }
                });
              }
              else{
                showInternetLostSnackbar();
              }
            },),
            SizedBox(
              height: 5,
            ),
            Buttons(buttonText: 'Close', buttonColor: Colors.red, buttonTextColor: Colors.white, width: double.infinity,onPressed: ()async{
              setState(() {
                isPressed = false;
                _authLoad = false;
              });
              Navigator.pop(context);
            },),
          ],
        );
        },
      )
  );
}

