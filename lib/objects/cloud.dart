import 'package:dinosaur_game/constants/constants.dart';
import 'package:dinosaur_game/objects/game_element.dart';
import 'package:dinosaur_game/objects/ground_elements.dart';
import 'package:flutter/widgets.dart';

GroundElements cloudElement = GroundElements()
  ..imagePath = "assets/cloud.png"
  ..imageWidth = 92
  ..imageHeight = 27;

class Cloud extends GameElement {
  final Offset worldLocation;

  Cloud({required this.worldLocation});

  @override
  Rect getRect(Size screenSize, double runDistance) {
    return Rect.fromLTWH(
      (worldLocation.dx - runDistance) * worlToPixelRatio / 5,
      screenSize.height / 3 - cloudElement.imageHeight - worldLocation.dy,
      cloudElement.imageWidth.toDouble(),
      cloudElement.imageHeight.toDouble(),
    );
  }

  @override
  Widget render() {
    return Image.asset(cloudElement.imagePath);
  }
}
