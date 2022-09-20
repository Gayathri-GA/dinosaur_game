import 'package:dinosaur_game/constants/constants.dart';
import 'package:dinosaur_game/objects/game_element.dart';
import 'package:dinosaur_game/objects/ground_elements.dart';
import 'package:flutter/widgets.dart';

GroundElements groundElements = GroundElements()
  ..imagePath = "assets/ground.png"
  ..imageWidth = 2399
  ..imageHeight = 24;

class Ground extends GameElement {
  final Offset worldLocation;

  Ground({required this.worldLocation});

  Rect getRect(Size screenSize, double runDistance) {
    return Rect.fromLTWH(
      (worldLocation.dx - runDistance) * worlToPixelRatio,
      screenSize.height / 1.75 - groundElements.imageHeight,
      groundElements.imageWidth.toDouble(),
      groundElements.imageHeight.toDouble(),
    );
  }

  Widget render() {
    return Image.asset(groundElements.imagePath);
  }
}
