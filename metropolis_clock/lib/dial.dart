import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class ClockDialPainter extends CustomPainter {
  final tickMarkLength = 5.0;
  final tickMarkWidth = 7.5;

  final Paint tickPaint;
  final TextPainter textPainter;
  final TextStyle textStyle;
  final Paint numeralPainter;

  ClockDialPainter()
      : numeralPainter = new Paint(),
        tickPaint = new Paint(),
        textPainter = new TextPainter(
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
        ),
        textStyle = TextStyle(
          color: Colors.white,
          fontFamily: 'MetropolisClock',
          fontSize: 60.0,
          shadows: <Shadow>[
            Shadow(
              offset: Offset(2.0, 2.0),
              blurRadius: 5,
              color: Colors.white70.withOpacity(.3),
            ),
            Shadow(
              offset: Offset(5.0, 5.0),
              blurRadius: 5,
              color: Colors.white70.withOpacity(.3),
            ),
          ],
        ) {
    tickPaint.color = Colors.white;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final angle = 2 * pi / 60;
    final radius = size.shortestSide / 2;
    canvas.save();

    // Sets the position of the canvas to the center of the layout
    canvas.translate(size.width / 2, size.height / 2);
    canvas.drawCircle(Offset(0, 0), 5, tickPaint);

    for (var i = 0; i < 60; i++) {
      //Decides when to  make the length and stroke of the tick marker,
      // longer and thicker depending on its position on the clock.

      tickPaint.strokeWidth = tickMarkWidth;
      canvas.drawLine(new Offset(0.0, -radius),
          new Offset(0.0, -radius + tickMarkLength), tickPaint);

      //draw the text
      if (i % 6 == 0) {
        canvas.save();

        canvas.translate(0.0, -radius + (i > 0 ? 35.00 : 40.00));

        textPainter.text = new TextSpan(
          text: '${i == 0 ? 10 : i ~/ 6}',
          style: textStyle,
        );

        //helps make the text painted vertically
        canvas.rotate(-angle * i);

        textPainter.layout();

        textPainter.paint(canvas,
            new Offset(-(textPainter.width / 2), -(textPainter.height / 2)));

        canvas.restore();
      }
      canvas.rotate(angle);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    //We have no reason to repaint so we return false.
    return false;
  }
}
