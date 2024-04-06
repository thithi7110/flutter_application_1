import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Block Breaker Game',
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  double ballX = 50;
  double ballY = 50;
  double ballSpeed = 15;
  double ballDirectionX = 1;
  double ballDirectionY = 1;
  double paddleX = 160;
  double paddleWidth = 100;
  double paddleHeight = 10;
  List<Rect> blocks = [];
  bool gameStarted = false;
  int score = 0;

  static const int rowCount = 5;
  static const int columnCount = 5;
  static const double blockWidth = 60;
  static const double blockHeight = 20;
  static const double blockSpacing = 10;

  @override
  void initState() {
    super.initState();
    _initializeBlocks();
    _startGame();
  }

  void _initializeBlocks() {
    for (int i = 0; i < rowCount; i++) {
      for (int j = 0; j < columnCount; j++) {
        double x = j * (blockWidth + blockSpacing);
        double y = i * (blockHeight + blockSpacing);
        blocks.add(Rect.fromLTWH(x, y, blockWidth, blockHeight));
      }
    }
  }

  void _startGame() {
    gameStarted = true;
    Timer.periodic(Duration(milliseconds: 50), (timer) {
      setState(() {
        ballX += ballDirectionX * ballSpeed;
        ballY += ballDirectionY * ballSpeed;

        if (ballX <= 0 || ballX >= MediaQuery.of(context).size.width - 20) {
          ballDirectionX *= -1;
        }

        if (ballY <= 0) {
          ballDirectionY *= -1;
        }

        if (ballY >= MediaQuery.of(context).size.height - 20) {
          gameStarted = false;
          timer.cancel();
          _showGameOverDialog();
        }

        // if (ballY >= MediaQuery.of(context).size.height - 40 &&
        //     ballX >= paddleX &&
        //     ballX <= paddleX + paddleWidth) {
        //   ballDirectionY *= -1;
        // }
        if (ballY >= MediaQuery.of(context).size.height - 40 - paddleHeight){
          debugPrint("hit");
        }
        if (ballY >= MediaQuery.of(context).size.height - 40 - paddleHeight - 80 &&
            ballX >= paddleX &&
            ballX <= paddleX + paddleWidth) {
          ballDirectionY *= -1;
        }

        for (int i = 0; i < blocks.length; i++) {
          if (blocks[i].contains(Offset(ballX, ballY))) {
            ballDirectionY *= -1;
            setState(() {
              blocks.removeAt(i);
              score++;
            });
            break;
          }
        }

        if (blocks.isEmpty) {
          gameStarted = false;
          timer.cancel();
          _showWinDialog();
        }
      });
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Text('Your score: $score'),
          actions: [
            TextButton(
              child: Text('Play Again'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  ballX = 50;
                  ballY = 50;
                  paddleX = 160;
                  blocks.clear();
                  _initializeBlocks();
                  score = 0;
                  gameStarted = false;
                  _startGame();
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('You Win!'),
          content: Text('Your score: $score'),
          actions: [
            TextButton(
              child: Text('Play Again'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  ballX = 50;
                  ballY = 50;
                  paddleX = 160;
                  blocks.clear();
                  _initializeBlocks();
                  score = 0;
                  gameStarted = false;
                  _startGame();
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Block Breaker'),
      ),
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          setState(() {
            paddleX += details.delta.dx;
            paddleX = max(0, min(paddleX, MediaQuery.of(context).size.width - paddleWidth));
          });
        },
        child: Stack(
          children: [
            Container(
              color: Colors.white,
            ),
            Positioned(
              top: ballY,
              left: ballX,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: paddleX,
              child: Container(
                width: paddleWidth,
                height: paddleHeight,
                color: Colors.blue,
              ),
            ),
            for (var block in blocks)
              Positioned(
                top: block.top,
                left: block.left,
                child: Container(
                  width: block.width,
                  height: block.height,
                  color: Colors.green,
                ),
              ),
            Positioned(
              top: 20,
              right: 20,
              child: Text(
                'Score: $score',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}