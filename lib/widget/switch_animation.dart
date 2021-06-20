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

class _SwitchAnimationState extends State<SwitchAnimation>
    with TickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 600);

  late bool _isSwitched = widget.initialValue;

  late final double _heightSize = widget.size / 2;
  late final double _heightPadding = 6.0;
  late final double _innerHeight = _heightSize - (_heightPadding * 2);

  late AnimationController _animationController;
  late Animation<double> _animationOpacity;
  late Animation<double> _animationCircle;

  late AnimationController _animationAlignmentController;
  late Animation<Alignment> _animationAlignment;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(vsync: this, duration: _duration)
      ..addListener(_rebuild)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _isSwitched = !_isSwitched;
          _animationController.reset();
        }
      });

    _animationAlignmentController =
        AnimationController(vsync: this, duration: _duration)
          ..addListener(_rebuild);

    _animationOpacity = TweenSequence<double>(
      <TweenSequenceItem<double>>[
        TweenSequenceItem(
          tween: Tween<double>(begin: 0, end: 1).chain(
            CurveTween(curve: Curves.easeInOutExpo),
          ),
          weight: 1,
        ),
        TweenSequenceItem(tween: ConstantTween(1), weight: 2),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1, end: 0).chain(
            CurveTween(curve: Curves.easeInOutExpo),
          ),
          weight: 1,
        ),
      ],
    ).animate(_animationController);

    _animationCircle = TweenSequence<double>(
      <TweenSequenceItem<double>>[
        TweenSequenceItem(
          tween: Tween<double>(begin: _innerHeight, end: widget.size).chain(
            CurveTween(curve: Curves.linear),
          ),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: widget.size, end: _innerHeight).chain(
            CurveTween(curve: Curves.linear),
          ),
          weight: 1,
        ),
      ],
    ).animate(_animationController);

    _animationAlignment = TweenSequence<Alignment>(
      <TweenSequenceItem<Alignment>>[
        TweenSequenceItem(
          tween: ConstantTween(Alignment.centerLeft).chain(
            CurveTween(curve: Curves.linear),
          ),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: ConstantTween(Alignment.centerRight).chain(
            CurveTween(curve: Curves.linear),
          ),
          weight: 1,
        ),
      ],
    ).animate(_animationAlignmentController);
  }

  @override
  void dispose() {
    _animationController.removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _animationController.status != AnimationStatus.completed
          ? _onTap
          : null,
      child: Container(
        width: widget.size,
        height: _heightSize,
        padding: EdgeInsets.all(_heightPadding),
        decoration: BoxDecoration(
          color: Color.lerp(
            _isSwitched ? Colors.green : Colors.grey,
            _isSwitched ? Colors.grey : Colors.green,
            _animationController.value,
          ),
          borderRadius: BorderRadius.circular(_heightSize / 2),
        ),
        child: Stack(
          alignment: _animationAlignment.value,
          children: <Widget>[
            Container(
              width: _animationCircle.value,
              height: _heightSize,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(_heightSize / 2),
              ),
            ),
            Center(
              child: Opacity(
                opacity: _animationOpacity.value,
                child: Text(
                  _isSwitched ? widget.offText : widget.onText,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _isSwitched ? Colors.grey : Colors.green,
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
    _animationController.forward();

    if (_animationAlignmentController.status == AnimationStatus.completed) {
      _animationAlignmentController.reverse();
    } else {
      _animationAlignmentController.forward();
    }
  }

  void _rebuild() => setState(() {});
}
