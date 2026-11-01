import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tom_chat/models/user/user_model.dart';

class GenderWidget extends StatelessWidget {
  final UserModel user;
  const GenderWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    if (user.type == 1) {
      return Container(
        padding: EdgeInsets.all(2).r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.lightBlue,
        ),
        child: Icon(Icons.male, size: 15.r),
      );
    }
    return Container(
      padding: EdgeInsets.all(2).r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.pinkAccent,
      ),
      child: Icon(Icons.female, size: 15.r),
    );
  }
}
