import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:shelterstocks_prototype2/presentation/provider/admin/adminData.dart';
import 'package:shelterstocks_prototype2/presentation/provider/sell_requests/sellRequestData.dart';
import 'package:shelterstocks_prototype2/presentation/dashboard/pages/admin/AdminDashboard.dart';
import 'package:shelterstocks_prototype2/presentation/auth/pages/user/signUpScreen.dart';
import 'package:shelterstocks_prototype2/presentation/auth/pages/admin/adminForgotPassword.dart';
import 'package:shelterstocks_prototype2/presentation/dashboard/pages/user/dashBoardScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shelterstocks_prototype2/presentation/auth/pages/user/resumeAppScreen.dart';
import '../../../../common/widgets/flush_bar/Flushbar.dart';
import '../user/ForgotPassword.dart';
import '../../../../common/widgets/buttons/goBackBtn.dart';
import '../../../provider/profile/user_profile/profileData.dart';
import '../../../provider/user/userData.dart';
import '../../../provider/firebase/firebaseData.dart';

class Adminlogin extends StatefulWidget {
  static String id = 'adminLogin_screen';
  const Adminlogin({super.key});

  @override
  State<Adminlogin> createState() => _AdminloginState();
}

class _AdminloginState extends State<Adminlogin> {
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
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: SafeArea(
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
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            alignment: Alignment.topLeft,
                            child: Icon(
                                FontAwesomeIcons.arrowLeft,
                                color: Color(0xFF1A1AFF), size: 25),
                          ),
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
                              height: 20*getScale(context),
                            ),
                            Text('LOGIN AS ADMIN', style: TextStyle(
                              fontSize: 20*getScale(context)
                            ),),
                            SizedBox(
                              height: 20*getScale(context),
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
                                        InputField(obscureText: false, textfieldWidth: 300.w, hintText: 'e.g admin@gmail.com', inputType: TextInputType.emailAddress, controller_: emailController,),

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
                                          Navigator.push(context, MaterialPageRoute(builder: (context)=> Adminforgotpassword()));
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


                                          final result = await firebaseProvider.signInAdmin(email, password);

                                          // Check if login was successful
                                          if (result['user'] != null) {
                                            final loggedinAdmin = result['user'] as User;
                                            String? adminId = loggedinAdmin.uid;
                                            // Fetch user data from Firestore
                                            DocumentSnapshot currentAdminDoc =
                                            await firebaseProvider.fetchData('AdminInformation', adminId);
                                            if (currentAdminDoc.exists) {
                                              if(currentAdminDoc['role'] == 'Administrator'){
                                                final AdminProvider = Provider.of<Admindata>(context, listen: false);
                                                final SellRequestProvider = Provider.of<Sellrequestdata>(context, listen: false);
                                                // Correctly assign the fields
                                                String? email = loggedinAdmin.email;
                                                String? role = currentAdminDoc['role'];
                                                AdminProvider.updateAdmin(email!, role!, adminId);
                                                await AdminProvider.fetchAndStoreAllUsersData();
                                                bool result = await SellRequestProvider.fetchUnapprovedSellRequest(adminId);
                                                if(result){
                                                  print('all sell request fetched successfully');
                                                }
                                                else{
                                                  print('error fetching sell requests');
                                                }
                                              }
                                              else{
                                                setState(() {
                                                  isPressed = false;
                                                  showSpinner = false;
                                                });
                                              }
                                              //show spinner
                                              setState(() {
                                                showSpinner = false;
                                              });

                                              Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(builder: (context) => Admindashboard()),
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
                                              print('Admin document does not exist');
                                              showTopSnackBar(
                                                context: context,
                                                title: 'Error:',
                                                message: 'Invalid Admin Credentials',
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


                                      },
                                    ),

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
