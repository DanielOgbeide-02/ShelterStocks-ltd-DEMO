
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shelterstocks_prototype2/common/helpers/functions/getScale.dart';
import 'package:shelterstocks_prototype2/presentation/provider/user/userData.dart';

class Portfoliopage extends StatefulWidget {
  static String id = 'Portfolio_screen';
  const Portfoliopage({super.key});

  @override
  State<Portfoliopage> createState() => _PortfoliopageState();
}

class _PortfoliopageState extends State<Portfoliopage> {

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF1A1AFF),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Portfolio', style: TextStyle(
          color: Colors.white,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w900,
        ),),
        centerTitle: true,
      ),
      body: Consumer<UserData>(
        builder: (context, userProvider, child) {
          return Column(
            children: [
              Container(
                height: isTablet?45*getScale(context):(70*getScale(context)),
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(5)
                ),
                margin: EdgeInsets.only(top: 10, left: 10*getScale(context), right: 10*getScale(context)),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ShelterStock Units: ',style: TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w500,
                              ),),
                              Text('${userProvider.currentUser?.stockUnits}', style: TextStyle(
                                color: Color(0xFF1A1AFF),
                                fontSize: isTablet?10*getScale(context):(15*getScale(context)),
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w700,
                              )),
                            ],
                          ),
                        ),
                      ),
                      VerticalDivider(
                        color: Colors.grey, // Line color
                        width: 20, // Space between the line and its content
                        thickness: 1,
                      ),
                      Expanded(
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text('ShelterStock Value: ', style: TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w500,
                              ),),
                              Text('${currencyFormatter.format(userProvider.currentUser?.stockValue)}', style: TextStyle(
                                color: Color(0xFF1A1AFF),
                                fontSize: isTablet?10*getScale(context):(15*getScale(context)),
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w700,
                              )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(  // This allows the TabBarView to fill the remaining space
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TabBar(
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorColor: Color(0xFF1A1AFF),
                        dividerColor: Colors.grey,
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.grey,
                        tabs: [
                          Tab(text: 'Properties'),
                          Tab(text: 'Investments'),
                        ],
                      ),
                      Expanded( // Expanded to ensure it fills the remaining space
                        child: TabBarView(
                          children: [
                            Container(
                              child: Center(
                                child: Text(
                                  'You don\'t have any properties.',
                                  style: TextStyle(color: Colors.grey, fontSize: 18),
                                ),
                              ),
                            ),
                            Container(
                              child: Center(
                                child: Text(
                                  'You don\'t have any Investments.',
                                  style: TextStyle(color: Colors.grey, fontSize: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
