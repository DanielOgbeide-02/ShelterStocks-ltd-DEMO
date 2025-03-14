import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shelterstocks_prototype2/common/helpers/functions/getScale.dart';
import 'package:shelterstocks_prototype2/common/widgets/buttons/buttons.dart';
import 'package:shelterstocks_prototype2/presentation/provider/transactions/transactionData.dart';
import 'package:shelterstocks_prototype2/presentation/provider/user/userData.dart';
import 'package:shelterstocks_prototype2/presentation/registeration/pages/before_signup/PersonalInfoScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shelterstocks_prototype2/common/widgets/flush_bar/Flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../common/widgets/buttons/goBackBtn.dart';
import '../../../../common/widgets/input_field/inputfields.dart';
import '../../../provider/profile/user_profile/profileData.dart';
import '../../../provider/user/userData.dart';
import '../../../provider/user/userData.dart';
import '../../../../data/api/firebase_messaging/firebaseApi.dart';
import '../../../provider/firebase/firebaseData.dart';

class Signupscreen extends StatefulWidget {
  static String id = 'SignUp_screen';
  const Signupscreen({super.key});

  @override
  State<Signupscreen> createState() => _SignupscreenState();
}

class _SignupscreenState extends State<Signupscreen> {
  bool isLoading = false;
  bool isPressed = false;
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passWordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

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

  // First and last name variables
  String firstName = '';
  String lastName = '';
  String email = '';
  String password = '';
  String confirmPassword = '';


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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.only(top: 50, left: 20, right: 20, bottom: isSmallPhone?5*getScale(context):0),
        // Entire screen
        child: Column(
          children: [
            // Welcome message
            Container(
              padding: EdgeInsets.only(bottom: 20),
              width: double.infinity,
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: Color(0xFF1A1AFF), width: 3.w))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Go to previous page
                  goBackBtn(size: 25,),
                  SizedBox(
                    height: 15.h,
                  ),
                  // Let's get started
                  Text(
                    'Let\'s get started 🎉',
                    style: TextStyle(
                        fontSize: isTablet?15*getScale(context):19*getScale(context), fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Text(
                    'Create an account to get started with ShelterStocks today!',
                    style: TextStyle(
                        fontSize: isTablet?12*getScale(context):17*getScale(context),
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),

                  )
                ],
              ),
            ),
            Flexible(
              child: ListView(
                children: [
                  // Field name
                  Text('First Name', style: TextStyle(
                    fontSize: isTablet?12*getScale(context):15*getScale(context),
                      fontWeight: FontWeight.bold
                  ),),
                  InputField(
                      hintText: 'e.g John',
                      controller_: firstNameController,
                      obscureText: false),
                  SizedBox(
                    height: 20.h,
                  ),
                  Text('Last Name',style: TextStyle(
                      fontSize: isTablet?12*getScale(context):15*getScale(context),
                      fontWeight: FontWeight.bold
                  ),),
                  InputField(
                      hintText: 'e.g Makuele',
                      controller_: lastNameController,
                      obscureText: false),
                  SizedBox(
                    height: 20.h,
                  ),
                  Text('Email',style: TextStyle(
                      fontSize: isTablet?12*getScale(context):15*getScale(context),
                      fontWeight: FontWeight.bold
                  ),),
                  InputField(
                    hintText: 'e.g johnmakuele@gmail.com',
                    controller_: emailController,
                    obscureText: false,
                    inputType: TextInputType.emailAddress,
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  Text('Password',style: TextStyle(
                      fontSize: isTablet?12*getScale(context):15*getScale(context),
                      fontWeight: FontWeight.bold
                  ),),
                  InputField(
                    hintText: 'Password',
                    controller_: passWordController,
                    obscureText: true,
                    isPassword: true,
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  Text('Confirm Password',style: TextStyle(
                      fontSize: isTablet?12*getScale(context):15*getScale(context),
                      fontWeight: FontWeight.bold
                  ),),
                  InputField(
                    hintText: 'Password',
                    controller_: confirmPasswordController,
                    obscureText: true,
                    isPassword: true,
                  ),

                  SizedBox(
                    height: 50.h,
                  ),

                  Buttons(
                      key: UniqueKey(), // Ensures rebuild
                      buttonText: 'Create Account',
                      width: double.infinity,
                      buttonColor: Color(0xFF1A1AFF),
                      buttonTextColor: Colors.white,
                      isLoading: isLoading,
                      isPressed: isPressed,
                      onPressed: () async {
                        setState(() {
                          isPressed = true;
                          isLoading = true;
                        });
                        try{
                          final firebaseProvider = Provider.of<FirebaseProvider>(
                              context, listen: false);
                          final currentUserProfileProvider = Provider.of<profileData>(context, listen: false);
                          firstName = toTitleCase(firstNameController.text);
                          lastName = toTitleCase(lastNameController.text);
                          email = emailController.text;
                          password = passWordController.text;
                          confirmPassword = confirmPasswordController.text;

                          if (firstName.isNotEmpty &&
                              lastName.isNotEmpty &&
                              email.isNotEmpty &&
                              password.isNotEmpty &&
                              confirmPassword.isNotEmpty) {
                            if (password == confirmPassword) {
                              final result = await firebaseProvider.signUp(email, password);
                              String token = await FirebaseApi().getFCMToken();
                              if (result['user'] != null && (token != 'No token found' && token != 'Error retrieving token')) {
                                final user = result['user'] as User;
                                print('this user token: $token');
                                // Prepare the user data map
                                Map<String, dynamic> userData = {
                                  "firstName": firstName,
                                  "lastName": lastName,
                                  "email": email,
                                  "fCMToken": token,
                                  // "password": password,
                                  //NEWLY ADDED
                                  "stockUnits":0.0,
                                  "stockValue": 0.0,
                                  'Marital Status':'',
                                  'Residential Address':'',
                                  'Phone Number':'',
                                  'Means of Identification':'',
                                  'ID Number':'',
                                  'Issue Date':'',
                                  'Expiry Date':'',
                                  'Next of kin\'s fullname':'',
                                  'Relationship with Next of kin':'',
                                  'Next of kin\'s phone number':'',
                                  'Next of kin\'s email':'',
                                  'Next of kin\'s contact address':'',
                                  'Bank account name':'',
                                  'Account Number':'',
                                  'Bank':'',
                                  "Completed registration": false,
                                  'profileImageUrl': '',
                                };
                                //send user information to the database
                                await firebaseProvider.addData('UserInformation',user.uid,userData);
                                // await firebaseProvider.addData('AdminInformation',user.uid,userData);
                                Provider.of<UserData>(context, listen: false).updateUser(firstName, lastName, email, password, user.uid ,userData['stockUnits'], userData['stockValue'],userData['fCMToken']);
                                currentUserProfileProvider.updateUserProfile(
                                    meansOfId: '',
                                    nextOfKinsContactAddress: '',
                                    issueDate: '',
                                    expiryDate: '',
                                    nextOfKinsFullname: '',
                                    idNumber: '',
                                    nextOfKinsEmail: '',
                                    nextOfKinsPhoneno: '',
                                    relationshipNOK: '',
                                    maritalStatus: '',
                                    residentialAddress: '',
                                    phoneNo: '',
                                    accountNumber: '',
                                    bankAccountName: '',
                                    bank: '',
                                    regStatus: false,
                                    profilePictureUrl: '',
                                );
                                Navigator.pushNamed(
                                    context, PersonalInfoScreen.id).then((_){
                                  setState(() {
                                    isPressed = false;
                                    isLoading = false;
                                  });
                                });
                              }
                              else{
                                setState(() {
                                  isPressed = false;
                                  isLoading = false;
                                });
                                print('sign up failed');
                                showTopSnackBar(
                                  context: context,
                                  title: 'Error:',
                                  message: result['error'],
                                );

                              }
                            }
                            else{
                              setState(() {
                                isPressed = false;
                                isLoading = false;
                              });
                              showTopSnackBar(
                                context: context,
                                title: 'Error:',
                                message: 'Password does not match',
                              );
                            }
                          }
                          else{
                            setState(() {
                              isPressed = false;
                              isLoading = false;
                            });
                            showTopSnackBar(
                              context: context,
                              title: 'Error:',
                              message: 'Please fill all fields completely',
                            );
                          }
                        }
                        catch(ex){
                          setState(() {
                            isPressed = false;
                            isLoading = false;
                          });
                          String errorMessage = extractFirebaseErrorMessage(ex.toString());
                          showTopSnackBar(
                            context: context,
                            title: 'Error:',
                            message: '$errorMessage',
                          );
                        }
                      }
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}

