import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shelterstocks_prototype2/common/helpers/functions/getScale.dart';
import 'package:shelterstocks_prototype2/common/widgets/buttons/buttons.dart';

class InputField extends StatefulWidget {
  InputField({this.hintText, this.textfieldWidth, this.controller_, required this.obscureText, this.inputType, this.isPassword = false, this.autoFocus}){}
  final String? hintText;
  final double? textfieldWidth;
  final TextEditingController? controller_;
  bool obscureText = false;
  final TextInputType? inputType;
  final bool isPassword;
  final bool? autoFocus;


  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  @override
  Widget build(BuildContext context) {
    // Get screen width and height
    var screenWidth = MediaQuery.of(context).size.width;
    // Check if the device is a tablet (adjust threshold as needed)
    bool isTablet = screenWidth > 600;
    return Container(
      width: widget.textfieldWidth,
      height: isTablet?40*getScale(context):40.sp,
      child: TextField(
        autofocus: widget.autoFocus??false,
        keyboardType: widget.inputType,
          obscureText: widget.obscureText,
        controller: widget.controller_,
        decoration: InputDecoration(
          hintText: '${widget.hintText}',
          hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
            fontSize: isTablet?12*getScale(context):13.sp
          ),
          border: OutlineInputBorder(borderSide: BorderSide(color: CupertinoColors.activeBlue)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: CupertinoColors.activeBlue)),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: CupertinoColors.activeBlue)),
          suffixIcon: (widget.isPassword)?
              IconButton(
                  onPressed: (){
                    onPressed: setState(() {
                      widget.obscureText = !widget.obscureText;
                    });
                  },
                  icon: Icon(
                    (widget.obscureText)?Icons.visibility_off:Icons.visibility,
                  ),
              ):null
        ),
      ),
    );
  }
}


