import 'package:flutter/material.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import '../../core/constants/colors.dart';

class CarromPocket extends BodyComponent {
  CarromPocket({required this.pos, required this.onPocketed});

  final Vector2 pos;
  final Function(Body coinBody) onPocketed;

  @override
  Body createBody() {
    var bd = BodyDef(
      type: BodyType.static,
      position: pos,
    );

    var shape = CircleShape()..radius = 2.4; // slightly wider than coins

    var fd = FixtureDef(shape)..isSensor = true; // collision triggers contact but no rebound

    return world.createBody(bd)..createFixture(fd);
  }

  @override
  void render(Canvas canvas) {
    var radius = 2.4;
    var paint = Paint()
      ..color = AppColors.bg
      ..style = PaintingStyle.fill;

    var strokePaint = Paint()
      ..color = AppColors.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.4;

    canvas.drawCircle(Offset.zero, radius, paint);
    canvas.drawCircle(Offset.zero, radius, strokePaint);
  }
}
