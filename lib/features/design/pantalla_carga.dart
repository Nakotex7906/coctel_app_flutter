import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../main.dart';

class PantallaCarga extends StatefulWidget {
  const PantallaCarga({super.key});

  @override
  State<PantallaCarga> createState() => _PantallaCargaState();
}

class _PantallaCargaState extends State<PantallaCarga>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animacion;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // duración animación
    )..forward();

    _animacion = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Redirige luego de X segundos
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const PantallaPrincipal(), // 👈 Cambiado
          transitionsBuilder: (_, anim, __, child) {
            return FadeTransition(opacity: anim, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _animacion,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // Logo refinado
                CustomPaint(
                  painter: _LogoPainter(_animacion.value),
                  size: const Size(200, 260),
                ),
                const SizedBox(height: 30),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Logo
class _LogoPainter extends CustomPainter {
  final double progreso;

  _LogoPainter(this.progreso);

  @override
  void paint(Canvas canvas, Size size) {
    final borde = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillBlue = Paint()
      ..shader = LinearGradient(
        colors: [Colors.lightBlueAccent.shade100, Colors.blueAccent],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Triángulo de la copa
    final copa = Path()
      ..moveTo(size.width * 0.25, size.height * 0.2)
      ..lineTo(size.width * 0.5, size.height * 0.55)
      ..lineTo(size.width * 0.75, size.height * 0.2)
      ..close();
    canvas.drawPath(copa, borde);

    // Líquido azul
    canvas.save();
    canvas.clipPath(copa);
    final double nivel = (size.height * 0.55) - (progreso * size.height * 0.35);
    final rect = Rect.fromLTRB(
      size.width * 0.25,
      nivel,
      size.width * 0.75,
      size.height * 0.55,
    );
    canvas.drawRect(rect, fillBlue);
    canvas.restore();

    // Base de la copa
    final base = Path()
      ..moveTo(size.width * 0.5, size.height * 0.55)
      ..lineTo(size.width * 0.5, size.height * 0.85)
      ..moveTo(size.width * 0.38, size.height * 0.85)
      ..lineTo(size.width * 0.62, size.height * 0.85);
    canvas.drawPath(base, borde);

    // Limón
    final center = Offset(size.width * 0.75, size.height * 0.15);
    final radio = size.width * 0.12;

    final paintLimon = Paint()
      ..color = Colors.yellow.shade600
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radio, paintLimon);
    canvas.drawCircle(center, radio, borde);

    // Gajos internos
    for (int i = 0; i < 8; i++) {
      final ang = (pi / 4) * i;
      final dx = center.dx + radio * cos(ang);
      final dy = center.dy + radio * sin(ang);
      canvas.drawLine(center, Offset(dx, dy), borde);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
