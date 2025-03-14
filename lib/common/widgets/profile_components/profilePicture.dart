
import 'package:flutter/material.dart';

class profilePicture extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback onTap;

  const profilePicture({
    Key? key,
    required this.imageUrl,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          color: Color(0xFF1A1AFF),
          shape: BoxShape.circle,
          image: imageUrl != null && imageUrl!.isNotEmpty
              ? DecorationImage(
            image: NetworkImage(imageUrl!),
            fit: BoxFit.cover,
          )
              : null,
        ),
        child: imageUrl == null || imageUrl!.isEmpty
            ? Center(
          child: Icon(
            Icons.person,
            size: 35,
            color: Colors.white,
          ),
        )
            : null,
      ),
    );
  }
}