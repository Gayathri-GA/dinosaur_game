import 'package:dinosaur_game/constants/constants.dart';
import 'package:dinosaur_game/objects/game_element.dart';
import 'package:dinosaur_game/objects/ground_elements.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

List<GroundElements> dino = [
  GroundElements()
    ..imagePath = "assets/dino/dino_one.png"
    ..imageWidth = 48
    ..imageHeight = 54,
  GroundElements()
    ..imagePath = "assets/dino/dino_two.png"
    ..imageWidth = 48
    ..imageHeight = 54,
  GroundElements()
    ..imagePath = "assets/dino/dino_three.png"
    ..imageWidth = 48
    ..imageHeight = 54,
  GroundElements()
    ..imagePath = "assets/dino/dino_four.png"
    ..imageWidth = 48
    ..imageHeight = 54,
  GroundElements()
    ..imagePath = "assets/dino/dino_five.png"
    ..imageWidth = 48
    ..imageHeight = 54,
  GroundElements()
    ..imagePath = "assets/dino/dino_six.png"
    ..imageWidth = 48
    ..imageHeight = 54,
];

enum DinoState {
  jumping,
  running,
  dead,
}

class Dino extends GameElement {
  GroundElements currentSprite = dino[0];
  double dispY = 0;
  double velY = 0;
  DinoState state = DinoState.running;

  @override
  Widget render() {
    return Image.asset(currentSprite.imagePath);
  }

  @override
  Rect getRect(Size screenSize, double runDistance) {
    return Rect.fromLTWH(
      screenSize.width / 10,
      screenSize.height / 1.75 - currentSprite.imageHeight - dispY,
      currentSprite.imageWidth.toDouble(),
      currentSprite.imageHeight.toDouble(),
    );
  }

  @override
  void update(Duration lastUpdate, Duration? elapsedTime) {
    double elapsedTimeSeconds;
    try {
      currentSprite = dino[(elapsedTime!.inMilliseconds / 100).floor() % 2 + 2];
    } catch (_) {
      currentSprite = dino[0];
    }
    try {
      elapsedTimeSeconds = (elapsedTime! - lastUpdate).inMilliseconds / 1000;
    } catch (_) {
      elapsedTimeSeconds = 0;
    }

    dispY += velY * elapsedTimeSeconds;
    if (dispY <= 0) {
      dispY = 0;
      velY = 0;
      state = DinoState.running;
    } else {
      velY -= gravity * elapsedTimeSeconds;
    }
  }

  void jump() {
    if (state != DinoState.jumping) {
      state = DinoState.jumping;
      velY = jumpVelocity;
    }
  }

  void die() {
    currentSprite = dino[5];
    state = DinoState.dead;
  }
}
