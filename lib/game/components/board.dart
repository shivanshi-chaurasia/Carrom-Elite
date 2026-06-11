import 'package:flutter/material.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import '../../core/constants/colors.dart';

class CarromBoard extends BodyComponent {
  CarromBoard({required this.size});

  final Vector2 size;

  @override
  Body createBody() {
    var bd = BodyDef(type: BodyType.static, position: Vector2.zero());
    var body = world.createBody(bd);

    var w = size.x;
    var h = size.y;

    // Outer frame walls
    var top = EdgeShape()..set(Vector2(0, 0), Vector2(w, 0));
    var right = EdgeShape()..set(Vector2(w, 0), Vector2(w, h));
    var bottom = EdgeShape()..set(Vector2(w, h), Vector2(0, h));
    var left = EdgeShape()..set(Vector2(0, h), Vector2(0, 0));

    var wallFixture = FixtureDef(top)..restitution = 0.8..friction = 0.1; // highly bouncy frame

    body.createFixture(wallFixture);
    body.createFixture(FixtureDef(right)..restitution = 0.8..friction = 0.1);
    body.createFixture(FixtureDef(bottom)..restitution = 0.8..friction = 0.1);
    body.createFixture(FixtureDef(left)..restitution = 0.8..friction = 0.1);

    return body;
  }

  @override
  void render(Canvas canvas) {
    // draw carrom board pattern
    var w = size.x;
    var h = size.y;

    var borderPaint = Paint()
      ..color = AppColors.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    var bgPaint = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.fill;

    var designPaint = Paint()
      ..color = AppColors.line.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.3;

    // Fill background
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), borderPaint);

    // Center circles
    var cx = w / 2;
    var cy = h / 2;
    canvas.drawCircle(Offset(cx, cy), 5.5, designPaint);
    canvas.drawCircle(Offset(cx, cy), 1.8, designPaint);

    // Baselines
    var baselineDist = 6.0;
    // Bottom baseline
    canvas.drawLine(Offset(baselineDist, h - baselineDist), Offset(w - baselineDist, h - baselineDist), designPaint);
    canvas.drawLine(Offset(baselineDist, h - baselineDist - 1.2), Offset(w - baselineDist, h - baselineDist - 1.2), designPaint);
    canvas.drawCircle(Offset(baselineDist, h - baselineDist - 0.6), 0.6, designPaint);
    canvas.drawCircle(Offset(w - baselineDist, h - baselineDist - 0.6), 0.6, designPaint);

    // Top baseline
    canvas.drawLine(Offset(baselineDist, baselineDist), Offset(w - baselineDist, baselineDist), designPaint);
    canvas.drawLine(Offset(baselineDist, baselineDist + 1.2), Offset(w - baselineDist, baselineDist + 1.2), designPaint);
    canvas.drawCircle(Offset(baselineDist, baselineDist + 0.6), 0.6, designPaint);
    canvas.drawCircle(Offset(w - baselineDist, baselineDist + 0.6), 0.6, designPaint);
  }
}
