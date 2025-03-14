import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shelterstocks_prototype2/common/helpers/functions/getScale.dart';
import 'package:shelterstocks_prototype2/common/widgets/buttons/buttons.dart';
import 'package:shelterstocks_prototype2/common/widgets/input_field/inputfields.dart';
import 'package:shelterstocks_prototype2/presentation/provider/user/userData.dart';
import 'package:shelterstocks_prototype2/presentation/provider/admin/adminData.dart';
import 'package:shelterstocks_prototype2/presentation/provider/notification/notificationData.dart';
import 'package:shelterstocks_prototype2/presentation/intro/pages/ShelterStocksGetStartedScreen.dart';
import '../../../../common/widgets/flush_bar/Flushbar.dart';
import '../../../provider/transactions/transactionData.dart';
import '../../../provider/firebase/firebaseData.dart';
import '../../../dashboard/pages/user/dashBoardScreen.dart';

class resumeAppScreen extends StatefulWidget {
  static String id = 'resumeAppScreen_screen';
  const resumeAppScreen({super.key});


  @override
  State<resumeAppScreen> createState() => _resumeAppScreenState();
}

class _resumeAppScreenState extends State<resumeAppScreen> {
  bool showSpinner = false;
  bool isLoading = true;
  bool _loading = false;
  bool isPressed = false;
  TextEditingController passwordController = TextEditingController();
  String password = '';
  late final userProvider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userProvider  = Provider.of<UserData>(context, listen: false);
    _loadData();
  }

  Future<void> _loadData() async {
    await userProvider.loadUserData();
    setState(() {
      showSpinner = false;
      isLoading = false; // Hide spinner after data is loaded
    });
  }


  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    // Check if the device is a tablet (adjust threshold as needed)
    bool isTablet = screenWidth > 600;
    final userProvider = Provider.of<UserData>(context, listen: false);
    final adminProvider = Provider.of<Admindata>(context, listen: false);

    return ModalProgressHUD(
      color: Colors.white,
      inAsyncCall: showSpinner,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child:
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    isLoading?CircularProgressIndicator(color: Color(0xFF1A1AFF),):
                    Text(
                      '${userProvider.currentUser?.firstName},',
                      style:
                      TextStyle(
                          fontSize: 30*getScale(context),
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w900,
                      ),
                                            ),
                    SizedBox(
                      height: isTablet?10:10.h,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Please confirm your password to access your ShelterStocks.', style: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w700,
                        ),),
                      ],
                    ),
                  ],
                ),

                SizedBox(
                  height: isTablet?30:30.h,
                ),
                // type email
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your Password:', style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                    ),),
                    SizedBox(
                      height: 5.h,
                    ),
                    InputField(obscureText: true, textfieldWidth: double.infinity, hintText: 'Enter your password', controller_: passwordController, isPassword: true,),
                    SizedBox(
                      height: isTablet?50:50.h,
                    ),
                    Buttons(width: double.infinity,isPressed: isPressed,buttonText: 'LOGIN', buttonColor: Color(0xFF1A1AFF), buttonTextColor: Colors.white, isLoading: _loading,onPressed: ()async{
                      setState(() {
                        isPressed = true;
                        _loading = true;
                      });
                      setState(() {
                        password = passwordController.text.trim();
                      });
                      final transactionsProvider = Provider.of<transactionData>(
                          context, listen: false);
                      final notificationsProvider = Provider.of<notificationData>(context, listen: false);
                      if(password.isNotEmpty){
                        if(password == userProvider.currentUser?.password){
                          transactionsProvider.clearTransactionsOnLogout();
                          bool fetchTransaction = await transactionsProvider.fetchTransaction(userProvider.currentUser?.userId??'');
                          if(fetchTransaction){
                            print('Fetch transaction was successful');
                          }
                          else{
                            print('Unable to fetch transaction');
                          }
                          bool fetchNotifications = await notificationsProvider.fetchNotification(userProvider.currentUser?.userId??'', 'Notifications');
                          if(fetchNotifications){
                            print('Fetch Notifications was successful');
                          }
                          else{
                            print('Unable to fetch Notifications');
                          }
                          Future.delayed(Duration(seconds: 3), (){
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => DashboardScreen()),
                                  (Route<dynamic> route) => false,
                            ).then((_){
                              setState(() {
                                isPressed = false;
                                _loading = false;
                              });
                            });
                          });
                        }
                        else{
                          setState(() {
                            isPressed = false;
                            _loading = false;
                          });
                          showTopSnackBar(
                            context: context,
                            title: 'Error:',
                            message: 'Incorrect password',
                          );
                        }
                      }
                      else{
                        setState(() {
                          isPressed = false;
                          _loading = false;
                        });
                        showTopSnackBar(
                          context: context,
                          title: 'Error:',
                          message: 'Please fill all fields completely',
                        );
                      }
                    }
                    ),
                    SizedBox(
                      height: 30.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(' Not you? ',style: TextStyle(color: Colors.grey,  fontFamily: 'Roboto',
                              fontWeight: FontWeight.w700,)),
                            GestureDetector(
                              onTap: (){
                                final userFirebaseProvider = Provider.of<FirebaseProvider>(context, listen: false);
                                final transactionsProvider = Provider.of<transactionData>(context, listen: false);
                                final notificationsProvider = Provider.of<notificationData>(context, listen: false);

                                userFirebaseProvider.signOut(transactionsProvider, notificationsProvider);
                                Navigator.pushReplacementNamed(context, getStartedScreen.id);
                              },
                                child: Text('Log out',style: TextStyle(color: Colors.black,  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w700,),))
                          ],
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: 50.h,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
