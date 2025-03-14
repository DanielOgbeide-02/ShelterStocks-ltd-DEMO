import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shelterstocks_prototype2/main.dart';
import '../../helpers/functions/getScale.dart';
import '../../../presentation/registeration/pages/before_signup/PersonalInfoScreen.dart';

class Buttons extends StatefulWidget {
  Buttons({Key?key, this.width, this.height, this.buttonText, this.buttonColor, this.buttonTextColor, this.onPressed, this.isLoading = false, this.isPressed = false}):super(key: key){}
  final double? width;
  final double? height;
  final String? buttonText;
  final Color? buttonTextColor;
  final Color? buttonColor;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isPressed;

  @override
  State<Buttons> createState() => _ButtonsState();
}

class _ButtonsState extends State<Buttons> {

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    // Check if the device is a tablet (adjust threshold as needed)
    bool isTablet = screenWidth > 600;
    bool isSmallPhone = screenWidth < 413 && screenHeight<733;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.shade700),
        borderRadius: BorderRadius.circular(5.r),
        color: widget.buttonColor,                    ),
      width: widget.width,
      height: isSmallPhone?40*getScale(context):widget.height,
      child: TextButton(
          onPressed: (widget.isPressed)?null:widget.onPressed,
          child:
              (widget.isLoading)?Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${widget.buttonText}',
                    style: TextStyle(
                        color: widget.buttonTextColor,
                        fontSize: isSmallPhone?13*getScale(context):(isTablet?22:18.sp),
                        letterSpacing: 1,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: isSmallPhone?15*getScale(context):(20.w),),
                  SizedBox(
                    height: isSmallPhone?13*getScale(context):(isTablet?20:18.h),
                    width:  isSmallPhone?13*getScale(context):(isTablet?20:18.w),
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                ],
              ):
          Text(
            '${widget.buttonText}',
            style: TextStyle(
                color: widget.buttonTextColor,
                fontSize: isSmallPhone?13*getScale(context):(isTablet?22:18),
                letterSpacing: 1,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
            ),
          )
      ),
    );
  }
}