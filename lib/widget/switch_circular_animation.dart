import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:switch_animation_demo/rebuild_mixin.dart';

class SwitchCircularAnimation extends StatefulWidget {
  const SwitchCircularAnimation({
    Key? key,
    this.size = 200,
    this.initialValue = true,
  })  : assert(size >= 80 && size <= 200),
        super(key: key);

  final double size;
  final bool initialValue;

  @override
  _SwitchCircularAnimationState createState() =>
      _SwitchCircularAnimationState();
}

class _SwitchCircularAnimationState extends State<SwitchCircularAnimation>
    with SingleTickerProviderStateMixin, RebuildMixin {
  static const _duration = Duration(milliseconds: 2000);

  late AnimationController _animationController;
  late Animation<double> _trapezeAnimation;
  late Animation<double> _pseudoLinearAnimation;

  late bool _isSwitched = widget.initialValue;
  late final double _heightSize = widget.size / 2;

  double get _heightPadding => (widget.size * 0.075).clamp(0, 15);

  double get _innerHeight => _heightSize - (_heightPadding * 2);

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

    final alignment = Alignment.lerp(
      Alignment.centerRight,
      Alignment.centerLeft,
      value,
    )!;

    final padding = EdgeInsets.lerp(
      EdgeInsets.all(_heightPadding),
      EdgeInsets.zero,
      _trapezeAnimation.value,
    );

    final outerWidth = lerpDouble(
      widget.size,
      widget.size / 2,
      _trapezeAnimation.value,
    );

    final square = lerpDouble(
      _innerHeight,
      widget.size / 2,
      _trapezeAnimation.value,
    );

    final color = Color.lerp(Colors.green, Colors.blueAccent, value)!;

    return GestureDetector(
      onTap: _animationController.status != AnimationStatus.completed
          ? _animationController.forward
          : null,
      child: Container(
        width: outerWidth,
        height: _heightSize,
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(_heightSize / 2),
          boxShadow: <BoxShadow>[
            BoxShadow(color: color, offset: Offset(0, 10), blurRadius: 15),
          ],
        ),
        child: Stack(
          alignment: alignment,
          children: [
            Container(
              width: square,
              height: square,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(200)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
