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

class _TaskCardState extends State<TaskCard> with TickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animation;

  AnimationController _fadeAnimationController;
  Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 350));
    _animation = new Tween<double>(begin: 0, end: 1).animate(new CurvedAnimation(parent: _animationController, curve: Curves.easeInOutCirc));

    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 750),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeOut,
    );

    if (widget.task.isFinished) {
      _animationController.value = 1;
    } else {
      _animationController.value = 0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fadeAnimationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _fadeAnimationController.forward();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        child: Padding(
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
                  height: 50,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 150,
                          height: 26,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_animationController.isCompleted) {
                                _animationController.reverse().whenComplete(() => {widget.toggleFinish(), _animationController.value = 1});
                              } else if (_animationController.isDismissed) {
                                _animationController.forward().whenComplete(() => {widget.toggleFinish(), _animationController.value = 0});
                              }
                            },
                            child: Container(
                                child: AnimatedCheck(
                                  progress: _animation,
                                  size: 28,
                                )),
                            style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                              primary: Colors.white, // <-- Button color
                              onPrimary: kTitleTextColor, // <-- Splash color
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          height: 50,
                          width: 40,
                          child: Row(
                            children: [
                              Text('9', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white)),
                              Icon(
                                Icons.replay,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
