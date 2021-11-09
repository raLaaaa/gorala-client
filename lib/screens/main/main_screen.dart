import 'package:flutter/material.dart';
import 'package:gorala/responsive.dart';
import 'components/list_of_tasks.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // It provide us the width and height
    return Scaffold(
      body: Responsive(
        // Let's work on our mobile part
        mobile: ListOfTasks(),
        tablet: Row(
          children: [
            Expanded(
              flex: 6,
              child: ListOfTasks(),
            ),
          ],
        ),
        desktop: Row(
          children: [
            Expanded(
              child: ListOfTasks(),
            ),
          ],
        ),
      ),
    );
  }
}
