import 'package:flutter/material.dart';
import 'package:gorala/responsive.dart';
import 'components/list_of_emails.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // It provide us the width and height
    return Scaffold(
      body: Responsive(
        // Let's work on our mobile part
        mobile: ListOfEmails(),
        tablet: Row(
          children: [
            Expanded(
              flex: 6,
              child: ListOfEmails(),
            ),
          ],
        ),
        desktop: Row(
          children: [
            Expanded(
              child: ListOfEmails(),
            ),
          ],
        ),
      ),
    );
  }
}
