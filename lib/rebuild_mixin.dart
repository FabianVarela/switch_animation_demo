import 'package:flutter/material.dart';

mixin RebuildMixin<S extends StatefulWidget> on State<S> {
  void rebuild() => setState(() {});
}
