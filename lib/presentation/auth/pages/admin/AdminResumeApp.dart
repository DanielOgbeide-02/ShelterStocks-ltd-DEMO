import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';

import '../../../../common/widgets/flush_bar/Flushbar.dart';
import '../../../../common/widgets/buttons/buttons.dart';
import '../../../../common/widgets/input_field/inputfields.dart';
import '../../../provider/admin/adminData.dart';
import '../../../provider/firebase/firebaseData.dart';
import '../../../provider/sell_requests/sellRequestData.dart';
import '../../../dashboard/pages/admin/AdminDashboard.dart';
import '../../../intro/pages/ShelterStocksGetStartedScreen.dart';

class AdminResumeApp extends StatefulWidget {
  static String id = 'AdminResumeScreen_screen';
  const AdminResumeApp({super.key});

  @override
  State<AdminResumeApp> createState() => _AdminResumeAppState();
}

class _AdminResumeAppState extends State<AdminResumeApp> {
  bool showSpinner = false;
  bool isLoading = true;
  bool _loading = false;
  bool isPressed = false;
  TextEditingController passwordController = TextEditingController();
  String password = '';
  late final adminProvider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    adminProvider  = Provider.of<Admindata>(context, listen: false);
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    await adminProvider.loadAdminData();
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
    final adminProvider = Provider.of<Admindata>(context, listen: false);
    return ModalProgressHUD(
      color: Colors.white,
      inAsyncCall: showSpinner,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        isLoading?CircularProgressIndicator(color: Color(0xFF1A1AFF),):
                        Consumer<Admindata>(
                            builder: (context, adminData, child) {
                              return
                                Text(
                                  '${adminData.currentAdmin?.role},',
                                  style: TextStyle(fontSize: 30),
                                );
                            }),
                        SizedBox(
                          height: isTablet?10:10.h,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: isTablet?30:30.h,
                  ),
                  //type email
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your Password:'),
                      SizedBox(
                        height: 5.h,
                      ),
                      InputField(obscureText: true, textfieldWidth: double.infinity, hintText: 'Enter your password', controller_: passwordController, isPassword: true,),
                      SizedBox(
                        height: isTablet?50:50.h,
                      ),
                      Consumer<Admindata>(
                        builder: (context,adminData,child)=>
                            Buttons(width: double.infinity,isPressed: isPressed,buttonText: 'LOGIN', buttonColor: Color(0xFF1A1AFF), buttonTextColor: Colors.white, isLoading: _loading,onPressed: ()async{
                              setState(() {
                                isPressed = true;
                                _loading = true;
                              });
                              setState(() {
                                password = passwordController.text.trim();
                              });

                              if(password.isNotEmpty){
                                final firebaseProvider = Provider.of<FirebaseProvider>(
                                    context, listen: false);

                                final result = await firebaseProvider.signInAdmin(adminProvider.currentAdmin!.email!, password);
                                if(result['user'] != null){
                                  final AdminProvider = Provider.of<Admindata>(context, listen: false);
                                  final SellRequestProvider = Provider.of<Sellrequestdata>(context, listen: false);
                                  await AdminProvider.fetchAndStoreAllUsersData();
                                  bool result = await SellRequestProvider.fetchUnapprovedSellRequest((adminProvider.currentAdmin!.adminId!));
                                  if(result){
                                    print('all sell request fetched successfully');
                                  }
                                  else{
                                    print('error fetching sell requests');
                                  }
                                  Future.delayed(Duration(seconds: 3), (){
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(builder: (context) => Admindashboard()),
                                          (Route<dynamic> route) => false,
                                    ).then((_){
                                      setState(() {
                                        isPressed = false;
                                        _loading = false;
                                      });
                                    });
                                  });
                                }
                                else {
                                  setState(() {
                                    isPressed = false;
                                    _loading = false;
                                  });
                                  print('Login failed');
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
                      ),
                      SizedBox(
                        height: 30.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Consumer<Admindata>(
                              builder: (context, adminData, child)=>
                                  Row(
                                    children: [
                                      Text(' Not you? ',style: TextStyle(color: Colors.grey)),
                                      GestureDetector(
                                          onTap: (){
                                            final userFirebaseProvider = Provider.of<FirebaseProvider>(context, listen: false);
                                            userFirebaseProvider.signOutAdmin('${adminProvider.currentAdmin?.role}');
                                            Navigator.pushReplacementNamed(context, getStartedScreen.id);
                                          },
                                          child: Text('Log out',style: TextStyle(color: Colors.black),)
                                      )
                                    ],
                                  )
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
      ),
    );
  }
}
