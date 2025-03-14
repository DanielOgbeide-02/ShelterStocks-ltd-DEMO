import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shelterstocks_prototype2/common/widgets/buttons/buttons.dart';

import '../../helpers/functions/getScale.dart';
import '../../../presentation/provider/user/userData.dart';

class userProfileItem extends StatelessWidget {
   userProfileItem({
    required this.profileItemHeader,
     required this.profileItem,
  }){}

  final String profileItemHeader;
   final Widget profileItem;


   @override
  Widget build(BuildContext context) {
     var screenWidth = MediaQuery.of(context).size.width;
     var screenHeight = MediaQuery.of(context).size.height;
     // Check if the device is a tablet (adjust threshold as needed)
     bool isTablet = screenWidth > 600;
     bool isSmallPhone = screenWidth < 413 && screenHeight<733;
    return
      Container(
      padding: EdgeInsets.only(top: isTablet?12*getScale(context):(isSmallPhone?15*getScale(context):(20.sp)), bottom: isTablet?12*getScale(context):(isSmallPhone?15*getScale(context):(20.sp))),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: CupertinoColors.activeBlue, width: 2)
          )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${profileItemHeader}',
            style: TextStyle(
                fontSize: isTablet?10*getScale(context):(isSmallPhone?15*getScale(context):(14*getScale(context))),
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
            ),
          ),
          Consumer<UserData>(
              builder: (context, userProvider, child){
                return
                  profileItem;
              }
          )
        ],
      ),
    );
  }
}
