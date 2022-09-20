import 'dart:math';

import 'package:dinosaur_game/constants/constants.dart';
import 'package:dinosaur_game/objects/cactus.dart';
import 'package:dinosaur_game/objects/cloud.dart';
import 'package:dinosaur_game/objects/dino.dart';
import 'package:dinosaur_game/objects/game_element.dart';
import 'package:dinosaur_game/objects/ground.dart';
import 'package:dinosaur_game/utils/size_config.dart';
import 'package:flutter/material.dart';

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

  ///
  @override
  void initState() {
    super.initState();
    worldController =
        AnimationController(vsync: this, duration: const Duration(days: 99));
    worldController.addListener(updateGame);
    // worldController.forward();
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
      cactusList = [
        Cactus(worldLocation: const Offset(200, 0)),
        Cactus(worldLocation: const Offset(300, 0)),
        Cactus(worldLocation: const Offset(450, 0)),
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 5000),
      color: (runDistance ~/ dayNightOffest) % 2 == 0
          ? Colors.white
          : Colors.black,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (dino.state != DinoState.dead) {
            dino.jump();
          }
          if (dino.state == DinoState.dead) {
            newGame();
          }
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            ...children,
            AnimatedBuilder(
              animation: worldController,
              builder: (context, _) {
                return Positioned(
                  left: screenSize.width / 2 - 30,
                  top: 100,
                  child: Text(
                    'Score: ' + runDistance.toInt().toString(),
                    style: TextStyle(
                      color: (runDistance ~/ dayNightOffest) % 2 == 0
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                );
              },
            ),
            AnimatedBuilder(
              animation: worldController,
              builder: (context, _) {
                return Positioned(
                  left: screenSize.width / 2 - 50,
                  top: 120,
                  child: Text(
                    'High Score: ' + highScore.toString(),
                    style: TextStyle(
                      color: (runDistance ~/ dayNightOffest) % 2 == 0
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                );
              },
            ),
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
                                    height: 25,
                                    width: 75,
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
                                    height: 25,
                                    width: 75,
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
                                    height: 25,
                                    width: 75,
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
                                    height: 25,
                                    width: 75,
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
                                    height: 25,
                                    width: 75,
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
                            child: const Text(
                              "Done",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            Positioned(
              bottom: 10,
              child: TextButton(
                onPressed: () {
                  gameOver();
                },
                child: const Text(
                  "Quit Game",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
