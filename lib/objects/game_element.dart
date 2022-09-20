import 'package:flutter/widgets.dart';

abstract class GameElement {
  Widget render();
  Rect getRect(Size screenSize, double runDistance);
  void update(Duration lastUpdate, Duration elapsedTime) {}
}
