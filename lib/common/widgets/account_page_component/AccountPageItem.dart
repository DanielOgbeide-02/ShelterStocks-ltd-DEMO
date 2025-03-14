import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shelterstocks_prototype2/common/helpers/functions/getScale.dart';

class accountPageItem extends StatelessWidget {
  accountPageItem({
    super.key,
    this.itemName,
    this.onPressed
  }){}
  final String? itemName;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    // Check if the device is a tablet (adjust threshold as needed)
    bool isTablet = screenWidth > 600;
    bool isSmallPhone = screenWidth < 413 && screenHeight<733;
    return
      GestureDetector(
      onTap: onPressed,
      child:
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(color: Colors.grey.shade300, width: 1)
            )
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              itemName!,
              style: TextStyle(
                fontSize: isTablet?10*getScale(context):(isSmallPhone?15.0*getScale(context):(17.0*getScale(context))),
                letterSpacing: 0.0,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w700,
              ),
            ),
            Icon(
              Icons.chevron_right_sharp,
              color: Color(0xFF1A1AFF),
              size: isTablet?20*getScale(context):(isSmallPhone?20.0*getScale(context):(24.0*getScale(context))),
            ),
          ],
        ),
      ),
    );
  }
}
