import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:time_timer/presentation/timer.dart';

class TimeTimerPainter extends StatefulWidget {
  final double angle;

  final bool isActive;

  final Function onDrag;

  final Widget child;

  final Color color;

  final TimerDirection direction;


  TimeTimerPainter({
    this.angle,
    this.isActive = false,
    this.onDrag,
    this.child,
    this.color = Colors.red,
    this.direction = TimerDirection.CLOCKWISE
  });

  @override
  _TimeTimerPainterState createState() => _TimeTimerPainterState();
}

class _TimeTimerPainterState extends State<TimeTimerPainter> {
  Offset start;
  double startAngle;

  Offset prev;
  double prevAngle;

  DrawTimer _painter;

  double _angle;
  double _testAngle;

  GlobalKey globalKey;


  @override
  void initState() {
    super.initState();
    this.globalKey = new GlobalKey();
    _calculate();
  }

  @override
  void didUpdateWidget(TimeTimerPainter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.angle != widget.angle ||
        oldWidget.color != widget.color ||
        oldWidget.direction != widget.direction
    ) {
      _calculate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: _onPanDown,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      key: globalKey,
      child: CustomPaint(
        painter: BasePainter(direction: widget.direction),
        foregroundPainter: _painter,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: widget.child,
        ),
      ),
    );
  }

  _calculateAngle(double angle) {
    if (angle.isNaN) angle = 0.0;

    if (angle < 0) angle = 0.0;
    if (angle > 360) angle = 360.0;

    return angle;
  }

  _calculate() {
    final angle = _calculateAngle(widget.angle);
    this._angle = angle;

    _painter = DrawTimer(
        color: widget.color,
        angle: widget.direction != TimerDirection.COUNTER_CLOCKWISE ? -this._angle : this._angle
    );
  }

  _onPanDown(DragDownDetails e) {
    if (widget.isActive) return;

    var position = e.globalPosition;
    var vector = getVector(globalKey, position);

    debugPrint("START: ${position.toString()}");

    this.start = vector;
    this.startAngle = this._angle;
    this.prev = vector;
    this.prevAngle = 0;

    _testAngle = 0;
  }

  _onPanUpdate(DragUpdateDetails e) {
    if (widget.isActive) return;

    var position = e.globalPosition;

    var vector = getVector(globalKey, position);
    var vectorDirection = getRotationDirection(this.prev, vector);
    var angle = getAngle(this.start, this.prev);

//    debugPrint("CurrentAngle: ${_angle}, Angle: $angle, DIR: ${dir}");

    if (_testAngle.isNaN) _testAngle = 0;

    _testAngle += (prevAngle - angle).abs() * (!(vectorDirection ^ (widget.direction != TimerDirection.COUNTER_CLOCKWISE)) ? -1 : 1);

//    debugPrint("$_testAngle");


    if (startAngle + _testAngle < 0 && vectorDirection) {
      widget.onDrag(0.0);
      return;
    }

    if (startAngle + _testAngle > 360 && !vectorDirection) {
      widget.onDrag(360.0);
      return;
    }

    widget.onDrag(startAngle + _testAngle);



    this.prev = vector;
    this.prevAngle = angle;
  }

  _onPanEnd(DragEndDetails e) {
    if (widget.isActive) return;

    debugPrint("DRAG ENDED.");
  }


  getVector(GlobalKey globalKey, Offset offset) {
    final RenderBox renderBoxRed = globalKey.currentContext.findRenderObject();
    final positionRed = renderBoxRed.localToGlobal(Offset.zero);
    final size = renderBoxRed.size;

    final center = Offset(size.width / 2 + positionRed.dx, size.height / 2 + positionRed.dy);
    final curPos = offset;
    final vector = curPos - center;

    return vector;
  }

  getAngle(Offset v1, Offset v2) {
    var dotProduct = v1.dx * v2.dx + v1.dy * v2.dy;

    var lengthOfV1 = getLengthOfVector(v1);
    var lengthOfV2 = getLengthOfVector(v2);

    var angle = acos(dotProduct / (lengthOfV1 * lengthOfV2)) * (180 / pi);

    if (angle.isNaN) return 0.0;
    return angle;
  }

  getRotationDirection(Offset v1, Offset v2) {
    var crossProduct = v1.dx * v2.dy - v1.dy * v2.dx;

    var lengthOfV1 = getLengthOfVector(v1);
    var lengthOfV2 = getLengthOfVector(v2);

    return asin(crossProduct / (lengthOfV1 * lengthOfV2)) > 0;
  }

  getLengthOfVector(Offset v) {
    return sqrt(v.dx * v.dx + v.dy * v.dy);
  }
}


class BasePainter extends CustomPainter {

  final TimerDirection direction;
  final TextPainter textPainter;
  final TextStyle textStyle;


  BasePainter({this.direction}) : textPainter = new TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.rtl,
    ),
    textStyle = TextStyle(
      color: Colors.black,
      fontFamily: 'Arial',
      fontSize: 27.5,
      fontWeight: FontWeight.w500
    );

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width - 80;
    final height = size.height - 80;

    final radius = min(width, height) / 2;
    final radian = 6 * (pi / 180);

    final center = Offset(size.width / 2, size.height / 2);

    final transparentPainter = _getPaint(color: Colors.transparent, style: PaintingStyle.fill);
    final linePainter = _getPaint(color: Colors.black, width: 1.0, style: PaintingStyle.fill);
    final boldLinePainter = _getPaint(color: Colors.black, width: 3.0, style: PaintingStyle.fill);

    canvas.save();
    canvas.translate(center.dx, center.dy);

    for(int i = 0; i < 60; i++) {
      if (i % 5 == 0) {
        canvas.drawLine(Offset(0, -radius + 10), Offset(0, - radius), boldLinePainter);

        canvas.save();
        canvas.translate(0, -radius - 20);
        canvas.rotate(-radian * i);

        final text = this.direction != TimerDirection.CLOCKWISE ? (i % 60).toInt().toString() : ((60 - i) % 60).toInt().toString();

        textPainter.text = TextSpan(text: text, style: textStyle);
        textPainter.layout();
        textPainter.paint(canvas, new Offset(-(textPainter.width / 2), -(textPainter.height / 2)));

        canvas.restore();

      } else {
        canvas.drawLine(Offset(0, -radius + 9), Offset(0, -radius + 3),
            linePainter);
      }
      canvas.rotate(radian);
    }

    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), transparentPainter);
    canvas.restore();
  }

  Paint _getPaint({@required Color color, double width, PaintingStyle style}) =>
      Paint()
        ..color = color
        ..strokeCap = StrokeCap.round
        ..style = style ?? PaintingStyle.stroke
        ..strokeWidth = width ?? 12.0;

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

}

class DrawTimer extends CustomPainter {
  final Color color;
  final double angle;

  DrawTimer({this.color = Colors.green, this.angle = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width - 100;
    final height = size.height - 100;

    final radius = min(width, height) / 2;
    final radian = angle * (pi / 180);

    final center = Offset(size.width / 2, size.height / 2);

    final circlePainter = _getPaint(color: this.color, style: PaintingStyle.fill);
    final innerCirclePainter = _getPaint(color: Colors.white, style: PaintingStyle.fill);

    final rrect = RRect.fromLTRBR(-3.5, 0, 3.5, -35, Radius.circular(3.0));

    Path path = Path();
    path.addOval(Rect.fromCircle(center: Offset.zero, radius: 20));
    path.addRRect(rrect);
    path.close();

    canvas.save();
    canvas.translate(center.dx, center.dy);

    canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: radius), pi * 3 / 2, radian, true, circlePainter);

    canvas.save();
    canvas.rotate(radian);

    canvas.drawShadow(path, Colors.grey, 4.0, true);
    canvas.drawPath(path, innerCirclePainter);

    canvas.restore();

    canvas.restore();
  }

  Paint _getPaint({@required Color color, double width, PaintingStyle style}) =>
      Paint()
        ..color = color
        ..strokeCap = StrokeCap.round
        ..style = style ?? PaintingStyle.stroke
        ..strokeWidth = width ?? 12.0;

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

}