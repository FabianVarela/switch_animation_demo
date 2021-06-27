import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:switch_animation_demo/rebuild_mixin.dart';

class SwitchAnimation extends StatefulWidget {
  const SwitchAnimation({
    Key? key,
    this.initialValue = false,
    this.size = 200,
    this.onText = 'ON',
    this.offText = 'OFF',
  })  : assert(size >= 80 && size <= 200),
        super(key: key);

  final bool initialValue;
  final double size;
  final String onText;
  final String offText;

  @override
  _SwitchAnimationState createState() => _SwitchAnimationState();
}

class _SwitchAnimationState extends State<SwitchAnimation>
    with SingleTickerProviderStateMixin, RebuildMixin {
  static const _duration = Duration(milliseconds: 600);

  late bool _isSwitched = widget.initialValue;

  late final double _heightSize = widget.size / 2;
  late final double _heightPadding = 6.0;
  late final double _innerHeight = _heightSize - (_heightPadding * 2);

  late AnimationController _animationController;

  late Animation<double> _trapezeAnimation;
  late Animation<double> _pseudoLinearAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(vsync: this, duration: _duration)
      ..addListener(rebuild)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _isSwitched = !_isSwitched;
          _animationController.reset();
        }
      });

    _trapezeAnimation = TweenSequence<double>(
      <TweenSequenceItem<double>>[
        TweenSequenceItem(
          tween: Tween<double>(begin: 0, end: 1).chain(
            CurveTween(curve: Curves.linear),
          ),
          weight: 1,
        ),
        TweenSequenceItem(tween: ConstantTween(1), weight: 2),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1, end: 0).chain(
            CurveTween(curve: Curves.linear),
          ),
          weight: 1,
        ),
      ],
    ).animate(_animationController);

    _pseudoLinearAnimation = TweenSequence<double>(
      <TweenSequenceItem<double>>[
        TweenSequenceItem(tween: ConstantTween(0), weight: 1),
        TweenSequenceItem(
          tween: Tween<double>(begin: 0, end: 1).chain(
            CurveTween(curve: Curves.linear),
          ),
          weight: 2,
        ),
        TweenSequenceItem(tween: ConstantTween(1), weight: 1),
      ],
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.removeListener(rebuild);
    _animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final value = _isSwitched
        ? _pseudoLinearAnimation.value
        : 1 - _pseudoLinearAnimation.value;

    final color = Color.lerp(Colors.green, Colors.grey, value);
    final alignment = Alignment.lerp(
      Alignment.centerRight,
      Alignment.centerLeft,
      value,
    )!;

    final opacityValue = _trapezeAnimation.value.floorToDouble();

    final opacity = lerpDouble(0, 1, opacityValue)!;
    final width = lerpDouble(
      _innerHeight,
      widget.size,
      _trapezeAnimation.value,
    );

    return GestureDetector(
      onTap: _animationController.status != AnimationStatus.completed
          ? _animationController.forward
          : null,
      child: Container(
        width: widget.size,
        height: _heightSize,
        padding: EdgeInsets.all(_heightPadding),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(_heightSize / 2),
        ),
        child: Stack(
          alignment: alignment,
          children: <Widget>[
            Container(
              width: width,
              height: _heightSize,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(_heightSize / 2),
              ),
            ),
            Center(
              child: Opacity(
                opacity: opacity,
                child: Text(
                  _isSwitched ? widget.offText : widget.onText,
                  style: TextStyle(
                    fontSize: widget.size / 6,
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
}
