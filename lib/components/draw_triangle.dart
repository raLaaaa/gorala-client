import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class Triangle extends StatelessWidget {
  const Triangle({
    Key key,
    this.color = kTitleTextColor,
    this.width = 100,
    this.height = 100,
  }) : super(key: key);
  final Color color;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ShapesPainter(color),
      child: Container(
        height: width,
        width: height,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0, bottom: 16),
          ),
        ),
      ),
    );
  }
}

class _ShapesPainter extends CustomPainter {
  final Color color;

  _ShapesPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = color;
    var path = Path();
    path.lineTo(size.width, 0);
    path.lineTo(size.height, size.width);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
