import 'dart:math';

import 'package:dinosaur_game/constants/constants.dart';
import 'package:dinosaur_game/objects/cactus.dart';
import 'package:dinosaur_game/objects/cloud.dart';
import 'package:dinosaur_game/objects/dino.dart';
import 'package:dinosaur_game/objects/game_element.dart';
import 'package:dinosaur_game/objects/ground.dart';
import 'package:dinosaur_game/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  Dino dino = Dino();
  double runVelocity = initialVelocity;
  double runDistance = 0;
  int highScore = 0;
  TextEditingController gravityController =
      TextEditingController(text: gravity.toString());
  TextEditingController accelerationController =
      TextEditingController(text: acceleration.toString());
  TextEditingController jumpVelocityController =
      TextEditingController(text: jumpVelocity.toString());
  TextEditingController runVelocityController =
      TextEditingController(text: initialVelocity.toString());
  TextEditingController dayNightOffestController =
      TextEditingController(text: dayNightOffest.toString());

  late AnimationController worldController;
  Duration lastUpdateCall = const Duration();

  ///
  List<Cactus> cactusList = [Cactus(worldLocation: const Offset(200, 0))];

  ///
  List<Ground> groundList = [
    Ground(worldLocation: const Offset(0, 0)),
    Ground(worldLocation: Offset(groundElements.imageWidth / 10, 0))
  ];

  ///
  List<Cloud> clouds = [
    Cloud(worldLocation: const Offset(100, 20)),
    Cloud(worldLocation: const Offset(200, 10)),
    Cloud(worldLocation: const Offset(350, -10)),
  ];
  final FocusNode _keyboardFocus = FocusNode();
  bool showGameOver = false;

  ///
  @override
  void initState() {
    super.initState();
    worldController =
        AnimationController(vsync: this, duration: const Duration(days: 99));
    worldController.addListener(updateGame);
    gameOver();
  }

  ///
  void gameOver() {
    setState(() {
      worldController.stop();
      dino.die();
    });
  }

  void newGame() {
    setState(() {
      highScore = max(highScore, runDistance.toInt());
      runDistance = 0;
      runVelocity = initialVelocity;
      dino.state = DinoState.running;
      dino.dispY = 0;
      worldController.reset();
      showGameOver = false;
      cactusList = [
        Cactus(worldLocation: const Offset(200, 0)),
        Cactus(worldLocation: const Offset(350, 0)),
        Cactus(worldLocation: const Offset(500, 0)),
      ];

      groundList = [
        Ground(worldLocation: const Offset(0, 0)),
        Ground(worldLocation: Offset(groundElements.imageWidth / 10, 0))
      ];

      clouds = [
        Cloud(worldLocation: const Offset(100, 20)),
        Cloud(worldLocation: const Offset(200, 10)),
        Cloud(worldLocation: const Offset(350, -15)),
        Cloud(worldLocation: const Offset(500, 10)),
        Cloud(worldLocation: const Offset(550, -10)),
      ];

      worldController.forward();
    });
  }

  ///
  updateGame() {
    try {
      double elapsedTimeSeconds;
      dino.update(lastUpdateCall, worldController.lastElapsedDuration);
      try {
        elapsedTimeSeconds =
            (worldController.lastElapsedDuration! - lastUpdateCall)
                    .inMilliseconds /
                1000;
      } catch (_) {
        elapsedTimeSeconds = 0;
      }

      runDistance += runVelocity * elapsedTimeSeconds;
      if (runDistance < 0) runDistance = 0;
      runVelocity += acceleration * elapsedTimeSeconds;

      Size screenSize = MediaQuery.of(context).size;

      Rect dinoRect = dino.getRect(screenSize, runDistance);
      for (Cactus cactus in cactusList) {
        Rect obstacleRect = cactus.getRect(screenSize, runDistance);
        if (dinoRect.overlaps(obstacleRect.deflate(20))) {
          showGameOver = true;
          gameOver();
        }

        if (obstacleRect.right < 0) {
          setState(() {
            cactusList.remove(cactus);
            cactusList.add(Cactus(
                worldLocation: Offset(
                    runDistance +
                        Random().nextInt(100) +
                        MediaQuery.of(context).size.width / worlToPixelRatio,
                    0)));
          });
        }
      }

      for (Ground groundlet in groundList) {
        if (groundlet.getRect(screenSize, runDistance).right < 0) {
          setState(() {
            groundList.remove(groundlet);
            groundList.add(
              Ground(
                worldLocation: Offset(
                  groundList.last.worldLocation.dx +
                      groundElements.imageWidth / 10,
                  0,
                ),
              ),
            );
          });
        }
      }

      for (Cloud cloud in clouds) {
        if (cloud.getRect(screenSize, runDistance).right < 0) {
          setState(() {
            clouds.remove(cloud);
            clouds.add(
              Cloud(
                worldLocation: Offset(
                  clouds.last.worldLocation.dx +
                      Random().nextInt(200) +
                      MediaQuery.of(context).size.width / worlToPixelRatio,
                  Random().nextInt(50) - 25.0,
                ),
              ),
            );
          });
        }
      }

      lastUpdateCall = worldController.lastElapsedDuration!;
    } catch (e) {
      //
    }
  }

  // Handling Keyboard events
  void handleKeyboard(RawKeyEvent keyEvent) {
    if (keyEvent.runtimeType == RawKeyDownEvent) {
      switch (keyEvent.logicalKey.debugName) {
        case "Space":
          if (dino.state != DinoState.dead) {
            dino.jump();
          }
          if (dino.state == DinoState.dead) {
            newGame();
          }
          break;
        default:
      }
    }
  }

  @override
  void dispose() {
    gravityController.dispose();
    accelerationController.dispose();
    jumpVelocityController.dispose();
    runVelocityController.dispose();
    dayNightOffestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    Size screenSize = MediaQuery.of(context).size;
    List<Widget> children = [];

    for (GameElement gameElements in [
      ...clouds,
      ...groundList,
      ...cactusList,
      dino
    ]) {
      children.add(
        AnimatedBuilder(
          animation: worldController,
          builder: (context, _) {
            Rect objectRect = gameElements.getRect(screenSize, runDistance);
            return Positioned(
              left: objectRect.left,
              top: objectRect.top,
              width: objectRect.width,
              height: objectRect.height,
              child: gameElements.render(),
            );
          },
        ),
      );
    }
    return RawKeyboardListener(
      focusNode: _keyboardFocus,
      autofocus: true,
      onKey: handleKeyboard,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 5000),
        color: (runDistance ~/ dayNightOffest) % 2 == 0
            ? Colors.white
            : Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ...children,
            AnimatedBuilder(
              animation: worldController,
              builder: (context, _) {
                return Positioned(
                  right: screenSize.width / 6,
                  top: 80,
                  child: Text(
                    'HI   $highScore  ${runDistance.toInt()}',
                    style: TextStyle(
                      fontSize: 20.toFont,
                      fontWeight: FontWeight.w500,
                      color: (runDistance ~/ dayNightOffest) % 2 == 0
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                );
              },
            ),
            showGameOver
                ? AnimatedBuilder(
                    animation: worldController,
                    builder: (context, _) {
                      return Positioned(
                        left: screenSize.width / 2 - 30,
                        top: 100,
                        child: Column(
                          children: [
                            Text(
                              'Game Over',
                              style: TextStyle(
                                fontSize: 22.toFont,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(
                              height: 10.toHeight,
                            ),
                            Icon(
                              Icons.refresh_rounded,
                              size: 30.toFont,
                            )
                          ],
                        ),
                      );
                    },
                  )
                : AnimatedBuilder(
                    animation: worldController,
                    builder: (context, _) {
                      return Positioned(
                          left: screenSize.width / 2 - 30,
                          top: 100,
                          child: const SizedBox());
                    }),
            Positioned(
              right: 20,
              top: 20,
              child: IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  gameOver();
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Change Physics"),
                        actions: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: 25,
                              width: 280,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Gravity:"),
                                  SizedBox(
                                    height: 25,
                                    width: 75,
                                    child: TextField(
                                      controller: gravityController,
                                      key: UniqueKey(),
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: 25,
                              width: 280,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Acceleration:"),
                                  SizedBox(
                                    height: 25,
                                    width: 75,
                                    child: TextField(
                                      controller: accelerationController,
                                      key: UniqueKey(),
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: 25,
                              width: 280,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Initial Velocity:"),
                                  SizedBox(
                                    height: 25,
                                    width: 75,
                                    child: TextField(
                                      controller: runVelocityController,
                                      key: UniqueKey(),
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: 25,
                              width: 280,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Jump Velocity:"),
                                  SizedBox(
                                    height: 25,
                                    width: 75,
                                    child: TextField(
                                      controller: jumpVelocityController,
                                      key: UniqueKey(),
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: 25,
                              width: 280,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Day-Night Offset:"),
                                  SizedBox(
                                    height: 25,
                                    width: 75,
                                    child: TextField(
                                      controller: dayNightOffestController,
                                      key: UniqueKey(),
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              gravity = int.parse(gravityController.text);
                              acceleration =
                                  double.parse(accelerationController.text);
                              initialVelocity =
                                  double.parse(runVelocityController.text);
                              jumpVelocity =
                                  double.parse(jumpVelocityController.text);
                              dayNightOffest =
                                  int.parse(dayNightOffestController.text);
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.toWidth,
                                  vertical: 10.toHeight),
                              color: Colors.black,
                              child: const Text(
                                "Done",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
