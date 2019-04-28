import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import './time_painter.dart';
import './utils.dart';

class TimeTimer extends StatefulWidget {
  final double seconds;

  final bool isActive;

  final Function onDrag;
  final Widget child;

  final double radius;

  final Color color;

  TimeTimer({
    @required this.seconds,
    this.isActive = false,
    this.radius = 300,
    this.onDrag ,
    this.child,
    this.color
  });

  @override
  _TimeTimerState createState() => _TimeTimerState();
}

class _TimeTimerState extends State<TimeTimer> {
  Offset start;

  double _angle;

  Timer timer;

  double temp;

  @override
  void initState() {
    super.initState();
    this._angle = secondsToAngle(widget.seconds);
    this.timer = Timer.periodic(const Duration(milliseconds: 100), tick);
  }

  @override
  void dispose() {
    super.dispose();

    this.timer.cancel();
  }

  tick(Timer t) {
    if (!widget.isActive) return;

//    debugPrint((angleToSeconds(this._angle)).toString());
    setState(() {
      _angle -= 0.6 * (pi / 180);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.radius,
      height: widget.radius,
      child: TimeTimerPainter(
        isActive: widget.isActive,
        color: widget.color,
        onDrag: (angle) {
          if (widget.onDrag != null) {
            widget.onDrag(angleToSeconds(angle));
          }

          setState(() {
            this._angle = angle;
          });
        },
        angle: this._angle,
      )
    );
  }
}
