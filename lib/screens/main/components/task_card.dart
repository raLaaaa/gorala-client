import 'package:flutter/material.dart';
import 'package:gorala/models/task.dart';

import '../../../constants.dart';
import '../../../extensions.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    Key key,
    this.task,
    this.press,
  }) : super(key: key);

  final Task task;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: kDefaultPadding, vertical: kDefaultPadding / 5),
      child: InkWell(
        onTap: press,
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(kDefaultPadding),
              decoration: BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: "${task.description}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).addNeumorphism(
              blurRadius: 15,
              borderRadius: 15,
              offset: Offset(5, 5),
              topShadowColor: Colors.white60,
              bottomShadowColor: Color(0xFF234395).withOpacity(0.15),
            ),
          ],
        ),
      ),
    );
  }
}
