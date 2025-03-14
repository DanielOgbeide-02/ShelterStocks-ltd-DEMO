import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shelterstocks_prototype2/presentation/intro/pages/ShelterStocksGetStartedScreen.dart';

class splashScreen extends StatefulWidget {
  const splashScreen({super.key});

  @override
  State<splashScreen> createState() => _splashScreenState();
}

class _splashScreenState extends State<splashScreen> with SingleTickerProviderStateMixin{

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    Future.delayed(Duration(seconds: 2),(){
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=> getStartedScreen()));
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.blue, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight
          )
        ),
        child: Column(
          children: [
            Text(
              'ShelterStocks'
            )
          ],
        ),
      ),
    );
  }
}
