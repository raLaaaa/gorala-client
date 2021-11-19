import 'package:flutter/material.dart';
import 'package:gorala/components/draw_triangle.dart';

import '../../constants.dart';

class SuccessfulRegistrationView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      Stack(
        children: [
          Align(alignment: Alignment.topRight, child: Triangle(color: kTitleTextColor,),),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('You will receive an email to confirm your account.', textAlign: TextAlign.center),
                SizedBox(height: 8,),
                SizedBox(
                  width: kDefaultPrimaryButtonWidth,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/',
                            (Route<dynamic> route) => false,
                      );
                    },
                    child: Text('Login'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
