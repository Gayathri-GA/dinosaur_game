import 'package:dinosaur_game/constants/constants.dart';
import 'package:dinosaur_game/objects/game_element.dart';
import 'package:dinosaur_game/objects/ground_elements.dart';

import 'package:flutter/widgets.dart';

List<GroundElements> blockerFrame = [
  GroundElements()
    ..imagePath = "assets/blocker/blocker_one.png"
    ..imageHeight = 80
    ..imageWidth = 92,
  GroundElements()
    ..imagePath = "assets/blocker/blocker_two.png"
    ..imageHeight = 80
    ..imageWidth = 92,
];

class Blocker extends GameElement {
  final Offset worldLocation;
  int frame = 0;

  Blocker({required this.worldLocation});

  @override
  Rect getRect(Size screenSize, double runDistance) {
    return Rect.fromLTWH(
        (worldLocation.dx - runDistance) * worlToPixelRatio,
        4 / 7 * screenSize.height -
            blockerFrame[frame].imageHeight -
            worldLocation.dy,
        blockerFrame[frame].imageWidth.toDouble(),
        blockerFrame[frame].imageHeight.toDouble());
  }

  @override
  Widget render() {
    return Image.asset(
      blockerFrame[frame].imagePath,
      gaplessPlayback: true,
    );
  }

  @override
  void update(Duration lastUpdate, Duration elapsedTime) {
    frame = (elapsedTime.inMilliseconds / 200).floor() % 2;
  }
}
