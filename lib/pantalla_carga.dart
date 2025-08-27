import 'dart:async';
import 'package:flutter/material.dart';
import 'pantalla_inicio.dart'; // asegúrate de importar tu pantalla principal

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
      duration: const Duration(seconds: 3),
    )..forward();

    _animacion = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Cambiar de pantalla después de 4s
    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PantallaInicio()),
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
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: _animacion,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomPaint(
                  painter: _CopaPainter(_animacion.value),
                  size: const Size(200, 300),
                ),
                const SizedBox(height: 20),
                const Text(
                  "BlueMix",
                  style: TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CopaPainter extends CustomPainter {
  final double progreso;

  _CopaPainter(this.progreso);

  @override
  void paint(Canvas canvas, Size size) {
    final paintBorde = Paint()
      ..color = Colors.cyanAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final paintLiquido = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    // Forma triangular de la copa 🍸
    final copa = Path()
      ..moveTo(size.width * 0.2, size.height * 0.1)
      ..lineTo(size.width * 0.5, size.height * 0.5)
      ..lineTo(size.width * 0.8, size.height * 0.1)
      ..close();

    // Dibujo del borde
    canvas.drawPath(copa, paintBorde);

    // Recortamos el canvas con la forma de la copa
    canvas.save();
    canvas.clipPath(copa);

    // Calculamos el nivel del líquido
    final double nivel =
        (size.height * 0.5) - (progreso * size.height * 0.4);

    // Dibujamos un rectángulo que se recorta con la copa
    final rect = Rect.fromLTRB(
      size.width * 0.2,
      nivel,
      size.width * 0.8,
      size.height * 0.5,
    );

    canvas.drawRect(rect, paintLiquido);
    canvas.restore();

    // Base de la copa
    final base = Path()
      ..moveTo(size.width * 0.5, size.height * 0.5)
      ..lineTo(size.width * 0.5, size.height * 0.8)
      ..moveTo(size.width * 0.3, size.height * 0.8)
      ..lineTo(size.width * 0.7, size.height * 0.8);

    canvas.drawPath(base, paintBorde);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
