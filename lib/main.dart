import 'dart:math';

import 'package:flutter/material.dart';
import 'package:time_timer/presentation/modal.dart';
import 'package:time_timer/presentation/timer.dart';
import 'package:screen/screen.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time Timer',
      theme: new ThemeData(
          primarySwatch: Colors.red,
          primaryColor: Colors.white,
          textTheme: TextTheme(
              title: TextStyle(fontFamily: 'Consolas', color: Colors.black, fontWeight: FontWeight.bold),
              caption: TextStyle(fontFamily: 'Consolas', color: Colors.black),
              body1: TextStyle(fontFamily: 'Consolas', color: Colors.black, fontSize: 17.0),
              body2: TextStyle(fontFamily: 'Consolas', color: Colors.black, fontSize: 15.0),
              display1: TextStyle(fontFamily: 'Consolas', color: Colors.black),
              display2: TextStyle(fontFamily: 'Consolas', color: Colors.black),
              display3: TextStyle(fontFamily: 'Consolas', color: Colors.black),
              display4: TextStyle(fontFamily: 'Consolas', color: Colors.black),
              headline: TextStyle(fontFamily: 'Consolas', color: Colors.black),
              subhead: TextStyle(fontFamily: 'Consolas', color: Colors.black),
              button: TextStyle(fontFamily: 'Consolas', color: Colors.black)
          )
      ),
      home: MyHomePage(title: 'Quick Task'),

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

    final drawer = Drawer(
        child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: Icon(FontAwesomeIcons.tasks, color: Colors.black,),
                  title: Text("Quick Task"),
                  onTap: () {},
                )
              ],
            )
        )
    );

    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.title, style: Theme.of(context).textTheme.title.copyWith(fontWeight: FontWeight.normal),),
            backgroundColor: Colors.white,
            elevation: 0.0,
          ),
          drawer: drawer,
          backgroundColor: Colors.white,
          body: OrientationBuilder(builder: (context, orientation) =>
            ModalView(
              isStacked: true,
              isTitleVisible: orientation == Orientation.portrait,
              child: Column(
                children: [
                  Expanded(
                    child: Flex(
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
                          isNumberVisible: orientation == Orientation.portrait,
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
                  ),
                ]
              ),
              modalChild: Container(
                child: Center(
                  child: Text("hellooo???", style: Theme.of(context).textTheme.body1)
                )
              ),
              maxHeight: 200,
            ),
          )
//      floatingActionButton: FloatingActionButton(
//        tooltip: 'Change Color',
//        child: Icon(Icons.colorize),
//        onPressed: () {
//          showDialog(context: context,
//            builder: (context) => Dialog(
//              backgroundColor: Colors.white,
//              child: MaterialColorPicker(
//                onColorChange: (Color color) {
//                  setState(() => this._selectedColor = color);
//                },
//                selectedColor: this._selectedColor
//              )
//          ));
//        },
//      ),
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
    debugPrint("ended");
    toggleTimer(force: false);
    if (await Vibration.hasVibrator())
    {
      playAlram();
      Vibration.vibrate(pattern: [300, 500, 300, 500, 300]);
    }
  }

  toggleTimer({ bool force }) {
    if (!this._isActive && this._seconds <= 0 && force != null) return;

    setState(() {
      if (force != null) this._isActive = force;
      else this._isActive = !this._isActive;

      debugPrint(this._isActive.toString() + ' Toggled');

      Screen.keepOn(this._isActive);
    });
  }
}
