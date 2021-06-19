import 'package:flutter/material.dart';

class SwitchAnimation extends StatefulWidget {
  const SwitchAnimation({
    Key? key,
    this.initialValue = false,
    this.size = 200,
    this.onText = 'ON',
    this.offText = 'OFF',
  }) : super(key: key);

  final bool initialValue;
  final double size;
  final String onText;
  final String offText;

  @override
  _SwitchAnimationState createState() => _SwitchAnimationState();
}

class _SwitchAnimationState extends State<SwitchAnimation> {
  static const _duration = Duration(milliseconds: 300);

  late bool _isSwitched = widget.initialValue;
  late Alignment _alignment =
      widget.initialValue ? Alignment.centerRight : Alignment.centerLeft;
  late Color _backgroundColor =
      widget.initialValue ? Colors.green : Colors.grey;
  late int _step = widget.initialValue ? 0 : 2;
  late Color _textColor = widget.initialValue ? Colors.grey : Colors.green;

  double _textOpacity = 0;

  @override
  Widget build(BuildContext context) {
    final _heightSize = widget.size / 2;
    final _heightPadding = 6.0;
    final _innerHeight = _heightSize - (_heightPadding * 2);

    final _widths = [_innerHeight, widget.size, _innerHeight];

    return GestureDetector(
      onTap: _step != 1 ? _onTap : null,
      child: AnimatedContainer(
        duration: _duration,
        width: widget.size,
        height: _heightSize,
        padding: EdgeInsets.all(_heightPadding),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(_heightSize / 2),
        ),
        child: Stack(
          alignment: _alignment,
          children: [
            AnimatedContainer(
              duration: _duration,
              curve: Curves.easeInOut,
              width: _widths[_step],
              height: _heightSize,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(_heightSize / 2),
              ),
            ),
            Center(
              child: AnimatedOpacity(
                duration: _duration,
                opacity: _textOpacity,
                curve: Curves.easeInOutQuint,
                child: Text(
                  _isSwitched ? 'ON' : 'OFF',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTap() async {
    if (_step == 0) {
      setState(() {
        _step = 1;
        _textOpacity = 1;
        _textColor = Colors.grey;
        _isSwitched = !_isSwitched;
      });
      await Future.delayed(_duration);
      setState(() {
        _step = 2;
        _alignment = Alignment.centerLeft; // Alignment.centerRight
        _backgroundColor = Colors.grey;
        _textOpacity = 0;
      });
    } else if (_step == 2) {
      setState(() {
        _step = 1;
        _textOpacity = 1;
        _textColor = Colors.green;
        _isSwitched = !_isSwitched;
      });
      await Future.delayed(_duration);
      setState(() {
        _step = 0;
        _alignment = Alignment.centerRight; // Alignment.centerLeft
        _backgroundColor = Colors.green;
        _textOpacity = 0;
      });
    }
  }
}
