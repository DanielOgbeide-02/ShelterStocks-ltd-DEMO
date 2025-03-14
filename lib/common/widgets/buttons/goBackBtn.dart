import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class goBackBtn extends StatelessWidget {
  goBackBtn({
    this.size
  }){}

  final double? size;

  @override
  Widget build(BuildContext context) {
    return
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Icon(FontAwesomeIcons.arrowLeft,
            color: Color(0xFF1A1AFF), size: size));
  }
}
