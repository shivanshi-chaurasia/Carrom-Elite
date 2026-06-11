import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

import '../core/constants/colors.dart';

import 'components/board.dart';
import 'components/coin.dart';
import 'components/pocket.dart';
import 'components/striker.dart';

class CarromGame extends Forge2DGame with PanDetector {
  CarromGame({
    required this.mode,
    required this.onScoreChanged,
    required this.onTurnChanged,
    required this.onGameOver,
  }) : super(gravity: Vector2.zero());

  final String mode; // 1v1, private, bot
  final Function(int p1Score, int p2Score) onScoreChanged;
  final Function(String activeTurn) onTurnChanged;
  final Function(String winner) onGameOver;

  late CarromBoard board;
  late CarromStriker striker;
  final List<CarromCoin> coins = [];
  final List<CarromPocket> pockets = [];

  final Vector2 boardSize = Vector2(44, 44);
  
  // Game states
  String activeTurn = 'player1'; // player1, player2
  int player1Score = 0;
  int player2Score = 0;

  // Striker aiming gesture properties
  Vector2? dragStart;
  Vector2? dragCurrent;
  bool showGuide = false;
  bool isMoving = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 1. Add Board
    board = CarromBoard(size: boardSize);
    await world.add(board);

    // 2. Add Pockets
    var pocketOffset = 3.2;
    var positions = [
      Vector2(pocketOffset, pocketOffset),
      Vector2(boardSize.x - pocketOffset, pocketOffset),
      Vector2(pocketOffset, boardSize.y - pocketOffset),
      Vector2(boardSize.x - pocketOffset, boardSize.y - pocketOffset),
    ];

    for (var pos in positions) {
      var p = CarromPocket(pos: pos, onPocketed: _handlePocketed);
      pockets.add(p);
      await world.add(p);
    }

    // 3. Add Striker
    striker = CarromStriker(initialPos: Vector2(boardSize.x / 2, boardSize.y - 6.6));
    await world.add(striker);

    // 4. Add Guide Line component
    await world.add(GuideLineComponent());

    // 5. Spawn Coins
    _spawnCoins();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // scale to fit board in center
    final boardDim = max(boardSize.x, boardSize.y) + 2.0;
    final minScreenDim = min(size.x, size.y);
    camera.viewfinder.zoom = minScreenDim / boardDim;
    camera.viewfinder.position = boardSize / 2;
  }

  void _spawnCoins() {
    var center = boardSize / 2;
    // Queen (center)
    var q = CarromCoin(type: CoinType.queen, initialPos: center);
    coins.add(q);
    world.add(q);

    // Circle of coins
    var radius = 3.5;
    for (var i = 0; i < 6; i++) {
      var angle = i * (pi / 3);
      var offset = Vector2(cos(angle), sin(angle)) * radius;
      
      // alternate black and white
      var type = i % 2 == 0 ? CoinType.white : CoinType.black;
      var c = CarromCoin(type: type, initialPos: center + offset);
      coins.add(c);
      world.add(c);
    }
  }

  void updateStrikerX(double x) {
    if (isMoving || !striker.isPlaced) return;
    
    // constrain striker to baseline bounds
    var minX = 7.0;
    var maxX = boardSize.x - 7.0;
    var targetX = minX + (maxX - minX) * x;
    
    striker.reset(Vector2(targetX, striker.initialPos.y));
  }

  // Touch controls for aiming
  @override
  void onPanStart(DragStartInfo info) {
    if (isMoving || activeTurn == 'player2' && mode == 'bot') return;

    var touchPos = screenToWorld(info.eventPosition.global);
    var dist = touchPos.distanceTo(striker.body.position);

    if (dist < 4.5) {
      dragStart = striker.body.position.clone();
      dragCurrent = touchPos;
      showGuide = true;
    }
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (showGuide) {
      dragCurrent = screenToWorld(info.eventPosition.global);
    }
  }

  @override
  void onPanEnd(DragEndInfo info) {
    if (!showGuide || dragStart == null || dragCurrent == null) return;

    showGuide = false;
    var shotDir = dragStart! - dragCurrent!;
    
    // limit force
    var forceMag = min(shotDir.length * 12, 160.0);
    if (forceMag > 15) {
      var force = shotDir.normalized() * forceMag;
      striker.fire(force);
      isMoving = true;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isMoving) {
      // check if all bodies stopped moving
      var stillMoving = false;
      
      // check striker
      if (striker.body.linearVelocity.length > 0.08) {
        stillMoving = true;
      }
      
      // check coins
      for (var c in coins) {
        if (c.isMounted && c.body.linearVelocity.length > 0.08) {
          stillMoving = true;
        }
      }

      if (!stillMoving) {
        isMoving = false;
        _endTurn();
      }
    }
  }

  void _handlePocketed(Body coinBody) {
    // find matching coin component
    CarromCoin? matchedCoin;
    for (var c in coins) {
      if (c.body == coinBody) {
        matchedCoin = c;
        break;
      }
    }

    if (matchedCoin != null) {
      matchedCoin.removeFromParent();
      coins.remove(matchedCoin);

      // increment score
      var val = matchedCoin.type == CoinType.white
          ? 10
          : matchedCoin.type == CoinType.black
              ? 5
              : 25;

      if (activeTurn == 'player1') {
        player1Score += val;
      } else {
        player2Score += val;
      }
      onScoreChanged(player1Score, player2Score);

      // check if all coins are gone
      if (coins.isEmpty) {
        var winner = player1Score > player2Score ? 'player1' : 'player2';
        onGameOver(winner);
      }
    } else if (striker.body == coinBody) {
      // striker pocketed! foul
      print('foul: striker pocketed');
      if (activeTurn == 'player1') {
        player1Score = max(0, player1Score - 5);
      } else {
        player2Score = max(0, player2Score - 5);
      }
      onScoreChanged(player1Score, player2Score);
      striker.reset(Vector2(boardSize.x / 2, boardSize.y - 6.6));
    }
  }

  void _endTurn() {
    // reset striker back to baseline
    striker.reset(Vector2(boardSize.x / 2, boardSize.y - 6.6));

    // swap turn
    activeTurn = activeTurn == 'player1' ? 'player2' : 'player1';
    onTurnChanged(activeTurn);

    // if bot's turn, trigger bot shot
    if (activeTurn == 'player2' && mode == 'bot' && coins.isNotEmpty) {
      _triggerBotTurn();
    }
  }

  void _triggerBotTurn() async {
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    if (coins.isEmpty) return;

    // bot logic: pick random coin, slide to matching base coordinate, and shoot
    var targetCoin = coins[Random().nextInt(coins.length)];
    var targetPos = targetCoin.body.position;

    // slide striker to align nicely with coin
    var botX = targetPos.x + (Random().nextDouble() * 2 - 1.0);
    botX = botX.clamp(7.0, boardSize.x - 7.0);
    
    striker.reset(Vector2(botX, 6.6)); // bots play from top baseline

    // aim towards coin
    var botShot = targetPos - striker.body.position;
    var force = botShot.normalized() * (60.0 + Random().nextDouble() * 60.0);
    
    striker.fire(force);
    isMoving = true;
  }

}

class GuideLineComponent extends Component with HasGameReference<CarromGame> {
  @override
  void render(Canvas canvas) {
    if (game.showGuide && game.dragStart != null && game.dragCurrent != null) {
      var guidePaint = Paint()
        ..color = AppColors.teal
        ..strokeWidth = 0.4
        ..style = PaintingStyle.stroke;

      var shotDir = game.dragStart! - game.dragCurrent!;
      var endPoint = game.striker.body.position + shotDir.normalized() * min(shotDir.length * 1.5, 12.0);

      canvas.drawLine(
        Offset(game.striker.body.position.x, game.striker.body.position.y),
        Offset(endPoint.x, endPoint.y),
        guidePaint,
      );

      // draw target circle preview
      canvas.drawCircle(Offset(endPoint.x, endPoint.y), 0.6, guidePaint);
    }
  }
}
