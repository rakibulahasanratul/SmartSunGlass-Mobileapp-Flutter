import 'package:flutter/material.dart';

class CustomBatteryPainter extends CustomPainter {
  CustomBatteryPainter({
    required this.charge,
    this.batteryColor = Colors.green,
  });

  final double charge;
  final Color batteryColor;

  final double batteryShellWidth = 33.33;
  final double batteryShellHeight = 16.66;
  final double chargeWidth = 26.66;
  final double chargeHeight = 11.66;
  final double batteryPositivePowerHeight = 6.66;
  final double batteryPositivePowerWidth = 3.33;

  final batteryShellPainter = Paint()
    ..style = PaintingStyle.stroke
    ..color = Colors.black;

  final batteryChargeStrokePainter = Paint()
    ..style = PaintingStyle.stroke
    ..color = Colors.black;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.height / 2, size.width / 2);

    final batteryPowerCenter = Offset(
      center.dx + batteryShellWidth / 2 + batteryPositivePowerWidth / 2,
      center.dy,
    );

    final shellRect = Rect.fromCenter(
      center: center,
      width: batteryShellWidth,
      height: batteryShellHeight,
    );

    final fullChargeRect = Rect.fromCenter(
      center: center,
      width: chargeWidth,
      height: chargeHeight,
    );

    final positivePowerRect = Rect.fromCenter(
      center: batteryPowerCenter,
      width: batteryPositivePowerWidth,
      height: batteryPositivePowerHeight,
    );

    final chargeRect = Rect.fromLTWH(
      fullChargeRect.left,
      fullChargeRect.top,
      (charge * chargeWidth) / 100,
      chargeHeight,
    );

    canvas
      ..drawRect(shellRect, batteryShellPainter)
      ..drawRect(fullChargeRect, batteryChargeStrokePainter)
      ..drawRect(
        chargeRect,
        Paint()
          ..style = PaintingStyle.fill
          ..color = batteryColor,
      )
      ..drawRect(positivePowerRect, batteryShellPainter);
  }

  @override
  bool shouldRepaint(CustomBatteryPainter oldDelegate) {
    return oldDelegate.charge != charge;
  }
}
