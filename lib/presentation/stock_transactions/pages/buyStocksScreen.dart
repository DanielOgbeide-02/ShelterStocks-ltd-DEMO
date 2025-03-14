import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shelterstocks_prototype2/common/helpers/constants/api_keys.dart';
import 'package:shelterstocks_prototype2/common/helpers/functions/getScale.dart';
import 'package:shelterstocks_prototype2/common/widgets/buttons/buttons.dart';
import 'package:shelterstocks_prototype2/common/widgets/input_field/inputfields.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:shelterstocks_prototype2/presentation/provider/firebase/firebaseData.dart';

import '../../../common/widgets/flush_bar/Flushbar.dart';
import '../../provider/transactions/transactionData.dart';
import '../../provider/user/userData.dart';
import '../../../data/sources/firebase_operations/firebase_service.dart';

class buyStocksScreen extends StatefulWidget {
  static String id = 'buyStocks_screen';
  const buyStocksScreen({super.key});

  @override
  State<buyStocksScreen> createState() => _buyStocksScreenState();
}

class _buyStocksScreenState extends State<buyStocksScreen> {
  TextEditingController stockAmountController = TextEditingController();
  // test key
  String publicKey = 'pk_test_d12505493ebe9033cd51612c6c61f5e5c06a0734';
  //actualy key: reference=> Mr Ugo
  // String publicKey = ApiKeys.publicKey;
  final plugin = PaystackPlugin();
  String message = '';
  bool isConnectedToInternet = false;
  String transactionType = 'Buy';
  int? price = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
    plugin.initialize(publicKey: publicKey);
    stockAmountController.addListener(_updatePrice);
  }

  void getData() async {
    final userProvider = Provider.of<UserData>(context, listen: false);
    await userProvider.loadUserData();
  }

  void _updatePrice() {
    setState(() {
      final stockAmount = int.tryParse(stockAmountController.text.trim());
      if (stockAmount != null && stockAmount > 0) {
        price = stockAmount * 1000; // Adjust the price calculation as needed
      } else {
        price = 0; // Display 0 if the input is empty or invalid
      }
    });
  }

  void makePayment() async {
    int priceToPay = price!*100;
    if (!mounted) return;
    final userProvider = Provider.of<UserData>(context, listen: false);
    final userFirebaseProvider = Provider.of<FirebaseProvider>(context, listen: false);
    final FirebaseService _firebaseService = FirebaseService(); // Reference to FirebaseService
    final String? currentUserEmail = userProvider.currentUser?.email;
    final transactionsProvider = Provider.of<transactionData>(context, listen: false);
    final stockAmount = int.tryParse(stockAmountController.text.trim());
    final String? userId = userProvider.currentUser?.userId;
    Charge charge = Charge()
      ..amount = priceToPay
      ..reference = 'ref_${DateTime.now()}'
      ..email = currentUserEmail
      ..currency = 'NGN';
    CheckoutResponse response = await plugin.checkout(
        context, method: CheckoutMethod.card, charge: charge);
    String status;
    if (response.status == true && mounted) {
      status = 'Success';
      message = 'Payment was successful. Ref: ${response.reference}';
      if (mounted) {}
      showTopSnackBar(
        context: context,
        title: 'Success:',
        message: 'Payment successful',
      );
      userProvider.updateStocks(int.parse(stockAmountController.text), true);
      Map<String, dynamic> updatedUserStocks = {
        //NEWLY ADDED
        "stockUnits":userProvider.currentUser?.stockUnits,
        "stockValue": userProvider.currentUser?.stockValue,
      };
      final updateResult = await userFirebaseProvider.updateData('UserInformation',userId!,updatedUserStocks);
      if(updateResult['status'] == 'success'){
        //should be the last
        // DocumentSnapshot globalCycledoc = await _firebaseService.fetchData('globalCycle', 'current');
        // if(globalCycledoc.exists){
        //   int daysLeft = globalCycledoc['daysLeft'];
        //   List<Map<String, dynamic>> stockPurchases = [
        //     {
        //       "numberOfStocks": stockAmount,
        //       "purchaseDate": DateTime.now(),
        //       "daysLeft": daysLeft,
        //       "dividendGenerated": calculateDividendForPurchase(stockAmount!, daysLeft),
        //     }
        //   ];
        //
        //   final addStockResults = await _firebaseService.addStockPurchases(userId, stockPurchases);
        // Fetch the global cycle document
        DocumentSnapshot globalCycledoc = await _firebaseService.fetchData('globalCycle', 'current');

        if (globalCycledoc.exists) {
          int daysLeft = globalCycledoc['daysLeft'];
          DateTime cycleEndDate = DateTime.now().add(Duration(days: daysLeft));
          DateTime cycleStartDate = cycleEndDate.subtract(Duration(days: 90));

          List<Map<String, dynamic>> stockPurchases = [
            {
              "numOfStocks": stockAmount,
              "purchaseDate": DateTime.now(),
              "cycleStartDate": cycleStartDate,
              "cycleEndDate": cycleEndDate,
              "daysLeft": daysLeft,
            }
          ];

          final addStockResults = await _firebaseService.addStockPurchases(userId, stockPurchases);
          if(addStockResults['status']){
            transactionsProvider.addNewTransaction(userId, transactionType, DateTime.now(), stockAmount!, price!.toDouble(), price!.toDouble(), status);
          }
        }
      }
    }
    else if(response.status == false && response.message.contains('failed')){
      status = 'Failed';
      transactionsProvider.addNewTransaction(userId!, transactionType, DateTime.now(), stockAmount!, price!.toDouble(), price!.toDouble(), status);
    }
  }

  double calculateDividendForPurchase(int stockUnits, int daysLeft) {
    const double annualDividendRate = 0.05; // 5% annual dividend rate (adjust as needed)
    const double dailyRate = annualDividendRate / 365;

    return stockUnits * dailyRate * daysLeft;
  }
  
  final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: '₦',
  );

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _checkInternetConnection();
  }

  Future<void> _checkInternetConnection() async {
    final internetConnectionStatus = await InternetConnectionCheckerPlus().connectionStatus;
    setState(() {
      isConnectedToInternet = internetConnectionStatus == InternetConnectionStatus.connected;
      print('Is connected o: ${isConnectedToInternet}');

    });
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
        body:
        Container(
          child: Column(
            children: [
              Container(
                color: Color(0xFF1A1AFF),
                child: Center(
                  child: Container(
                    margin: EdgeInsets.only(top: 25),
                    height: isSmallPhone?320*getScale(context):(isTablet?320*getScale(context):330),
                      width: double.infinity,
                      child: Image.asset(
                          'images/buystocksImg.jpg',
                        fit: BoxFit.cover,
                      )
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.only(top: isSmallPhone?10*getScale(context):20*getScale(context), left: 30, right: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'ShelterStocks',
                          style: TextStyle(
                            fontSize: isSmallPhone?15*getScale(context):(isTablet?15*getScale(context):20.sp),
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(
                          height: isSmallPhone?5*getScale(context):(isTablet?8:10),
                        ),
                        Text(
                            'Buy ShelterStocks',
                          style: TextStyle(
                              fontSize: isSmallPhone?11*getScale(context):(isTablet?8*getScale(context):13.sp),
                            color: Colors.grey,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(
                          height: isSmallPhone?10*getScale(context):(isTablet?10*getScale(context):20*getScale(context)),
                        ),
                        Text(
                            'ShelterStocks are fractional units of real estate investments. ShelterStocks offers an innovative platform to democratize real estate investing for ordinary, aspirational Nigerians via a fractional ownership framework, streamlining intricate procedures.',
                          style: TextStyle(
                              fontSize: isSmallPhone?10*getScale(context):(isTablet?8*getScale(context):11.sp),
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(
                          height: isSmallPhone?10*getScale(context):(isTablet?10*getScale(context):25.h),
                        ),

                        InputField(obscureText: false,
                          isPassword: false,
                          hintText: 'amount of stocks',
                          controller_: stockAmountController,),
                        SizedBox(
                          height: isSmallPhone?15*getScale(context):(isTablet?8*getScale(context):20),
                        ),
                        Text(
                            'You can order a minimum of 5 at a time',
                          style: TextStyle(
                              fontSize: isSmallPhone?11*getScale(context):(isTablet?6*getScale(context):11.sp),
                            color: Colors.red,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(
                          height: isSmallPhone?10*getScale(context):(isTablet?10*getScale(context):20.h),
                        ),

                        Text(
                            'Price',
                          style: TextStyle(
                              fontSize: isSmallPhone?12*getScale(context):(isTablet?8*getScale(context):13.sp),
                            color: Colors.grey,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        SizedBox(
                          height: isSmallPhone?4*getScale(context):(isTablet?4*getScale(context):9.h),
                        ),
                        Text('${currencyFormatter.format(price)}', style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w700,
                        ),),
                        SizedBox(
                          height: isTablet?10*getScale(context):15.h,
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: isSmallPhone?10*getScale(context):0),
                          child: Buttons(
                            width: double.infinity,
                            // height: isSmallPhone?35*getScale(context):(40.h),
                            buttonText: 'Buy now',
                            buttonColor: Color(0xFF1A1AFF),
                            buttonTextColor: Colors.white,
                            onPressed: () {
                              if(stockAmountController.text.isNotEmpty){
                                if(int.parse(stockAmountController.text.trim()) >= 5){
                                  makePayment();
                                }
                                else{
                                  showTopSnackBar(
                                    context: context,
                                    title: 'Error:',
                                    message: 'You can only buy a minimum of 5 stocks at a time',
                                  );
                                }
                              }
                                else{
                                  showTopSnackBar(
                                    context: context,
                                    title: 'Error:',
                                    message: 'Please enter an amount',
                                  );
                                }
                            },),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed
    stockAmountController.removeListener(_updatePrice);
    stockAmountController.dispose();
    super.dispose();
  }
  }

