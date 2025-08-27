// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coctel_app/main.dart';

void main() {
  testWidgets('Carga inicial muestra BlueMix', (WidgetTester tester) async {
    // Construir la app
    await tester.pumpWidget(const MyApp());

    // Verificar que aparece el título de la pantalla de carga
    expect(find.text('BlueMix'), findsOneWidget);

    // Avanzar el tiempo para simular la espera del splash
    await tester.pump(const Duration(seconds: 5));

    // Después de la carga debería navegar a la pantalla principal
    expect(find.text('BlueMix'), findsNothing);
  });
}
