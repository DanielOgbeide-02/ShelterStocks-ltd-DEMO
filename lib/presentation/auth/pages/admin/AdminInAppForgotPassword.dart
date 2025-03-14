import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:shelterstocks_prototype2/common/widgets/buttons/buttons.dart';
import 'package:shelterstocks_prototype2/presentation/provider/admin/adminData.dart';

import '../../../provider/profile/user_profile/profileData.dart';
import '../../../provider/transactions/transactionData.dart';
import '../../../provider/user/userData.dart';
import '../../../provider/firebase/firebaseData.dart';
import '../../../intro/pages/ShelterStocksGetStartedScreen.dart';
import '../../../../common/widgets/flush_bar/Flushbar.dart';
import '../../../../common/widgets/buttons/goBackBtn.dart';
import '../../../../common/widgets/input_field/inputfields.dart';

class Admininappforgotpassword extends StatefulWidget {
  const Admininappforgotpassword({super.key});

  @override
  State<Admininappforgotpassword> createState() => _Admininappforgotpassword();
}

class _Admininappforgotpassword extends State<Admininappforgotpassword> {
  TextEditingController emailController = TextEditingController();
  UserData? userProvider;
  profileData? userProfileProvider;
  bool showSpinner = true;
  bool _authLoad = false;
  bool isPressed = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userProvider  = Provider.of<UserData>(context, listen: false);
    userProfileProvider  = Provider.of<profileData>(context, listen: false);
    _loadData();
  }

  Future<void> _loadData() async {
    await userProvider?.loadUserData();
    await userProfileProvider?.loadUserProfileData();
    setState(() {
      showSpinner = false; // Hide spinner after data is loaded
    });
  }
  @override
  void dispose() {
    // TODO: implement dispose
    emailController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    if(showSpinner){
      return Center(
        child: CircularProgressIndicator(color: Colors.white,),
      );
    }
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
            margin: EdgeInsets.only(top: 50, left: 20, right: 20),
          child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            goBackBtn(size: 25,),
            SizedBox(
              height: 250,
            ),
              Container(
                  margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Enter Your Email and we will send you a reset password link:',textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20
                        ),),
                      SizedBox(height: 10,),
                      InputField(obscureText: false, textfieldWidth: double.infinity, hintText: 'e.g admin@gmail.com', inputType: TextInputType.emailAddress, controller_: emailController,),
                      SizedBox(height: 20,),
                      Buttons(
                        width: double.infinity,
                        buttonText: 'Reset Password',
                        buttonColor: Color(0xFF1A1AFF),
                        buttonTextColor: Colors.white,
                        isLoading: _authLoad,
                        isPressed: isPressed,
                        onPressed: ()async{
                          setState(() {
                            isPressed = true;
                            _authLoad = true;
                          });
                          final userFirebaseProvider = Provider.of<FirebaseProvider>(context, listen: false);
                          final adminProvider = Provider.of<Admindata>(context, listen: false);
                          if(emailController.text.trim().isNotEmpty){
                            if(emailController.text.trim() == adminProvider.currentAdmin?.email){
                              final result = await userFirebaseProvider.updatePassword(emailController.text.trim());
                              if(result['status'] == 'success'){
                                showDialog(context: context, builder: (context){
                                  return AlertDialog(
                                    title:
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'To complete your password change:',
                                          style: TextStyle(
                                            // fontSize: 30,
                                              color: Colors.black
                                          ),
                                        ),
                                        SizedBox(height: 10,),
                                        Text(
                                          'A Password reset link has been sent,Please check your email!. After reset, use the "Logout" button below to sign out, then sign in again using your newly set password.',
                                          style: TextStyle(
                                              color: Colors.grey.shade500,
                                              fontSize: 18
                                          ),
                                        ),
                                        SizedBox(height: 10,),
                                        Text(
                                          'Note: The reset link is valid for 1 hour.',
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
                                            firebaseProvider.signOutAdmin(adminProvider.currentAdmin!.role!);
                                            Navigator.of(context).pushNamedAndRemoveUntil(
                                              getStartedScreen.id,
                                                  (Route<dynamic> route) => false,
                                            ).then((_){
                                              setState(() {
                                                _authLoad = false;
                                              });
                                            });
                                          },
                                          child: _authLoad?CircularProgressIndicator(
                                            color: Color(0xFF1A1AFF),
                                          ):Text('Logout')
                                      )
                                    ],
                                  );
                                });
                                setState(() {
                                  isPressed = false;
                                });
                              }
                            }
                            else{
                              showTopSnackBar(
                                context: context,
                                title: 'Invalid Email:',
                                message: 'Please enter your correct email!',
                              );
                            }
                          }
                          else{
                            showTopSnackBar(
                              context: context,
                              title: 'Error:',
                              message: 'Please fill field correctly',
                            );
                          }
                          setState(() {
                            _authLoad = false;
                            isPressed = false;
                          });
                        },
                      )
                    ],
                  )
              ),
            ],
          )

        ),
      ),
    );
  }
}
