import 'package:flutter/material.dart';

class SuccessfulRegistrationView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('You will receive an email to confirm your account.'),
            SizedBox(height: 8,),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                      (Route<dynamic> route) => false,
                );
              },
              child: Text('Go to login page'),
            ),
          ],
        ),
      ),
    );
  }
}
