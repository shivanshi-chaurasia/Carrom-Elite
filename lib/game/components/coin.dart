import 'package:flutter/material.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import '../../core/constants/colors.dart';

enum CoinType { white, black, queen }

class CarromCoin extends BodyComponent {
  CarromCoin({
    required this.type,
    required this.initialPos,
  });

  final CoinType type;
  final Vector2 initialPos;

  @override
  Body createBody() {
    var bd = BodyDef(
      type: BodyType.dynamic,
      position: initialPos,
      linearDamping: 1.2, // friction with board
      angularDamping: 1.0,
    );

    var shape = CircleShape()..radius = 1.6; // meter scale representation

    var fd = FixtureDef(shape)
      ..density = 1.0
      ..restitution = 0.65 // bounciness
      ..friction = 0.15;

    return world.createBody(bd)..createFixture(fd);
  }

  @override
  void render(Canvas canvas) {
    var radius = 1.6;
    var paint = Paint()
      ..color = type == CoinType.white
          ? AppColors.white
          : type == CoinType.black
              ? Colors.grey[850]!
              : AppColors.red
      ..style = PaintingStyle.fill;

    var strokePaint = Paint()
      ..color = AppColors.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.3;

    canvas.drawCircle(Offset.zero, radius, paint);
    canvas.drawCircle(Offset.zero, radius, strokePaint);
    canvas.drawCircle(Offset.zero, radius * 0.4, strokePaint); // inner design
  }
}
