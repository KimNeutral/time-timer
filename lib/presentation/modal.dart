import 'package:flutter/material.dart';

class ModalView extends StatefulWidget {
  final Widget child;
  final Widget modalChild;

  final String title;
  final TextStyle titleTextStyle;

  final double titleHeight;

  final double minHeight;
  final double maxHeight;

  final bool isStacked;
  final bool isTitleVisible;

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
    this.isStacked = true,
    this.isTitleVisible = true,
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
  void didUpdateWidget(ModalView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isTitleVisible != widget.isTitleVisible) {
      calculateHeight();
    }
  }

  @override
  void initState() {
    super.initState();
    calculateHeight();
  }

  void calculateHeight() {
    final height = widget.isTitleVisible ? widget.titleHeight : 0.0;
    setModalHeight(height);
  }

  void setModalHeight(height) {
    if (
      (widget.isTitleVisible && (height < widget.minHeight || height > widget.maxHeight)) ||
      (!widget.isTitleVisible && height < 0)
    ) {
      return;
    }

    setState(() => this._height = height);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Padding(padding: EdgeInsets.only(bottom: widget.isStacked ? 0 : widget.titleHeight), child: widget.child),
        Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onPanUpdate: (e) {
              final height = this._height - e.delta.dy;
              setModalHeight(height);
            },
            child: Container(
              width: size.width - 20 > 0 ? size.width - 20 : 0,
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
