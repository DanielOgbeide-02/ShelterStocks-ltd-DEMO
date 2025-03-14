import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shelterstocks_prototype2/common/widgets/flush_bar/Flushbar.dart';
import 'package:shelterstocks_prototype2/common/widgets/buttons/buttons.dart';
import 'package:shelterstocks_prototype2/presentation/provider/transactions/transactionData.dart';
import 'package:shelterstocks_prototype2/presentation/provider/notification/notificationData.dart';
import 'package:shelterstocks_prototype2/presentation/provider/sell_requests/sellRequestData.dart';

import '../../../common/helpers/functions/getScale.dart';
import '../../provider/admin/adminData.dart';
import '../../provider/firebase/firebaseData.dart';
import '../../../data/sources/firebase_operations/firebase_service.dart';
import '../../../domain/models/sell_requests/sellRequest.dart';

class SellrequestsPage extends StatefulWidget {
  static String id = 'SellRequestPage';
  const SellrequestsPage({super.key});

  @override
  State<SellrequestsPage> createState() => _SellrequestsPageState();
}

class _SellrequestsPageState extends State<SellrequestsPage> {
  final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: '₦',
  );
  late final Admindata adminProvider;
  final ValueNotifier<bool> _showSpinner = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _isConnectedToInternet = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isCheckingInternet = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(true);

  StreamSubscription? _internetConnectionStreamSubscription;

  @override
  void initState() {
    super.initState();
    adminProvider = Provider.of<Admindata>(context, listen: false);
    _initialSetup();
  }

  Future<void> _initialSetup() async {
    await _checkInternetConnection();
    _isCheckingInternet.value = false;
    _showSpinner.value = false;
    _setupInternetConnectionListener();
    await _loadAdminData();
    await _loadData();
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
    _isConnectedToInternet.value = isConnected;
    if (!isConnected) {
      showInternetLostSnackbar();
    }
  }

  void showInternetLostSnackbar() {
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

  Future<void> _loadAdminData() async {
    await adminProvider.loadAdminData();
    _showSpinner.value = false;
  }

  Future<void> _loadData() async {
    final sellRequestData = Provider.of<Sellrequestdata>(context, listen: false);
    _isLoading.value = true;

    try {
      await sellRequestData.fetchUnapprovedSellRequest(adminProvider.currentAdmin!.adminId!);
    } catch (e) {
      print('Error fetching sell requests: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  void dispose() {
    _internetConnectionStreamSubscription?.cancel();
    _showSpinner.dispose();
    _isConnectedToInternet.dispose();
    _isCheckingInternet.dispose();
    _isLoading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1A1AFF),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Sell Requests', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _isConnectedToInternet,
        builder: (context, isConnectedToInternet, child) {
          if (!isConnectedToInternet) {
            return Center(child: Text('No internet connection'));
          }
          return ValueListenableBuilder<bool>(
            valueListenable: _isLoading,
            builder: (context, isLoading, child) {
              if (isLoading) {
                return Center(child: CircularProgressIndicator(color: Colors.blue));
              }
              return Consumer<Sellrequestdata>(
                builder: (context, sellRequestData, child) => Column(
                  children: [
                    if (sellRequestData.sellRequestCount > 0)
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0))
                          ),
                          child: ListView.builder(
                            itemCount: sellRequestData.sellRequests.length,
                            itemBuilder: (context, index) {
                              final eachRequest = sellRequestData.sellRequests[index];
                              String qualified = (eachRequest.qualified == true) ? 'Yes' : 'No';
                              return SellRequestItem(
                                index: index,
                                eachRequest: eachRequest,
                                qualified: qualified,
                                currencyFormatter: currencyFormatter,
                                sellRequestData: sellRequestData,
                                notificationProvider: Provider.of<notificationData>(context, listen: false),
                                firebaseService: FirebaseService(),
                              );
                            },
                          ),
                        ),
                      )
                    else
                      Expanded(
                          child: Center(
                              child: Text(
                                  'No sell requests at the moment.',
                                  style: TextStyle(color: Colors.red)
                              )
                          )
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class SellRequestItem extends StatefulWidget {
  final int index;
  final dynamic eachRequest;
  final String qualified;
  final NumberFormat currencyFormatter;
  final Sellrequestdata sellRequestData;
  final notificationData notificationProvider;
  final FirebaseService firebaseService;

  const SellRequestItem({
    Key? key,
    required this.index,
    required this.eachRequest,
    required this.qualified,
    required this.currencyFormatter,
    required this.sellRequestData,
    required this.notificationProvider,
    required this.firebaseService,
  }) : super(key: key);

  @override
  _SellRequestItemState createState() => _SellRequestItemState();
}

class _SellRequestItemState extends State<SellRequestItem> {
  bool _loading = false;
  bool isPressed = false;

  Future<void> onApprove(BuildContext ctx) async {
    final approveResults = await widget.sellRequestData.approveRequest(widget.eachRequest, widget.eachRequest.userId!);
    if (approveResults['status'] == 'success') {
      print('Sell request of ${widget.eachRequest.userId} has been approved');
      // showTopSnackBar(context: context, title: 'success', message: 'Sell request of ${widget.eachRequest.userId} has been approved');
      Get.snackbar(
        "success",
        "Sell request of ${widget.eachRequest.userId} has been approved.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Color(0xFF1A1AFF),
        backgroundGradient: LinearGradient(
          colors: [Color(0xFF1A1AFF), Colors.white70],
        ),
        boxShadows:  [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(2, 2),
            blurRadius: 8,
          )
        ],
        colorText: Colors.white,
        margin: EdgeInsets.all(16),
        borderRadius: 10,
        snackStyle: SnackStyle.FLOATING,
        duration: Duration(seconds: 3),
        isDismissible: true,
      );
      final addTransResult = await widget.firebaseService.addTransaction(widget.eachRequest.userId!,
          {
            'transactionType': 'Sell',
            'transactionDate': DateTime.now(),
            'stockUnits': widget.eachRequest.stockUnits,
            'stockValue': widget.eachRequest.stockValue,
            'transactionAmount': widget.eachRequest.stockValue,
            'transactionStatus': 'Success',
          }
      );
      if(addTransResult['status'] == 'Success'){
        try{
          widget.firebaseService.sendNotificationToUser(widget.eachRequest.userId!,
              'From ShelterStocks',
              'Your request to sell ${widget.currencyFormatter.format(widget.eachRequest.stockValue)} has been approved. Check your account to confirm it has been credited.'
          ).then((_){
            try{
              widget.notificationProvider.addNewNotification(widget.eachRequest.userId!, 'Payment', 'Your request to sell ${widget.currencyFormatter.format(widget.eachRequest.stockValue)} has been approved. Check your account to confirm it has been credited.', DateTime.now(), 'account_balance_wallet',false);
              print('notification added successfully');
            }
            catch(e){
              print('unable to add notifications see details: ${e.toString()}');
            }
          });

          print('notification sent successfully');
        }
        catch(e){
          print('unable to send notifications see details: ${e.toString()}');
        }
      }
      else{
        print('unable to sent notification');
      }
    } else {
      print('error approving request');
      // showTopSnackBar(context: context, title: 'Failed', message: 'Sell request of ${widget.eachRequest.userId} could not be approved');
      Get.snackbar(
        "Failed",
        "Sell request of ${widget.eachRequest.userId} could not be approved.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Color(0xFF1A1AFF),
        backgroundGradient: LinearGradient(
          colors: [Color(0xFF1A1AFF), Colors.white70],
        ),
        boxShadows:  [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(2, 2),
            blurRadius: 8,
          )
        ],
        colorText: Colors.white,
        margin: EdgeInsets.all(16),
        borderRadius: 10,
        snackStyle: SnackStyle.FLOATING,
        duration: Duration(seconds: 3),
        isDismissible: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    bool isTablet = screenWidth > 600;
    bool isSmallPhone = screenWidth < 413 && screenHeight<733;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(width: 1, color: Colors.grey)
          )
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.index + 1}. ',
                          style: TextStyle(
                            fontSize: isTablet?10*getScale(context):(13.0 * getScale(context))
                          ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.eachRequest.lastName} ${widget.eachRequest.firstName}',
                            style: TextStyle(fontSize: isTablet?10*getScale(context):(13.0 * getScale(context)),
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w700,
                             ),
                          ),
                          Text(
                            'Qualified: ${widget.qualified}',
                            style: TextStyle(color: Colors.green, fontFamily: 'Roboto',
                                fontWeight: FontWeight.w700,
                                fontSize: isTablet?10*getScale(context):(13.0 * getScale(context)),
                                ),
                          )
                        ],
                      ),
                    ],
                  )
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'ShelterStocks: ${widget.eachRequest.stockUnits}',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: isTablet?10*getScale(context):(13.0 * getScale(context)),
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,

                    ),
                  ),
                  Text(
                    'Value: ${widget.currencyFormatter.format(widget.eachRequest.stockValue)}',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: isTablet?10*getScale(context):(13.0 * getScale(context)),
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,

                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 5 * getScale(context)),
          Buttons(
            isLoading: _loading,
            isPressed: isPressed,
            width: double.infinity,
            buttonText: 'Approve',
            buttonTextColor: Colors.white,
            buttonColor: Color(0xFF1A1AFF),
            onPressed: () async {
              BuildContext ctx = context;
              setState(() {
                isPressed = true;
                _loading = true;
              });
              try {
                await onApprove(ctx);
              } finally {
                if (mounted) {
                  setState(() {
                    isPressed = false;
                    _loading = false;
                  });
                }
              }
            },
          )
        ],
      ),
    );
  }
  }