import 'dart:math';

import 'package:dinosaur_game/constants/constants.dart';
import 'package:dinosaur_game/objects/game_element.dart';
import 'package:dinosaur_game/objects/ground_elements.dart';
import 'package:flutter/material.dart';

List<GroundElements> cactus = [
  GroundElements()
    ..imagePath = "assets/cactus/cactus_group.png"
    ..imageWidth = 104
    ..imageHeight = 100,
  GroundElements()
    ..imagePath = "assets/cactus/cactus_one.png"
    ..imageWidth = 50
    ..imageHeight = 100,
  GroundElements()
    ..imagePath = "assets/cactus/cactus_two.png"
    ..imageWidth = 98
    ..imageHeight = 100,
  GroundElements()
    ..imagePath = "assets/cactus/cactus_small_one.png"
    ..imageWidth = 34
    ..imageHeight = 70,
  GroundElements()
    ..imagePath = "assets/cactus/cactus_small_two.png"
    ..imageWidth = 68
    ..imageHeight = 70,
  GroundElements()
    ..imagePath = "assets/cactus/cactus_small_three.png"
    ..imageWidth = 107
    ..imageHeight = 70,
];

class Cactus extends GameElement {
  final GroundElements groundElements;
  final Offset worldLocation;

  Cactus({required this.worldLocation})
      : groundElements = cactus[Random().nextInt(cactus.length)];

  @override
  @override
  Rect getRect(Size screenSize, double runDistance) {
    return Rect.fromLTWH(
      (worldLocation.dx - runDistance) * worlToPixelRatio,
      screenSize.height / 1.75 - groundElements.imageHeight,
      groundElements.imageWidth.toDouble(),
      groundElements.imageHeight.toDouble(),
    );
  }

  @override
  Widget render() {
    return Image.asset(groundElements.imagePath);
  }
}
