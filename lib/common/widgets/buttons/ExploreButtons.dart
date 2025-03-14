import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExploreButtons extends StatelessWidget {
  ExploreButtons({required this.buttonText, required this.buttonIcon,required this.onPressed}){}
  final String buttonText;
  final IconData buttonIcon;
  final Function? onPressed;
  double getScale(BuildContext context) {
    const double referenceWidth = 400;
    double screenWidth = MediaQuery.of(context).size.width;
    double fraction = screenWidth / referenceWidth;
    return fraction;
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    // Check if the device is a tablet (adjust threshold as needed)
    bool isTablet = screenWidth > 600;
    bool isSmallPhone = screenWidth < 413 && screenHeight<733;
    // ScreenUtil.init(context, designSize: Size(375, 690));
    return GestureDetector(
      onTap: (){
        onPressed!();
      },
      child: Container(
        height: isSmallPhone?95*getScale(context):(isTablet?96*getScale(context):100.sp),
        width: isSmallPhone?90*getScale(context):(isTablet?86*getScale(context):90.sp),
        decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(15.r),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: Offset(2, 2)
              )
            ]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              buttonIcon,
              color: Color(0xFF1A1AFF),
              size: isSmallPhone?35*getScale(context):(isTablet?30*getScale(context):40.sp),
            ),
            SizedBox(
              height: isSmallPhone?5*getScale(context):(isTablet?6.h:10.h),
            ),
            Text(
                '$buttonText',
              style: TextStyle(
                fontSize: isSmallPhone?13*getScale(context):(isTablet?9*getScale(context):12.sp),
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500
              ),
            )
          ],
        ),
      ),
    );
  }
}