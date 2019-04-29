import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:time_timer/presentation/timer.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:screen/screen.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audio_cache.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time Timer',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'Time Timer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Color _selectedColor = Colors.red;

  bool _isActive;

  double _seconds;

  static AudioCache player = new AudioCache();

  @override
  void initState() {
    super.initState();
    this._isActive = false;
    this._seconds = 1500;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: OrientationBuilder(builder: (context, orientation) =>
          Flex(
            direction: orientation == Orientation.portrait ? Axis.vertical : Axis.horizontal,
            children: <Widget>[
              Expanded(child: Container(),),
              TimeTimer(
                radius: min(size.width, size.height) - 25,
                seconds: this._seconds,
                color: this._selectedColor,
                isActive: this._isActive,
                onDrag: updateSeconds,
                tick: updateSeconds,
                onEnd: onEnd,
              ),
              Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: FloatingActionButton(
                  child: Icon(this._isActive ? Icons.pause : Icons.play_arrow),
                  onPressed: toggleTimer,
                ),
              ),
              Expanded(child: Container(),)
            ],
          )
        )
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Change Color',
        child: Icon(Icons.colorize),
        onPressed: () {
          showDialog(context: context,
            builder: (context) => Dialog(
              backgroundColor: Colors.white,
              child: MaterialColorPicker(
                onColorChange: (Color color) {
                  setState(() => this._selectedColor = color);
                },
                selectedColor: this._selectedColor
              )
          ));
        },
      ),
    );
  }

  playAlram() async {
    await player.play('beeps_notification.mp3');
  }

  updateSeconds(seconds) {
    setState(() => this._seconds = seconds);
  }

  onEnd() async {
    toggleTimer(force: false);
    if (await Vibration.hasVibrator())
    {
      playAlram();
      Vibration.vibrate(pattern: [300, 500, 300, 500, 300]);
    }
  }

  toggleTimer({ bool force }) {
    if (!this._isActive && this._seconds <= 0) return;

    setState(() {
      if (force != null) this._isActive = force;
      else this._isActive = !this._isActive;

      Screen.keepOn(this._isActive);
    });
  }
}
