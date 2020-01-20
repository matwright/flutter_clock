// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:developer';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';
import 'package:metropolis_clock/dial.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:vector_math/vector_math_64.dart' show radians;
import 'drawn_hand.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';

/// Total distance traveled by a second or a minute hand, each second or minute,
/// respectively.
final radiansPerTick = radians(360 / 60);

/// Total distance traveled by an hour hand, each hour, in radians.
final radiansPerHour = radians(360 / 12);

class MetropolisClock extends StatefulWidget {
  const MetropolisClock(this.model);

  final ClockModel model;

  @override
  _MetropolisClockState createState() => _MetropolisClockState();
}

class _MetropolisClockState extends State<MetropolisClock> {
  final FlareControls _controls = FlareControls();

  var _now = DateTime.now();
  var _temperature = '';
  var _temperatureRange = '';
  var _condition = '';
  var _location = '';
  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    // Set the initial values.
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(MetropolisClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      _temperature = widget.model.temperatureString;
      _temperatureRange = '(${widget.model.low} - ${widget.model.highString})';
      _condition = widget.model.weatherString;
      _location = widget.model.location;
    });
  }

  var currentSec = 1;
  void _updateTime() {
    if (_now.second > 0 && _now.second % 55 == 0) {
      if (currentSec != _now.second) {
        _controls.play('Default');
      }

      currentSec = _now.second;
    } else {
      currentSec = _now.second;
    }
    setState(() {
      _now = DateTime.now();
      // Update once per second. Make sure to do it at the beginning of each
      // new second, so that the clock is accurate.

      _timer = Timer(
        Duration(seconds: 1) - Duration(seconds: _now.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).copyWith(
            // Hour hand.
            primaryColor: Colors.white30,
            // Minute hand.
            highlightColor: Colors.white70,
            // Second hand.
            accentColor: Colors.white30,
            backgroundColor: Colors.black12,
          )
        : Theme.of(context).copyWith(
            primaryColor: Colors.white,
            accentColor: Colors.white,
            backgroundColor: Color(0xFF3C4043));

    final time = DateFormat.Hms().format(DateTime.now());
    final mediaHeight = MediaQuery.of(context).size.height;

    final double cornerSize = 75.00;
    onBottom(Widget child) => Positioned.fill(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: child,
          ),
        );
    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Analog clock with time $time',
        value: time,
      ),
      child: Container(
          child: Stack(
        children: <Widget>[
          Positioned.fill(child: AnimatedBackground()),
          onBottom(AnimatedWave(
            height: mediaHeight,
            speed: 1.0,
          )),
          onBottom(AnimatedWave(
            height: mediaHeight * 0.6,
            speed: 0.9,
            offset: pi,
          )),
          onBottom(AnimatedWave(
            height: mediaHeight * 0.3,
            speed: 1.2,
            offset: pi / 2,
          )),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                  child: Align(
                child: Text(
                  DateFormat('EE').format(_now) + '\n' + _now.day.toString(),
                  style: TextStyle(
                    color: Theme.of(context).cardColor,
                    fontFamily: 'Limelight',
                    fontSize: 32,
                    shadows: <Shadow>[
                      Shadow(
                        offset: Offset(2.0, 2.0),
                        blurRadius: 8.0,
                        color: Colors.white70.withOpacity(.6),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                alignment: Alignment.center,
              )),
              Expanded(
                flex: 2,
                child: Stack(
                  children: [
                    new Container(
                      //color: customTheme.backgroundColor,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black87,
                      ),

                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      padding: const EdgeInsets.all(5.0),
                      margin: const EdgeInsets.all(5.0),
                      child: new CustomPaint(
                        painter: new ClockDialPainter(),
                      ),
                    ),
                    // Example of a hand drawn with [Container].

                    DrawnHand(
                      circularIndicator: false,
                      color: customTheme.primaryColor,
                      thickness: 6,
                      size: 0.4,
                      indicator: _now.hour.toString(),
                      angleRadians: _now.hour * radiansPerHour +
                          (_now.minute / 60) * radiansPerHour,
                    ),
                    // Example of a hand drawn with [CustomPainter].
                    //Minute Hand
                    DrawnHand(
                      circularIndicator: false,
                      color: customTheme.highlightColor,
                      thickness: 4,
                      size: 0.7,
                      indicator: _now.minute.toString(),
                      angleRadians: _now.minute * radiansPerTick,
                    ),

                    //Second hand
                    DrawnHand(
                      circularIndicator: false,
                      color: customTheme.accentColor,
                      thickness: 2,
                      size: 0.7,
                      indicator: _now.second.toString(),
                      angleRadians: _now.second * radiansPerTick,
                    ),
                    Center(
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: customTheme.backgroundColor,
                        ),
                      ),
                    ),

                  ],
                ),
              ),
              Expanded(
                child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      DateFormat('LLL').format(_now) +
                          '\n' +
                          _now.year.toString(),
                      style: TextStyle(
                        color: Theme.of(context).cardColor,
                        fontFamily: 'Limelight',
                        fontSize: 32,
                        shadows: <Shadow>[
                          Shadow(
                            offset: Offset(2.0, 2.0),
                            blurRadius: 8.0,
                            color: Colors.white70.withOpacity(.6),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    )),
              )
            ],
          ),
          Positioned(
            bottom: 10,
            left: 10,
            child: Image.asset(
              'assets/corner.png',
              width: cornerSize,
            ),
          ),
          Positioned(
              bottom: 10,
              right: 10,
              child: RotatedBox(
                  quarterTurns: 3,
                  child: Image.asset(
                    'assets/corner.png',
                    width: cornerSize,
                  ))),
          Positioned(
              top: 10,
              right: 10,
              child: RotatedBox(
                  quarterTurns: 6,
                  child: Image.asset(
                    'assets/corner.png',
                    width: cornerSize,
                  ))),
          Positioned(
              top: 10,
              left: 10,
              child: RotatedBox(
                  quarterTurns: 5,
                  child: Image.asset(
                    'assets/corner.png',
                    width: cornerSize,
                  )))
        ],
      )),
    );
  }
}

class AnimatedWave extends StatelessWidget {
  final double height;
  final double speed;
  final double offset;

  AnimatedWave({this.height, this.speed, this.offset = 0.0});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        height: height,
        width: constraints.biggest.width,
        child: ControlledAnimation(
            playback: Playback.LOOP,
            duration: Duration(milliseconds: (5000 / speed).round()),
            tween: Tween(begin: 0.0, end: 2 * pi),
            builder: (context, value) {
              return CustomPaint(
                foregroundPainter: CurvePainter(value + offset),
              );
            }),
      );
    });
  }
}

class CurvePainter extends CustomPainter {
  final double value;

  CurvePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final black = Paint()..color = Colors.black54.withAlpha(90);
    final path = Path();

    final y1 = sin(value);
    final y2 = sin(value + pi / 2);
    final y3 = sin(value + pi);

    final startPointY = size.height * (0.5 + 0.4 * y1);
    final controlPointY = size.height * (0.5 + 0.4 * y2);
    final endPointY = size.height * (0.5 + 0.4 * y3);

    path.moveTo(size.width * 0, startPointY);
    path.quadraticBezierTo(
        size.width * 0.5, controlPointY, size.width, endPointY);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, black);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class AnimatedBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tween = MultiTrackTween([
      Track("color1").add(Duration(seconds: 3),
          ColorTween(begin: Colors.black, end: Colors.black54)),
      Track("color2").add(Duration(seconds: 3),
          ColorTween(begin: Colors.black54, end: Colors.black))
    ]);

    return ControlledAnimation(
      playback: Playback.MIRROR,
      tween: tween,
      duration: tween.duration,
      builder: (context, animation) {
        return Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [animation["color1"], animation["color2"]])),
        );
      },
    );
  }
}
