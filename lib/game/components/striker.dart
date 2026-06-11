import 'package:flutter/material.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import '../../core/constants/colors.dart';

class CarromStriker extends BodyComponent {
  CarromStriker({required this.initialPos});

  final Vector2 initialPos;
  bool isPlaced = true;

  @override
  Body createBody() {
    var bd = BodyDef(
      type: BodyType.dynamic,
      position: initialPos,
      linearDamping: 1.4, // heavy friction
      angularDamping: 1.2,
    );

    var shape = CircleShape()..radius = 2.2; // larger than coins

    var fd = FixtureDef(shape)
      ..density = 2.0
      ..restitution = 0.55 // solid hit
      ..friction = 0.1;

    return world.createBody(bd)..createFixture(fd);
  }

  void fire(Vector2 force) {
    isPlaced = false;
    body.applyLinearImpulse(force);
  }

  void reset(Vector2 pos) {
    body.setTransform(pos, 0);
    body.linearVelocity.setZero();
    body.angularVelocity = 0;
    isPlaced = true;
  }

  @override
  void render(Canvas canvas) {
    var radius = 2.2;
    var paint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.fill;

    var glowPaint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    var strokePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.3;

    canvas.drawCircle(Offset.zero, radius, paint);
    canvas.drawCircle(Offset.zero, radius + 0.4, glowPaint);
    canvas.drawCircle(Offset.zero, radius, strokePaint);
    canvas.drawCircle(Offset.zero, radius * 0.5, strokePaint); // inner striker pattern
  }
}
