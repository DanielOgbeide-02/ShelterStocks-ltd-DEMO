
import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:provider/provider.dart';
import 'package:shelterstocks_prototype2/common/helpers/functions/getScale.dart';
import 'package:shelterstocks_prototype2/common/helpers/constants/api_keys.dart';
import 'package:shelterstocks_prototype2/common/helpers/constants/base_urls.dart';
import 'package:shelterstocks_prototype2/common/helpers/selectBankHandler.dart';
import 'package:shelterstocks_prototype2/presentation/dashboard/pages/user/dashBoardScreen.dart';

import '../../../../common/widgets/flush_bar/Flushbar.dart';
import '../../../../common/widgets/buttons/buttons.dart';
import '../../../../common/widgets/input_field/inputfields.dart';
import '../../../provider/profile/user_profile/profileData.dart';
import '../../../provider/user/userData.dart';
import '../../../../data/models/bank/bankModel.dart';
import '../../../provider/firebase/firebaseData.dart';
import 'PersonalInfoScreen.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';


class BankingdetailsScreen extends StatefulWidget {
  static String id = 'banking_screen';
  const BankingdetailsScreen({super.key});

  @override
  State<BankingdetailsScreen> createState() => _BankingdetailsScreenState();
}

class _BankingdetailsScreenState extends State<BankingdetailsScreen> {
  TextEditingController accountNoEditingController = TextEditingController();
  TextEditingController SearchEditingController = TextEditingController();

  List<BanksData> banks = [];
  BanksData? selectedBank;
  String bankCode = "";
  String accountName = "";
  String bankName = "";
  String accountNumber = "";
  String initials = "";
  bool accountAvailable = false;

  Future<void> fetchBanksData() async {
    String key = ApiKeys.payStackLiveKey;
    print(key);
    final headers = {'Authorization': 'Bearer ${key}'};
    final response = await http.get(
        Uri.parse("${AppBaseUrl.payStackBaseUrl}/bank?currency=NGN"),
        headers: headers); // Replace with your API endpoint

    if (response.statusCode == 200) {
      final banksResponse = banksResponseFromJson(response.body);
      setState(() {
        banks = banksResponse.data;
      });
    } else {
      throw Exception('Failed to load banks');
    }
  }
  Future<Map<String, dynamic>?> verifyAccountnumber() async {
    if (accountNoEditingController.text.isEmpty || bankCode.isEmpty) {
      print('Account number or bank code is empty');
      return null;
    }

    final url = Uri.https('api.paystack.co', '/bank/resolve', {
      'account_number': accountNoEditingController.text,
      'bank_code': bankCode
    });
    final headers = {
      'Authorization': 'Bearer ${ApiKeys.payStackLiveKey}',
    };
    print("Verifying account number: ${accountNoEditingController.text}");
    print("Bank code: $bankCode");

    try {
      final response = await http.get(url, headers: headers);
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          accountAvailable = true;
          accountName = data['data']['account_name'];
        });
        return data;
      } else {
        print('Failed to resolve bank account: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (error) {
      print('Error resolving bank account: $error');
      return null;
    }
  }

  bool showSpinner = false;
  bool isConnectedToInternet = false;
  bool isPressed = false;
  StreamSubscription? _internetConnectionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
    _setupInternetConnectionListener();
    fetchBanksData();
  }

  Future<void> _checkInternetConnection() async {
    final internetConnectionStatus = await InternetConnectionCheckerPlus().connectionStatus;
    _updateConnectionStatus(internetConnectionStatus == InternetConnectionStatus.connected);
  }

  void _setupInternetConnectionListener() {
    _internetConnectionStreamSubscription = InternetConnectionCheckerPlus().onStatusChange.listen((status) {
      _updateConnectionStatus(status == InternetConnectionStatus.connected);
    });
  }

  void _updateConnectionStatus(bool isConnected) {
    setState(() {
      isConnectedToInternet = isConnected;
      if (!isConnectedToInternet) {
        showInternetLostSnackbar();
      }
    });
  }

  void showInternetLostSnackbar() {
    // Only show the snackbar if it's not already visible
    if (!Get.isSnackbarOpen) {
      Get.snackbar(
        "Connection Lost",
        "You have lost connection to the internet.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: EdgeInsets.all(16),
        borderRadius: 10,
        icon: Icon(Icons.wifi_off, color: Colors.white),
        snackStyle: SnackStyle.FLOATING,
        duration: Duration(seconds: 3),
        isDismissible: true,
      );
    }
  }
  @override
  void dispose() {
    _internetConnectionStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width and height
    var screenWidth = MediaQuery.of(context).size.width;
    // Check if the device is a tablet (adjust threshold as needed)
    bool isTablet = screenWidth > 600;
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      opacity: 0.5, // Adjust this value between 0.0 and 1.0
      color: Colors.grey,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: ListView(
            children: [
              Text(
                'STEP ${context.watch<profileData>().currentStep} OF ${context.watch<profileData>().totalSteps}',
                style: TextStyle(
                  color: Color(0xFF1A1AFF),
                  fontSize: 17,
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              Text(
                  'BANKING DETAILS',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: isTablet?11*getScale(context):15.sp,
                      fontWeight: FontWeight.bold
                  )
              ),
              SizedBox(
                height: 10.h,
              ),
              //Identification
              Container(
                decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFF1A1AFF), width: 3.w))
                ),
                padding: EdgeInsets.only(top: 30),
                child:
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //account name
                    Visibility(
                      visible: accountAvailable,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (accountName.isNotEmpty) ? accountName : "",
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          CircleAvatar(
                            backgroundColor: Color(
                                0xFF8C52FF), // Set the background color of the Avatar
                            child: Text(
                              getInitials(accountName),
                              style: const TextStyle(
                                fontSize: 18, // Adjust the font size as needed
                                color: Colors.white, // Set the text color
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    TextFormField(
                      controller: accountNoEditingController,
                      decoration: InputDecoration(
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                            width: 1,
                            color: Colors.grey,
                          ),
                        ),
                        labelText: "Account Number",
                        labelStyle: const TextStyle(color: Colors.black87),
                        hintText: "Enter Account Number",
                        hintStyle:
                        const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      keyboardType: TextInputType.number,
                      //style: pBold16,
                      onChanged: (value) {
                        setState(() {
                          accountName = "";
                          accountNumber = "";
                          accountAvailable = false;
                        });
                        if (bankCode != "") {
                          if (value.length == 10 &&
                              int.tryParse(value) != null) {
                            //fetchRecipient();
                            print('Account Number: $value');
                          } else {
                            //Get.snackbar("", "Invalid account number");
                            print('Phone number length: ${value.length}');
                          }
                        }
                      },
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton2<BanksData>(
                        isExpanded: true,
                        isDense: true,
                        hint: Text(
                          (banks == [])
                              ? 'Fetching banks, please wait...'
                              : 'Select Banks',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        items: banks
                            .map<DropdownMenuItem<BanksData>>((BanksData bank) {
                          return DropdownMenuItem<BanksData>(
                            value: bank,
                            child: Text(
                              bank.name,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          );
                        }).toList(),
                        value: selectedBank,
                        onChanged: (BanksData? value) {
                          setState(() {
                            print(value!.code.toString());
                            bankCode = value.code.toString();
                            selectedBank = value;
                            bankName = value.name;
                            accountNumber = accountNoEditingController.text;
                          });
                          print(
                              "$bankCode $bankName $accountNumber $accountName");
                          if (bankCode != "") {
                            if (accountNoEditingController.text.length == 10 &&
                                int.tryParse(accountNoEditingController.text) !=
                                    null) {
                              verifyAccountnumber();
                            } else {
                              //Get.snackbar("", "Invalid account number");
                              print('Invalid input: $value');
                            }
                          }
                        },
                        buttonStyleData: ButtonStyleData(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          height: 50,
                          width: Get.size.width,
                        ),
                        dropdownStyleData: DropdownStyleData(
                            maxHeight: Get.size.height / 3,
                            decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ))),
                        menuItemStyleData: const MenuItemStyleData(
                          height: 40,
                        ),
                        dropdownSearchData: DropdownSearchData(
                          searchController: SearchEditingController,
                          searchInnerWidgetHeight: 50,
                          searchInnerWidget: Container(
                            height: 50,
                            padding: const EdgeInsets.only(
                              top: 8,
                              bottom: 4,
                              right: 8,
                              left: 8,
                            ),
                            child: TextFormField(
                              expands: true,
                              maxLines: null,
                              controller: SearchEditingController,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                hintText: 'Search for an item...',
                                hintStyle: const TextStyle(fontSize: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          searchMatchFn: (item, searchValue) {
                            final myItem = banks.firstWhereOrNull(
                                  (element) => element.name.toLowerCase() == item.value!.name.toLowerCase(),
                            );
                            return myItem != null && myItem.name.contains(searchValue);
                          },
                        ),
                        onMenuStateChange: (isOpen) {
                          if (!isOpen) {
                            SearchEditingController.clear();
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                  ],
                ),
              ),
              //Buttons
              Container(
                child: Row(
                  children: [
                    Expanded(
                      child: Buttons(
                        width: 50.w, buttonText: 'Previous', buttonColor: Color(0xFF1A1AFF), buttonTextColor: Colors.white,
                        onPressed: (){
                          Provider.of<profileData>(context, listen: false).decreaseCurrentStep();
                          print(Provider.of<profileData>(context, listen: false).currentStep);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    SizedBox(
                      width: 20.w,
                    ),
                    Expanded(
                      child: Buttons(
                        width: 50.w, isPressed: isPressed, buttonText: 'Finish', buttonColor: Color(0xFF1A1AFF), buttonTextColor: Colors.white,
                        onPressed: () async {
                          if(isConnectedToInternet){
                            setState(() {
                              isPressed = true;
                              // showSpinner = true;
                            });
                            accountNumber = accountNoEditingController.text.trim();
                            final currentUserProfileProvider = Provider.of<profileData>(context, listen: false);
                            final userProvider = Provider.of<UserData>(context, listen: false);
                            String? userId = userProvider.currentUser?.userId;
                            final firebaseProvider = Provider.of<FirebaseProvider>(
                                context, listen: false);
                            if(accountName.isNotEmpty && accountNumber.isNotEmpty && bankName.isNotEmpty){
                              currentUserProfileProvider.updateUserProfile(
                                accountNumber: accountNumber,
                                bankAccountName: accountName,
                                bank: bankName,
                              );

                              currentUserProfileProvider.increaseCurrentStep();
                              Map<String, dynamic> updateUserProfile = {
                                //NEWLY ADDED
                                "Account Number":currentUserProfileProvider.currentUserProfile?.accountNumber,
                                "Bank account name": currentUserProfileProvider.currentUserProfile?.bankAccountName,
                                "Bank": currentUserProfileProvider.currentUserProfile?.bank,
                              };
                              bool completedReg = false;
                              try {
                                await firebaseProvider.updateData('UserInformation', userId!, updateUserProfile);
                                // If the update is successful, you can do something here, like navigate to the next screen or show a success message.
                                completedReg = true;
                                Map<String, dynamic> completeRegStatus = {
                                  //NEWLY ADDED
                                  "Completed registration": completedReg
                                };
                                currentUserProfileProvider.updateUserProfile(regStatus: completedReg);
                                await firebaseProvider.updateData('UserInformation', userId, completeRegStatus);
                                //start
                                DocumentSnapshot currentUserDoc =
                                await firebaseProvider.fetchData('UserInformation', userId);
                                if (currentUserDoc.exists) {
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
                                      regStatus: regStatus
                                  );
                                }
                                //latest change
                                showTopSnackBar(
                                  context: context,
                                  title: 'Success:',
                                  message: 'Registration successfully completed',
                                );
                              } catch (e) {
                                // If there is an error, it will be caught here.
                                Map<String, dynamic> completeRegStatus = {
                                  //NEWLY ADDED
                                  "Completed registration": completedReg
                                };
                                await firebaseProvider.updateData('UserInformation', userId!, completeRegStatus);
                                setState(() {
                                  isPressed = false;
                                  showSpinner = false;
                                });
                                showTopSnackBar(
                                  context: context,
                                  title: 'Error:',
                                  message: 'Failed to update user information',
                                );
                                print('Failed to update user information: $e');
                                // You can show an error message to the user or handle the error as needed.
                              }

                              Future.delayed(Duration(seconds: 3), (){
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => DashboardScreen()),
                                      (Route<dynamic> route) => false,
                                ).then((_){
                                  setState(() {
                                    isPressed = false;
                                    showSpinner = false;
                                  });
                                });

                              });
                            }
                            else{
                              print('Bank Name: $bankName');
                              setState(() {
                                isPressed = false;
                                showSpinner = false;
                              });
                              print('Please ensure your bank details are correct.');
                              showTopSnackBar(
                                context: context,
                                title: 'Error:',
                                message: 'Please ensure your bank details are correct.',
                              );
                            }
                          }
                          else{
                            setState(() {
                              isPressed = false;
                              showSpinner = false;
                            });
                            showInternetLostSnackbar();
                          }
                        },
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
