
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
import 'package:shelterstocks_prototype2/common/widgets/buttons/ExploreButtons.dart';
import 'package:shelterstocks_prototype2/common/widgets/buttons/buttons.dart';
import 'package:shelterstocks_prototype2/common/widgets/buttons/goBackBtn.dart';
import 'package:shelterstocks_prototype2/common/widgets/input_field/inputfields.dart';
import 'package:shelterstocks_prototype2/presentation/provider/admin/adminData.dart';

import '../../../../common/helpers/functions/getScale.dart';
import '../../../../common/widgets/flush_bar/Flushbar.dart';
import '../../../../common/widgets/profile_components/profilePicture.dart';
import '../../../../common/widgets/profile_components/userProfileItem.dart';
import '../../../provider/profile/user_profile/profileData.dart';
import '../../../provider/transactions/transactionData.dart';
import '../../../provider/user/userData.dart';
import '../../../provider/firebase/firebaseData.dart';
import '../../../intro/pages/ShelterStocksGetStartedScreen.dart';
import 'package:image_picker/image_picker.dart';



class Editadminprofilepage extends StatefulWidget {
  static String id = 'editAdminProfilePage_screen';
  const Editadminprofilepage({super.key});

  @override
  State<Editadminprofilepage> createState() => _EditadminprofilepageState();
}

class _EditadminprofilepageState extends State<Editadminprofilepage> with WidgetsBindingObserver{
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

  TextEditingController adminEmail = TextEditingController();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController userIdController = TextEditingController();


  String updatedEmail = '';

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
                'ADMINISTRATOR PROFILE',
                style: TextStyle(
                    fontSize: isTablet?12*getScale(context):(isSmallPhone?20*getScale(context):(20.sp)),
                  fontWeight: FontWeight.bold
                ),
              ),
              Text(
                'Tap to edit profile details.',
                style: TextStyle(
                    fontSize: isTablet?8*getScale(context):13.sp,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1AFF)
                ),
              ),
              SizedBox(height: 10*getScale(context),),
              Flexible(
                child: ListView(
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: isTablet?12*getScale(context):(20.sp), bottom: isTablet?12*getScale(context):(20.sp)),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: CupertinoColors.activeBlue, width: 2)
                          )
                      ),
                      child:
                      Consumer<Admindata>(
                          builder: (context, adminData, child) {
                            return
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'ADMIN ID',
                                    style: TextStyle(
                                        fontSize: isTablet?10*getScale(context):(14.sp),
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  Text(adminData.currentAdmin!.adminId!, style: TextStyle(
                                      fontSize: isTablet?10*getScale(context):(14.sp),
                                      color: Colors.grey
                                  ),)
                                ],
                              );
                          }
                      ),
                    ),

                    Consumer<Admindata>(
                        builder: (context, adminData, child) {
                          adminEmail.text = adminData.currentAdmin!.email!;
                          return
                            userProfileItem(
                              profileItemHeader: 'ADMIN EMAIL',
                              profileItem: Flexible(
                                child: SizedBox(
                                  height: 25,
                                  child: TextField(
                                    controller: adminEmail,
                                    readOnly: false,
                                    style: TextStyle(
                                        fontSize: isTablet?10*getScale(context):(14.sp),
                                        color: Colors.grey
                                    ),
                                    textAlign: TextAlign.right,
                                    decoration: InputDecoration(
                                      hintText: 'Enter email',
                                      hintStyle: TextStyle(
                                          fontSize: isTablet?10*getScale(context):(14.sp),
                                          color: Colors.grey
                                      ),
                                      border: InputBorder.none,
                                    ),

                                  ),
                                ),
                              ),
                            );
                        }
                    ),
                    SizedBox(
                      height: 35,
                    ),
                    Buttons(width: double.infinity, buttonText: 'Finish', buttonTextColor: Colors.white, buttonColor: Color(0xFF1A1AFF), isLoading: isloading,isPressed:isPressed,onPressed: ()async{
                      final adminProvider = Provider.of<Admindata>(context, listen: false);
                      String currentEmail = adminProvider.currentAdmin!.email!;
                      if(isConnectedToInternet){
                        setState(() {
                          isloading = true;
                          isPressed=true;
                          updatedEmail = adminEmail.text.trim();
                        });
                        passwordController.clear();
                        print(currentEmail);
                        if (updatedEmail != currentEmail) {
                          openReAuthDialog();
                          setState(() {
                            isPressed = false;
                            isloading = false;
                          });
                        } else {
                          setState(() {
                            isPressed = false;
                            isloading = false;
                          });
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
                          adminEmail.text = currentEmail;
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
                firebaseProvider.signOutAdmin('administrator');
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
                  final adminProvider = Provider.of<Admindata>(context, listen: false);
                  if(passwordController.text.isNotEmpty){
                    String authResult = await firebaseProvider.reauthenticateUser(adminProvider.currentAdmin!.email!, passwordController.text);
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

