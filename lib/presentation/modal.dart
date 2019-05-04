import 'package:flutter/material.dart';

class ModalView extends StatefulWidget {
  final Widget child;
  final Widget modalChild;

  final String title;
  final TextStyle titleTextStyle;

  final double titleHeight;

  final double minHeight;
  final double maxHeight;

  static const double defaultTitleHeight = 50;

  ModalView({
    Key key,
    this.title,
    @required this.child,
    @required this.modalChild,
    this.titleHeight = defaultTitleHeight,
    this.titleTextStyle,
    this.minHeight = defaultTitleHeight,
    this.maxHeight = double.infinity,
  }) :  assert(child != null),
        assert(modalChild != null),
        assert(titleHeight >= 0),
        assert(minHeight >= 0),
        assert(maxHeight > minHeight),
        super(key: key);


  @override
  _ModalViewState createState() => _ModalViewState();
}

class _ModalViewState extends State<ModalView> {
  double _height;

  @override
  void initState() {
    super.initState();
    this._height = 50;
  }

  void setModalHeight(height) {
    if (height < widget.minHeight || height > widget.maxHeight) return;
    setState(() => this._height = height);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        widget.child,
        Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onPanUpdate: (e) {
              final height = this._height - e.delta.dy;
              setModalHeight(height);
            },
            child: Container(
              width: size.width - 20,
              height: this._height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
                boxShadow: [
                  BoxShadow(blurRadius: 12.5, color: Colors.black12)
                ]
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    height: widget.titleHeight,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [
                          Text(
                              "Presets",
                              style: TextStyle(fontSize: 15.0, color: Color.fromRGBO(91, 93, 104, 1.0))
                          ),
                          Expanded(child: Container()),
                          Icon(Icons.keyboard_arrow_up, color: Color.fromRGBO(91, 93, 104, 1.0),)
                        ]
                      )
                    ),
                  ),
                  Expanded(
                    child: widget.modalChild
                  )
                ],
              ),
            )
          )
        )
      ]
    );
  }
}
