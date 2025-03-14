import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class InternetChecker extends StatefulWidget {
  final Widget child;

  const InternetChecker({Key? key, required this.child}) : super(key: key);

  @override
  _InternetCheckerState createState() => _InternetCheckerState();
}
class _InternetCheckerState extends State<InternetChecker> {
  bool isConnectedToInternet = false;
  bool isCheckingInternet = true;
  StreamSubscription? _internetConnectionStreamSubscription;
  @override
  void initState() {
    super.initState();
    _internetConnectionStreamSubscription = InternetConnectionCheckerPlus().onStatusChange.listen((event){
      print(event);
      switch(event){
        case InternetConnectionStatus.connected:
          setState(() {
            isConnectedToInternet = true;
            isCheckingInternet = false;
          });
          break;
        case InternetConnectionStatus.disconnected:
          setState(() {
            isConnectedToInternet = false;
            isCheckingInternet = false;
          });
          break;
        default:
          setState(() {
            isConnectedToInternet = false;
            isCheckingInternet = false;
          });
          break;
      }
    });
  }

  @override
  void dispose() {
    _internetConnectionStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isCheckingInternet) {
      // Show a loading indicator while the internet connection status is being determined
      return Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    } else if (isConnectedToInternet) {
      return widget.child;
    } else {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                isConnectedToInternet ? Icons.wifi : Icons.wifi_off,
                size: 50,
                color: isConnectedToInternet ? Colors.green : Colors.red,
              ),
              Text(isConnectedToInternet ? 'You are connected to the internet.' : 'You are not connected to the internet.')
            ],
          ),
        ),
      );
    }
  }
}