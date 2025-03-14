import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shelterstocks_prototype2/main.dart';
import 'package:shelterstocks_prototype2/presentation/registeration/pages/before_signup/PersonalInfoScreen.dart';
import 'package:shelterstocks_prototype2/presentation/auth/pages/user/signUpScreen.dart';
import 'package:shelterstocks_prototype2/presentation/auth/pages/user/loginScreen.dart';
import '../../../common/widgets/buttons/buttons.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class getStartedScreen extends StatefulWidget {
  static String id = 'getStarted_screen';
  const getStartedScreen({super.key});

  @override
  State<getStartedScreen> createState() => _getStartedScreenState();
}

class _getStartedScreenState extends State<getStartedScreen> {
  bool showSpinner = false;
  @override
  Widget build(BuildContext context) {
    // Get screen width and height
    var screenWidth = MediaQuery.of(context).size.width;
    // Check if the device is a tablet (adjust threshold as needed)
    bool isTablet = screenWidth > 600;
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage(isTablet?'images/ShelterStocktabsplashscreen.jpg':'images/ShelterStocksplashscreen.jpg'), fit: BoxFit.cover)
              ),
            ),
            Center(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 80.h,
                    ),
                    Buttons(width: 160.w, height: 45.h, buttonText: 'Get Started', buttonColor: Color(0xFF1A1AFF), buttonTextColor: Colors.white,
                      onPressed:  (){
                      setState(() {
                        showSpinner = true;
                        Future.delayed(Duration(seconds: 3), (){
                          Navigator.pushNamed(context, Signupscreen.id).then((_){
                            setState(() {
                              showSpinner = false;
                            });
                          });
                        });
                      });
                      }
                      ,),
                    SizedBox(
                      height: 20.h,
                    ),
                    Buttons(
                      width: 160.w, height: 45.h, buttonText: 'Login', buttonColor: Colors.transparent, buttonTextColor: Color(0xFF1A1AFF),
                      onPressed: (){
                        Navigator.pushNamed(context, Loginscreen.id);
                      },
                    ),
                  ],
                )
              ),
            )
          ],
        ),
      ),
    );
  }
}


