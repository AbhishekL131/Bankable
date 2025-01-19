import 'package:flutter/material.dart';
import 'dart:math';

class BudgetSpeedometer extends StatelessWidget {
  final double totalExpenses;
  final double remainingBudget;
  final double budget;

  const BudgetSpeedometer({
    required this.totalExpenses,
    required this.remainingBudget,
    required this.budget,
  });

  @override
  Widget build(BuildContext context) {
    final totalFactor = (totalExpenses / budget).clamp(0.0, 1.0);
    final remainingFactor = (remainingBudget / budget).clamp(0.0, 1.0);

    return Container(
      width: 180,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Colors.blueGrey.shade900, Colors.blueGrey.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            spreadRadius: 5,
            offset: Offset(5, 10),
          ),
        ],
      ),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(seconds: 2),
        tween: Tween<double>(begin: 0, end: totalFactor),
        builder: (context, value, child) {
          return CustomPaint(
            painter: _SpeedometerPainter(
              totalFactor: value,
              remainingFactor: remainingFactor,
            ),
          );
        },
      ),
    );
  }
}

class _SpeedometerPainter extends CustomPainter {
  final double totalFactor;
  final double remainingFactor;

  _SpeedometerPainter({
    required this.totalFactor,
    required this.remainingFactor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 20;

    final totalAngle = totalFactor * pi; // Half-circle progress
    final remainingAngle = remainingFactor * pi;

    // Paint for base arc
    final basePaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15;

    // Paint for total progress arc (expenses)
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.red.shade500, Colors.red.shade900],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 15;

    // Paint for remaining budget arc
    final remainingPaint = Paint()
      ..color = Colors.green.shade600
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 15;

    // Draw base arc (the full circle background)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi, // Start angle (180 degrees)
      pi, // Sweep angle (180 degrees)
      false,
      basePaint,
    );

    // Draw total expenses arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi, // Start angle
      totalAngle, // Progress (expenses)
      false,
      progressPaint,
    );

    // Draw remaining budget arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi + totalAngle,
      remainingAngle,
      false,
      remainingPaint,
    );

    // Add tick marks around the speedometer
    final tickPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    for (double i = pi; i <= 2 * pi; i += pi / 20) {
      final tickStart = Offset(
        center.dx + (radius - 15) * cos(i),
        center.dy + (radius - 15) * sin(i),
      );
      final tickEnd = Offset(
        center.dx + radius * cos(i),
        center.dy + radius * sin(i),
      );
      canvas.drawLine(tickStart, tickEnd, tickPaint);
    }

    // Draw the needle (marking the total expenses)
    final needleAngle = pi + totalAngle; // Angle based on expenses
    final needleLength = radius - 10;
    final needleEnd = Offset(
      center.dx + needleLength * cos(needleAngle),
      center.dy + needleLength * sin(needleAngle),
    );

    final needlePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, needleEnd, needlePaint);

    // Show total expenses percentage inside the speedometer
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${(totalFactor * 100).toInt()}%',
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
