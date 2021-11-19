import 'package:flutter/material.dart';
import 'package:gorala/constants.dart';



class CustomDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 145,
          child: Divider(
            thickness: 2,
            color: kTitleTextColor.withOpacity(0.75),
          ),
        ),
        SizedBox(width: 4,),
        Container(
          width: 20,
          child: Divider(
            thickness: 2,
            color: kTitleTextColor.withOpacity(0.75),
          ),
        ),
      ],
    );
  }
}
