import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../common/helpers/functions/getScale.dart';
import '../../provider/admin/adminData.dart';
import '../../provider/sell_requests/sellRequestData.dart';

class SearchUsersPage extends StatefulWidget {
  static String id = 'SearchUsersPage';
  const SearchUsersPage({super.key});

  @override
  State<SearchUsersPage> createState() => _SearchUsersPageState();
}

class _SearchUsersPageState extends State<SearchUsersPage> {
  late final adminProvider;
  bool showSpinner = true;
  bool isConnectedToInternet = false;
  bool isCheckingInternet = true;
  bool _mounted = true;
  bool isPressed = false;
  bool isLoading = true;

  StreamSubscription? _internetConnectionStreamSubscription;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkInternetConnection();
    _setupInternetConnectionListener();
    adminProvider  = Provider.of<Admindata>(context, listen: false);
    _initialSetup();
    _loadAdminData();
  }
  Future<void> _initialSetup() async {
    await _checkInternetConnection();
    if (_mounted) {
      setState(() {
        isCheckingInternet = false;
        showSpinner = false;
      });
    }
    _setupInternetConnectionListener();
    await _loadData();
  }

  Future<void> _checkInternetConnection() async {
    final internetConnectionStatus = await InternetConnectionCheckerPlus().connectionStatus;
    _updateConnectionStatus(internetConnectionStatus == InternetConnectionStatus.connected);
  }
  void _setupInternetConnectionListener() {
    _internetConnectionStreamSubscription = InternetConnectionCheckerPlus().onStatusChange.listen((status) {
      if (_mounted) {
        _updateConnectionStatus(status == InternetConnectionStatus.connected);
      }
    });
  }
  void _updateConnectionStatus(bool isConnected) {
    if (_mounted) {
      setState(() {
        isConnectedToInternet = isConnected;
        if (!isConnectedToInternet) {
          showInternetLostSnackbar();
        }
      });
    }
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

  Future<void> _loadAdminData() async {
    await adminProvider.loadAdminData();
    if (_mounted) {
      setState(() {
        showSpinner = false;
      });
    }
  }

  Future<void> _loadData() async {
    final adminProvider = Provider.of<Admindata>(context, listen: false);
    final sellRequestData = Provider.of<Sellrequestdata>(context, listen: false);

    setState(() {
      isLoading = true;
    });

    try {
      await adminProvider.fetchAndStoreAllUsersData();
      await adminProvider.fetchTotalShelterStocks();

    } catch (e) {
      // Handle error, maybe show a snackbar
      print('Error fetching all Users: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _loadAdminData();
  }

  @override
  void dispose() {
    _mounted = false;
    _internetConnectionStreamSubscription?.cancel();
    super.dispose();
  }

  String myname = '';
  final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: '₦',
  );
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    // Check if the device is a tablet (adjust threshold as needed)
    bool isTablet = screenWidth > 600;
    bool isSmallPhone = screenWidth < 413 && screenHeight<733;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1A1AFF),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Search Users', style: TextStyle(
            color: Colors.white
        ),),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: (){
                showSearch(
                    context: context, delegate: CustomSearch()
                );
              }, icon: Icon(
            Icons.search
          )
          )
        ],
      ),
      body:
      isConnectedToInternet?
      (!isLoading?
      Column(
        children: [
          Consumer<Admindata>(
                builder: (context, adminData, child) {
                  // adminData.fetchTotalShelterStocks();
                  final totalStockUnits = adminData.totalShelterStocks[0]['Stock Units']??0.0;
                  final totalStockValue = adminData.totalShelterStocks[0]['Stock Value']??0.0;

                  return
                      Container(
                        height: isTablet?45*getScale(context):(70 * getScale(context)),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(5)
                        ),
                        margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                        padding: EdgeInsets.all(10),
                        child: Center(
                          child:
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: Center(
                                  child:
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: [
                                      Expanded(child: Text('Total ShelterStocks Users: ', style: TextStyle(
                                        fontSize: isTablet?10*getScale(context):10*getScale(context),
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w700,
                                      ),)),
                                      Expanded(
                                        child: Text('${adminData.allUsersCount}',
                                            style: TextStyle(
                                                color: Color(0xFF1A1AFF),
                                                fontSize: isTablet?7*getScale(context):(15 * getScale(context)),
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.w700,
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              VerticalDivider(
                                color: Colors.grey,
                                // Line color
                                width: 20,
                                // Space between the line and its content
                                thickness: 1, // Line thickness
                              ),
                              Expanded(
                                child: Center(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: [
                                      Expanded(
                                          child: Text('Total ShelterStocks:', style: TextStyle(
                                            fontSize: isTablet?10*getScale(context):10,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w700,
                                          ),)),
                                      Expanded(
                                        child: Text(
                                            'Units: ${totalStockUnits}',
                                            style: TextStyle(
                                              fontSize: isTablet?7*getScale(context):10,
                                              color: Color(0xFF1A1AFF),
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.w700,
                                            )),
                                      ),
                                      Expanded(
                                        child:
                                        Text(
                                            'Value: ${currencyFormatter.format(totalStockValue)}',
                                            style: TextStyle(
                                              fontSize: isTablet?7*getScale(context):10,
                                              color: Color(0xFF1A1AFF),
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.w700,

                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                }
          ),
          Expanded(
            flex: 9,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0))
              ),
              child:
              Consumer<Admindata>(
                builder: (context,adminData,child)
                => ListView.builder(
                  itemCount: (adminData.allUsersData.isNotEmpty)?adminData.allUsersData.length:0,
                    itemBuilder:(context, index){
                      adminData.fetchAndStoreAllUsersData();
                      List<Map<String, dynamic>> allUserData = adminData.allUsersData;
                      var eachUser = allUserData[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(width: 1, color: Colors.grey)
                            )
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${index+1}.  ${eachUser['firstName']} ${eachUser['lastName']}',
                              style: TextStyle(fontSize: isTablet?10*getScale(context):(12.0*getScale(context)),
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w500,),

                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'ShelterStocks: ${eachUser['stockUnits']}',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: isTablet?10*getScale(context):(15 * getScale(context)),
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Value: ${currencyFormatter.format(eachUser['stockValue'])}',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: isTablet?10*getScale(context):(15 * getScale(context)),
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }
                )
              ),
            ),
          ),
        ],
      ):Center(child: CircularProgressIndicator(color: Colors.blue,))):Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 10,
            child: Container(
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CustomSearch extends SearchDelegate{
  final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: '₦',
  );
  @override
  List<Widget>? buildActions(BuildContext context) {
   return[
     IconButton(
         onPressed: (){
           query = '';
         },
         icon: Icon(Icons.clear)
     )
   ];
  }
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: (){
          close(context, null);
        },
        icon: Icon(Icons.arrow_back)
    );
  }
  @override
  Widget buildSuggestions(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    bool isTablet = screenWidth > 600;
    bool isSmallPhone = screenWidth < 413 && screenHeight<733;
    final adminProvider = Provider.of<Admindata>(context, listen: false);
    adminProvider.fetchAndStoreAllUsersData();
    List<String> allUserNames = adminProvider.allUserNames;
    List<Map<String, dynamic>> allUserData = adminProvider.allUsersData;
    List<String> matchQuery = [];
    for(var item in allUserNames){
      if(item.toLowerCase().contains(query.toLowerCase())){
        matchQuery.add(item);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
        itemBuilder: (context, index){
          int originalIndex = allUserNames.indexOf(matchQuery[index]);
          var result = allUserData[originalIndex];
          return ListTile(
            title: Text('${index+1}.  ${result['firstName']} ${result['lastName']}', style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
            ),),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('ShelterStocks: ${result['stockUnits']}', style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                  fontSize: isTablet?6*getScale(context):(13*getScale(context)),
                  color: Colors.grey
                ),),
                Text('Value: ${currencyFormatter.format(result['stockValue'])}', style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                    fontSize: isTablet?6*getScale(context):(13*getScale(context)),
                   color: Colors.grey
                ),)
              ],
            ),
          );
        }
    );
  }
  @override
  Widget buildResults(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    bool isTablet = screenWidth > 600;
    bool isSmallPhone = screenWidth < 413 && screenHeight<733;
    final adminProvider = Provider.of<Admindata>(context, listen: false);
    adminProvider.fetchAndStoreAllUsersData();
    List<String> allUserNames = adminProvider.allUserNames;
    List<Map<String, dynamic>> allUserData = adminProvider.allUsersData;
    List<String> matchQuery = [];
    for(var item in allUserNames){
      if(item.toLowerCase().contains(query.toLowerCase())){
        matchQuery.add(item);
      }
    }
    return ListView.builder(
        itemCount: matchQuery.length,
        itemBuilder: (context, index){
          int originalIndex = allUserNames.indexOf(matchQuery[index]);
          var result = allUserData[originalIndex];
          return ListTile(
            title: Text('${index+1}.  ${result['firstName']} ${result['lastName']}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('ShelterStocks: ${result['stockUnits']}',style: TextStyle(color: Colors.green, fontSize: isTablet?6*getScale(context):(10 * getScale(context)))),
                Text('Value: ${currencyFormatter.format(result['stockValue'])}',style: TextStyle(color: Colors.green, fontSize: isTablet?6*getScale(context):(10 * getScale(context))))
              ],
            ),
          );
        }
    );
  }
}
