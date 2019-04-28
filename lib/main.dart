import 'dart:math';

import 'package:flutter/material.dart';
import 'package:time_timer/presentation/timer.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:screen/screen.dart';

void main() {
  // Prevent screen from going into sleep mode:
  Screen.keepOn(true);

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

  @override
  void initState() {
    super.initState();
    this._isActive = false;
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
                  seconds: 60,
                  color: this._selectedColor,
                  isActive: this._isActive,
                  onDrag: (seconds) {

                  }
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

  toggleTimer() {
    setState(() {
      this._isActive = !this._isActive;
    });
  }
}
