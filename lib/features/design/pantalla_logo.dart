import 'package:flutter/material.dart';

class PantallaLogo extends StatelessWidget {
  const PantallaLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: 200,
          height: 200,
          child: Image.asset('assets/images/LogoConNombre.png'),
        ),
      ),
    );
  }
}