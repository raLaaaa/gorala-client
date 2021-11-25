import 'package:flutter/material.dart';
import 'package:gorala/animations/animated_check.dart';
import 'package:gorala/models/task.dart';

import '../../../constants.dart';

class TaskCard extends StatefulWidget {
  const TaskCard({
    Key key,
    @required this.task,
    @required this.toggleFinish,
    @required this.press,
  }) : super(key: key);

  final Task task;
  final VoidCallback press;
  final VoidCallback toggleFinish;

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _animation = new Tween<double>(begin: 0, end: 1).animate(new CurvedAnimation(parent: _animationController, curve: Curves.easeInOutCirc));

    if (widget.task.isFinished) {
      _animationController.value = 1;
    } else {
      _animationController.value = 0;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: kDefaultPadding, vertical: kDefaultPadding / 5),
      child: Container(
        padding: EdgeInsets.only(left: kDefaultPadding, right: kDefaultPadding, top: kDefaultPadding),
        decoration: BoxDecoration(
          color: kPrimaryColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: widget.press,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: "${widget.task.description}",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            decoration: widget.task.isFinished ? TextDecoration.lineThrough : TextDecoration.none,
                            decorationThickness: 1.25),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              color: Colors.white,
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(bottom: 8),
              child: Container(
                width: 26,
                height: 26,
                child: ElevatedButton(
                  onPressed: () {
                    if (_animationController.isCompleted) {
                      _animationController.reverse().whenComplete(() => {widget.toggleFinish(), _animationController.value = 1});
                    } else if (_animationController.isDismissed) {
                      _animationController.forward().whenComplete(() => {widget.toggleFinish(), _animationController.value = 0});
                    }
                  },
                  child: Center(
                    child: Container(
                        child: AnimatedCheck(
                      progress: _animation,
                      size: 28,
                    )),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    primary: Colors.white, // <-- Button color
                    onPrimary: kTitleTextColor, // <-- Splash color
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
