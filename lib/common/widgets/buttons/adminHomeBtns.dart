import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shelterstocks_prototype2/common/widgets/buttons/buttons.dart';

class Adminhomebtns extends StatelessWidget {
  Adminhomebtns({required this.buttonText, required this.buttonIcon,required this.onPressed, this.enterText}){}
  final String buttonText;
  final IconData buttonIcon;
  final Function? onPressed;
  final Text? enterText;
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
    bool isSmallPhone = screenWidth < 413 && screenHeight<800;
    // ScreenUtil.init(context, designSize: Size(375, 690));
    return GestureDetector(
      onTap: (){
        onPressed!();
      },
      child:
      Container(
        padding: EdgeInsets.symmetric(horizontal: 10*getScale(context), vertical: 10*getScale(context)),
        height: isSmallPhone?85*getScale(context):(isTablet?90*getScale(context):100.sp),
        width: isSmallPhone?75*getScale(context):(isTablet?86.sp:90.sp),
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
        child:
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Icon(
                      buttonIcon,
                      color: Color(0xFF1A1AFF),
                      size: isSmallPhone?30*getScale(context):(isTablet?36.sp:40.sp),
                    ),
                  ),
                  SizedBox(
                    height: isTablet?6.h:10.h,
                  ),
                  Expanded(
                    child: Text(
                      buttonText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: isSmallPhone?10*getScale(context):(isTablet?7.sp:11.sp),
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(width: 10*getScale(context),),
            VerticalDivider(
              width: 1,
              color: Colors.grey.shade300,
            ),
            Expanded(
              flex: 3,
              child:
              Center(
                child: Container(
                  margin: EdgeInsets.only(left: 3*getScale(context)),
                    child: enterText!
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}