import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:shelterstocks_prototype2/common/helpers/functions/getScale.dart';
import 'package:shelterstocks_prototype2/common/widgets/buttons/buttons.dart';
import 'package:shelterstocks_prototype2/common/widgets/input_field/inputfields.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shelterstocks_prototype2/presentation/provider/transactions/transactionData.dart';
import 'package:shelterstocks_prototype2/presentation/provider/notification/notificationData.dart';
import 'package:shelterstocks_prototype2/presentation/auth/pages/user/signUpScreen.dart';
import 'package:shelterstocks_prototype2/presentation/auth/pages/admin/adminLogin.dart';
import 'package:shelterstocks_prototype2/presentation/dashboard/pages/user/dashBoardScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shelterstocks_prototype2/presentation/auth/pages/user/resumeAppScreen.dart';
import '../../../../common/widgets/flush_bar/Flushbar.dart';
import 'ForgotPassword.dart';
import '../../../../common/widgets/buttons/goBackBtn.dart';
import '../../../provider/profile/user_profile/profileData.dart';
import '../../../provider/user/userData.dart';
import '../../../../data/api/firebase_messaging/firebaseApi.dart';
import '../../../provider/firebase/firebaseData.dart';

class Loginscreen extends StatefulWidget {
  static String id = 'Login_screen';
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  bool showSpinner = false;
  bool isPressed = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String email = '';
  String password = '';

  String extractFirebaseErrorMessage(String errorMessage) {
    // Split the error message using the closing bracket ']'
    int startIndex = errorMessage.indexOf(']') + 1;

    // If the bracket was found, return the part after it, otherwise return the original message
    if (startIndex > 0 && startIndex < errorMessage.length) {
      return errorMessage.substring(startIndex).trim();
    } else {
      return errorMessage; // Return the full message if the pattern doesn't match
    }
  }
  String toTitleCase(String str) {
    if (str.isEmpty) return str;
    return str[0].toUpperCase() + str.substring(1).toLowerCase();
  }



  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child:
        SafeArea(
          child:
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                            onTap: () => Navigator.pop(context),
                                            child: Container(
                                              alignment: Alignment.topLeft,
                                              child: Icon(
                                                  FontAwesomeIcons.arrowLeft,
                                                  color: Color(0xFF1A1AFF), size: 25),
                                            ),
                            ),
                            //sign in as admin
                            GestureDetector(
                              onTap: (){
                                Navigator.pushNamed(context, Adminlogin.id);
                              },
                              child: Row(
                                children: [
                                  Text('Admin',style: TextStyle(
                                    color: Color(0xFF1A1AFF),
                                    fontSize: 15*getScale(context)
                                  ),),
                                  Icon(
                                    Icons.admin_panel_settings,
                                    color: Color(0xFF1A1AFF),
                                    size: 20*getScale(context),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image(
                              image: AssetImage('images/ShelterStock splashscreen logo.png'),
                              height: 80,
                              width: 160,
                              alignment: Alignment.center,
                            ),
                            SizedBox(
                              height: 40.h,
                            ),
                            Text('Login to your account'),
                            SizedBox(
                              height: 5.h,
                            ),
                            Text('Securely login to your ShelterStocks'),
                            SizedBox(
                              height: 40.h,
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    //type email
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Email'),
                                        SizedBox(
                                          height: 5.h,
                                        ),
                                        InputField(obscureText: false, textfieldWidth: 300.w, hintText: 'e.g daniel@gmail.com', inputType: TextInputType.emailAddress, controller_: emailController,),
                    
                                      ],
                                    ),
                                    SizedBox(
                                      height: 40.h,
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Your Password'),
                                        SizedBox(
                                          height: 5.h,
                                        ),
                                        InputField(obscureText: true, textfieldWidth: 300.w, hintText: 'Enter your password', controller_: passwordController, isPassword: true,),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5.h,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('Forgot Password?'),
                                        TextButton(onPressed: (){
                                          Navigator.push(context, MaterialPageRoute(builder: (context)=> Forgotpassword()));
                                        }, child: Text(
                                            'reset'
                                        ))
                                      ],
                                    ),// SizedBox(
                    
                                    // ),
                                    SizedBox(
                                      height: 5.h,
                                    ),
                    
                                    Buttons(
                                      width: 300.w,
                                      buttonText: 'LOGIN',
                                      buttonColor: Color(0xFF1A1AFF),
                                      buttonTextColor: Colors.white,
                                      isPressed: isPressed,
                                      onPressed: () async {
                                        setState(() {
                                          isPressed = true;
                                          email = emailController.text.trim();
                                          password = passwordController.text.trim();
                                        });

                                        if (password.isNotEmpty && email.isNotEmpty) {
                                          setState(() {
                                            showSpinner = true;
                                          });
                                          final firebaseProvider = Provider.of<FirebaseProvider>(
                                              context, listen: false);
                                          final transactionsProvider = Provider.of<transactionData>(
                                              context, listen: false);
                                          final notificationsProvider = Provider.of<notificationData>(
                                              context, listen: false);
                                          final result = await firebaseProvider.signIn(email, password);

                                          String deviceToken = await FirebaseApi().getFCMToken();
                                          print('token upon login: $deviceToken');
                                          // Check if login was successful
                                          if (result['user'] != null) {
                                            final loggedinUser = result['user'] as User;
                                            // Get user ID
                                            String? userId = loggedinUser.uid;
                                            // Fetch user data from Firestore
                                            DocumentSnapshot currentUserDoc =
                                            await firebaseProvider.fetchData('UserInformation', userId);
                                            await firebaseProvider.updateData('UserInformation', userId,
                                                {
                                                  'fCMToken':deviceToken
                                                });
                                            bool fetchTransaction = await transactionsProvider.fetchTransaction(userId);
                                            if(fetchTransaction){
                                              print('Fetch transaction was successful');
                                            }
                                            else{
                                              print('Unable to fetch transaction');
                                            }
                                            bool fetchNotification = await notificationsProvider.fetchNotification(userId, 'Notifications');
                                            if(fetchNotification){
                                              print('Fetch notifications was successful');
                                            }
                                            else{
                                              print('Unable to fetch notifications');
                                            }
                                            if (currentUserDoc.exists) {

                                              final userProvider = Provider.of<UserData>(context, listen: false);
                                              final currentUserProfileProvider = Provider.of<profileData>(context, listen: false);
                                              // Correctly assign the fields
                                              String firstName = toTitleCase(currentUserDoc['firstName']);
                                              String lastName = toTitleCase(currentUserDoc['lastName']); // Fixed typo here
                                              String? email = loggedinUser.email;
                                              String _password = password;
                                              // NEWLY ADDED
                                              double? stockUnits = currentUserDoc['stockUnits'];
                                              double? stockValue = currentUserDoc['stockValue'];
                                              userProvider.updateUser(firstName, lastName, email!, _password,currentUserDoc.id,stockUnits!, stockValue!, deviceToken);
                                              final prefs = await SharedPreferences.getInstance();
                                              await prefs.setString('password', password);
                                              String? maritalStatus = currentUserDoc['Marital Status']??'';
                                              String? residentialAddress = currentUserDoc['Residential Address']??'';
                                              String? phoneNo = currentUserDoc['Phone Number']??'';
                                              String? meansOfId = currentUserDoc['Means of Identification']??'';
                                              String? idNumber = currentUserDoc['ID Number']??'';
                                              String? issueDate = currentUserDoc['Issue Date']??'';
                                              String? expiryDate = currentUserDoc['Expiry Date']??'';
                                              String? nextOfKinsFullname = currentUserDoc['Next of kin\'s fullname']??'';
                                              String? relationshipNOK = currentUserDoc['Relationship with Next of kin']??'';
                                              String? nextOfKinsPhoneno = currentUserDoc['Next of kin\'s phone number']??'';
                                              String? nextOfKinsEmail = currentUserDoc['Next of kin\'s email']??'';
                                              String? nextOfKinsContactAddress = currentUserDoc['Next of kin\'s contact address']??'';
                                              String? bankAccountName = currentUserDoc['Bank account name']??'';
                                              String? accountNumber = currentUserDoc['Account Number']??'';
                                              String? bank = currentUserDoc['Bank']??'';
                                              bool? regStatus = currentUserDoc['Completed registration']??false;
                                              String?profilePictureUrl = currentUserDoc['profileImageUrl']??'';
                                              currentUserProfileProvider.updateUserProfile(
                                                  meansOfId: meansOfId,
                                                  nextOfKinsContactAddress: nextOfKinsContactAddress,
                                                  issueDate: issueDate,
                                                  expiryDate: expiryDate,
                                                  nextOfKinsFullname: nextOfKinsFullname,
                                                  idNumber: idNumber,
                                                  nextOfKinsEmail: nextOfKinsEmail,
                                                  nextOfKinsPhoneno: nextOfKinsPhoneno,
                                                  relationshipNOK: relationshipNOK,
                                                  maritalStatus: maritalStatus,
                                                  residentialAddress: residentialAddress,
                                                  phoneNo: phoneNo,
                                                  accountNumber: accountNumber,
                                                  bankAccountName: bankAccountName,
                                                  bank: bank,
                                                  regStatus: regStatus,
                                                  profilePictureUrl: profilePictureUrl
                                              );
                                              print('fetched token: $deviceToken');
                                              //show spinner
                                              setState(() {
                                                showSpinner = false;
                                              });
                                              Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(builder: (context) => DashboardScreen()),
                                                    (Route<dynamic> route) => false,
                                              );
                                              setState(() {
                                                isPressed = false;
                                              });
                                            } else {
                                              setState(() {
                                                showSpinner = false;
                                                isPressed = false;
                                              });
                                              // print(userId);
                                              print('User document does not exist');
                                              showTopSnackBar(
                                                context: context,
                                                title: 'Login Failed:',
                                                message: 'Account does not exist',
                                              );
                                            }
                                          }
                                          else {
                                            setState(() {
                                              isPressed = false;
                                              showSpinner = false;
                                            });
                                            print('Login failed');
                                            showTopSnackBar(
                                              context: context,
                                              title: 'Error:',
                                              message: result['error'],
                                            );
                                          }
                                        } else {
                                          setState(() {
                                            isPressed = false;
                                            showSpinner = false;
                                          });
                                          print('Please fill all fields');
                                          showTopSnackBar(
                                            context: context,
                                            title: 'Error:',
                                            message: 'Please fill all fields',
                                          );
                                        }
                                        final prefs = await SharedPreferences.getInstance();
                                        var loggedOut = await prefs.getBool('isLoggedin');
                                        var isAdmin = await prefs.getBool('isAdmin');
                                        print('islogged in: ${loggedOut}');
                                        print('is admin? : ${isAdmin}');
                                      },
                                    ),
                    
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('Don\'t have an account?'),
                                        TextButton(onPressed: (){
                                          Navigator.pushNamed(context, Signupscreen.id);
                                        }, child: Text(
                                            'Register'
                                        ))
                                      ],
                                    )
                                  ],
                                ),
                              ),
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
        ),
      ),
    );
  }
}
